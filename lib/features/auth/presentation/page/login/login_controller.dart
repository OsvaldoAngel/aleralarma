import 'package:aleralarma/common/settings/routes_names.dart';
import 'package:aleralarma/features/auth/data/models/GruposUsuarioModel.dart';
import 'package:aleralarma/features/auth/data/models/auth_model.dart';
import 'package:aleralarma/features/auth/data/repository/auth_repository_imp.dart';
import 'package:aleralarma/features/auth/domain/entities/auth_entitie.dart';
import 'package:aleralarma/features/auth/domain/repository/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickalert/quickalert.dart';

enum AuthStatus { checking, authenticated, notAuthenticated }

class AuthState {
  final AuthStatus status;
  final AuthEntitie? user;
  final String? errorMessage;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  
  // Campos para almacenar los datos completos
  final PersonaModel? persona;
  final UserOrAdminModel? userOrAdmin;
  final String? token;
  
  // Campos para grupos
  final GruposUsuarioModel? grupos;
  final String? grupoId;
  final String? alarmaId;

  AuthState({
    this.status = AuthStatus.checking,
    this.user,
    this.errorMessage,
    TextEditingController? emailController,
    TextEditingController? passwordController,
    this.isLoading = false,
    this.persona,
    this.userOrAdmin,
    this.token,
    this.grupos,
    this.grupoId,
    this.alarmaId,
  }) : emailController = emailController ?? TextEditingController(),
       passwordController = passwordController ?? TextEditingController();

  AuthState copyWith({
    AuthStatus? status,
    AuthEntitie? user,
    String? errorMessage,
    TextEditingController? emailController,
    TextEditingController? passwordController,
    bool? isLoading,
    PersonaModel? persona,
    UserOrAdminModel? userOrAdmin,
    String? token,
    GruposUsuarioModel? grupos,
    String? grupoId,
    String? alarmaId,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      emailController: emailController ?? this.emailController,
      passwordController: passwordController ?? this.passwordController,
      isLoading: isLoading ?? this.isLoading,
      persona: persona ?? this.persona,
      userOrAdmin: userOrAdmin ?? this.userOrAdmin,
      token: token ?? this.token,
      grupos: grupos ?? this.grupos,
      grupoId: grupoId ?? this.grupoId,
      alarmaId: alarmaId ?? this.alarmaId,
    );
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository authRepository;
  final GlobalKey<NavigatorState> navigatorKey;

  AuthNotifier({
    required this.authRepository,
    required this.navigatorKey,
  }) : super(AuthState());

 Future<void> checkAuthStatus() async {
  try {
    final authData = await authRepository.getAuthLocal();
    
    if (authData.token != null && authData.token!.isNotEmpty) {
      // Extraer información del modelo si está disponible
      PersonaModel? persona;
      UserOrAdminModel? userOrAdmin;
      
      if (authData is AuthModel) {
        persona = authData.persona;
        userOrAdmin = authData.userOrAdmin;
      }
      
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: authData,
        persona: persona,
        userOrAdmin: userOrAdmin,
        token: authData.token,
      );
      
      // Add the following code to fetch groups
      if (persona != null) {
        final grupos = await authRepository.getGruposData();
        final grupoId = await authRepository.getGrupoId();
        final alarmaId = await authRepository.getAlarmaId();
        
        // If no groups stored, try to fetch them
        if (grupos == null && persona.uuid.isNotEmpty) {
          final fetchedGrupos = await authRepository.obtenerYGuardarGruposUsuario(persona.uuid);
          if (fetchedGrupos != null) {
            state = state.copyWith(
              grupos: fetchedGrupos,
              grupoId: await authRepository.getGrupoId(),
              alarmaId: await authRepository.getAlarmaId(),
            );
          }
        } else {
          state = state.copyWith(
            grupos: grupos,
            grupoId: grupoId,
            alarmaId: alarmaId,
          );
        }
      }
    } else {
      state = state.copyWith(status: AuthStatus.notAuthenticated);
    }
  } catch (e) {
    state = state.copyWith(
      status: AuthStatus.notAuthenticated,
      errorMessage: e.toString(),
    );
  }
}

Future<void> login(BuildContext context) async {
  try {
    final email = state.emailController.text.trim();
    final password = state.passwordController.text.trim();

    // Debug info
    print("Intentando login con email: $email");

    if (email.isEmpty || password.isEmpty) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        title: 'Campos vacíos',
        text: 'Por favor, complete todos los campos',
        confirmBtnText: 'Aceptar',
        confirmBtnColor: const Color(0xFF1F2937),
      );
      return;
    }

    state = state.copyWith(
      status: AuthStatus.checking,
      isLoading: true,
    );

    final authEntitie = AuthEntitie(
      uuid: '',
      correo: email,
      contrasena: password,
    );

    // Hacer login y obtener respuesta completa
    print("Llamando a authRepository.login...");
    final loginResponse = await authRepository.login(authEntitie);
    print("Respuesta de login recibida correctamente");
    
    // El repositorio ya guarda todos los datos
    
    // Extrayendo y guardando datos en el estado
    PersonaModel? persona;
    UserOrAdminModel? userOrAdmin;
    String? token;
    
    if (loginResponse is AuthModel) {
      persona = loginResponse.persona;
      userOrAdmin = loginResponse.userOrAdmin;
      token = loginResponse.token;
      
      print("Token obtenido: ${token?.substring(0, 20)}...");
      print("Datos de persona obtenidos: ${persona != null}");
      print("Datos de userOrAdmin obtenidos: ${userOrAdmin != null}");
    }

    state = state.copyWith(
      status: AuthStatus.authenticated,
      user: loginResponse,
      persona: persona,
      userOrAdmin: userOrAdmin,
      token: token,
      errorMessage: null,
      isLoading: false,
    );

    // AGREGAR AQUÍ: Obtener y guardar grupos usando el UUID del userOrAdmin
    if (userOrAdmin != null) {
      print("Obteniendo grupos para el usuario: ${userOrAdmin.uuid}");
      try {
        final gruposData = await authRepository.obtenerYGuardarGruposUsuario(userOrAdmin.uuid);
        if (gruposData != null) {
          final grupoId = await authRepository.getGrupoId();
          final alarmaId = await authRepository.getAlarmaId();
          
          state = state.copyWith(
            grupos: gruposData,
            grupoId: grupoId,
            alarmaId: alarmaId,
          );
          
          print("Grupos obtenidos y guardados: ${gruposData.grupos.length}");
          print("GrupoId guardado: $grupoId");
          print("AlarmaId guardado: $alarmaId");
        } else {
          print("No se obtuvieron grupos para el usuario");
        }
      } catch (e) {
        print("Error al obtener grupos: $e");
      }
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      RoutesNames.alarm,
      (route) => false,
    );

  } catch (e) {
    print("Error en login: $e");
    state = state.copyWith(
      status: AuthStatus.notAuthenticated,
      errorMessage: e.toString(),
      isLoading: false,
    );

    // Mostrar un mensaje de error más amigable 
    final errorMessage = e.toString().contains("Error en login: Exception: Error en login: Exception") 
        ? "Error al iniciar sesión. Verifica tus credenciales." 
        : "Error al iniciar sesión: ${e.toString()}";
    
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Error',
      text: errorMessage,
      confirmBtnText: 'Aceptar',
      confirmBtnColor: const Color(0xFF1F2937),
    );
  }
}
  // Método para actualizar el token
  Future<void> refreshToken() async {
    try {
      final refreshResponse = await authRepository.refreshTokenUser();
      
      // Extraer información del modelo si está disponible
      PersonaModel? persona;
      UserOrAdminModel? userOrAdmin;
      
      if (refreshResponse is AuthModel) {
        persona = refreshResponse.persona;
        userOrAdmin = refreshResponse.userOrAdmin;
      }
      
      state = state.copyWith(
        user: refreshResponse,
        persona: persona,
        userOrAdmin: userOrAdmin,
        token: refreshResponse.token,
      );
    } catch (e) {
      // Si falla el refresh, cerrar sesión
      logout();
    }
  }

  void logout() async {
    // Limpiar datos de autenticación guardados
    await authRepository.clearAllAuthData();
    
    state.emailController.clear();
    state.passwordController.clear();
    state = state.copyWith(
      status: AuthStatus.notAuthenticated,
      user: null,
      persona: null,
      userOrAdmin: null,
      token: null,
    );
  }

  void clearControllers() {
    state.emailController.clear();
    state.passwordController.clear();
  }
  
  // Métodos de acceso a datos del usuario
  String getUserName() {
    return state.persona?.nombre ?? 'Usuario';
  }
  
  String getUserFullName() {
    final persona = state.persona;
    if (persona == null) return 'Usuario';
    
    return '${persona.nombre} ${persona.primerApellido} ${persona.segundoApellido}';
  }
  
  String getUserEmail() {
    return state.persona?.correo ?? '';
  }
  
  String getUserPhone() {
    return state.persona?.celular ?? '';
  }
  
  String getUserType() {
    return state.persona?.tipoPersona ?? '';
  }
  
  String getUserLocation() {
    return state.userOrAdmin?.lugar ?? '';
  }
  
  String getVerificationStatus() {
    return state.userOrAdmin?.statusVerification ?? 'No verificado';
  }
}

// Providers
final navigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) {
  return GlobalKey<NavigatorState>();
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final navigatorKey = ref.watch(navigatorKeyProvider);
  return AuthNotifier(
    authRepository: authRepository,
    navigatorKey: navigatorKey,
  );
});

// Provider para el repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImp(ref);
});