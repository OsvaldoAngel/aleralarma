import 'package:aleralarma/common/settings/routes_names.dart';
import 'package:aleralarma/features/auth/data/repositories/auth_repository_imp.dart';
import 'package:aleralarma/features/auth/domain/repository/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickalert/quickalert.dart';
import 'package:flutter/material.dart';
import 'package:aleralarma/features/auth/domain/entities/auth_entitie.dart';
 enum AuthStatus { checking, authenticated, notAuthenticated }

class AuthState {
  final AuthStatus status;
  final AuthEntitie? user;
  final String? errorMessage;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;

  AuthState({
    this.status = AuthStatus.checking,
    this.user,
    this.errorMessage,
    TextEditingController? emailController,
    TextEditingController? passwordController,
    this.isLoading = false,
  }) : emailController = emailController ?? TextEditingController(),
       passwordController = passwordController ?? TextEditingController();

  AuthState copyWith({
    AuthStatus? status,
    AuthEntitie? user,
    String? errorMessage,
    TextEditingController? emailController,
    TextEditingController? passwordController,
    bool? isLoading,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      emailController: emailController ?? this.emailController,
      passwordController: passwordController ?? this.passwordController,
      isLoading: isLoading ?? this.isLoading,
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

    Future<void> login(BuildContext context) async {
    try {
      final email = state.emailController.text.trim();
      final password = state.passwordController.text.trim();

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
        correo: email,
        contrasena: password,
      );

      // Hacer login y obtener respuesta inicial
      final loginResponse = await authRepository.login(authEntitie);
      
      // Guardar el token inicial
      if (loginResponse.token != null) {
        await authRepository.saveLocalTokenAuth(token: loginResponse.token!);
      }
      
      // Hacer refresh token para validar y obtener nuevo token
      final refreshResponse = await authRepository.refreshTokenUser();
      
      // Guardar el nuevo token - ahora usando el campo correcto
      final tokenToSave = refreshResponse.dato ?? refreshResponse.token;
      if (tokenToSave != null) {
        await authRepository.saveLocalTokenAuth(token: tokenToSave);
      }

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: refreshResponse,
        errorMessage: null,
        isLoading: false,
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        RoutesNames.homePage,
        (route) => false,
      );

    } catch (e) {
      print("Error en login: $e");
      state = state.copyWith(
        status: AuthStatus.notAuthenticated,
        errorMessage: e.toString(),
        isLoading: false,
      );

      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error',
        text: 'Error al iniciar sesión: ${e.toString()}',
        confirmBtnText: 'Aceptar',
        confirmBtnColor: const Color(0xFF1F2937),
      );
    }
  }

  void logout() {
    state.emailController.clear();
    state.passwordController.clear();
    state = state.copyWith(
      status: AuthStatus.notAuthenticated,
      user: null,
    );
  }

  void clearControllers() {
    state.emailController.clear();
    state.passwordController.clear();
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

// Asumiendo que tienes un provider para el repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
   return AuthRepositoryImp(ref); // Pasa el ref como argumento
});