import 'dart:convert';
import 'package:aleralarma/common/constants/constants.dart';
import 'package:aleralarma/features/auth/data/datasources/GruposDataSource.dart';
import 'package:aleralarma/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:aleralarma/features/auth/data/models/GruposUsuarioModel.dart';
import 'package:aleralarma/features/auth/data/models/auth_model.dart';
import 'package:aleralarma/features/auth/domain/entities/auth_entitie.dart';
import 'package:aleralarma/features/auth/domain/repository/auth_repository.dart';
import 'package:aleralarma/framework/preferences_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final repositoryProviderAuth = Provider.autoDispose<AuthRepository>(
    (ref) => AuthRepositoryImp(ref));

class AuthRepositoryImp implements AuthRepository {
  final Ref ref;
  AuthRepositoryImp(this.ref);
  
  @override
  Future<void> clearTokenAuth() async {
    PreferencesUser prefs = PreferencesUser();
    await prefs.clearOnePreference(key: AppConstants.prefTokenAuth);
  }

  @override
  Future<void> clearAllAuthData() async {
    PreferencesUser prefs = PreferencesUser();
    await prefs.clearOnePreference(key: AppConstants.prefTokenAuth);
    await prefs.clearOnePreference(key: AppConstants.prefUserData);
    await prefs.clearOnePreference(key: AppConstants.prefPersonaData);
    await prefs.clearOnePreference(key: AppConstants.prefSchoolID);
    await prefs.clearOnePreference(key: AppConstants.prefGrupoId);
    await prefs.clearOnePreference(key: AppConstants.prefAlarmaId);
    await prefs.clearOnePreference(key: AppConstants.prefGruposData);
  }
  
  @override
  Future<GruposUsuarioModel?> obtenerYGuardarGruposUsuario(String userAdminUuid) async {
    try {
      print("Obteniendo grupos para el usuario: $userAdminUuid");
      final token = await getLocalTokenAuth();
      
      if (token.isEmpty) {
        print("No hay token disponible para obtener grupos");
        return null;
      }
      
      final gruposDataSource = GruposDataSource();
      final grupos = await gruposDataSource.obtenerGruposUsuario(userAdminUuid, token);
      
      if (grupos.grupos.isNotEmpty) {
        print("Se obtuvieron ${grupos.grupos.length} grupos");
        
        // Guardamos los datos completos
        await saveGruposData(grupos);
        
        // Guardamos el ID del primer grupo y su alarma ID por defecto
        final primerGrupo = grupos.grupos.first;
        await saveGrupoId(primerGrupo.grupoId);
        await saveAlarmaId(primerGrupo.alarmaId);
        
        return grupos;
      } else {
        print("No se encontraron grupos para el usuario");
        return grupos;
      }
    } catch (e) {
      print("Error al obtener grupos: $e");
      return null;
    }
  }
  
  @override
  Future<void> saveGruposData(GruposUsuarioModel grupos) async {
    PreferencesUser prefs = PreferencesUser();
    final gruposJson = jsonEncode(grupos.toJson());
    prefs.savePrefs(
        type: String, key: AppConstants.prefGruposData, value: gruposJson);
    print("Datos de grupos guardados en preferencias");
  }
  
  @override
  Future<void> saveGrupoId(String grupoId) async {
    PreferencesUser prefs = PreferencesUser();
    prefs.savePrefs(
        type: String, key: AppConstants.prefGrupoId, value: grupoId);
    print("ID de grupo guardado: $grupoId");
  }
  
  @override
  Future<void> saveAlarmaId(String alarmaId) async {
    PreferencesUser prefs = PreferencesUser();
    prefs.savePrefs(
        type: String, key: AppConstants.prefAlarmaId, value: alarmaId);
    print("ID de alarma guardado: $alarmaId");
  }
  
  @override
  Future<GruposUsuarioModel?> getGruposData() async {
    PreferencesUser prefs = PreferencesUser();
    String? gruposJson = await prefs.loadPrefs(type: String, key: AppConstants.prefGruposData);
    
    if (gruposJson != null && gruposJson.isNotEmpty) {
      try {
        return GruposUsuarioModel.fromJson(jsonDecode(gruposJson));
      } catch (e) {
        print("Error al decodificar datos de grupos: $e");
        return null;
      }
    }
    
    return null;
  }
  
  @override
  Future<String> getGrupoId() async {
    PreferencesUser prefs = PreferencesUser();
    String? value = await prefs.loadPrefs(type: String, key: AppConstants.prefGrupoId);
    return value ?? '';
  }
  
  @override
  Future<String> getAlarmaId() async {
    PreferencesUser prefs = PreferencesUser();
    String? value = await prefs.loadPrefs(type: String, key: AppConstants.prefAlarmaId);
    return value ?? '';
  }

  @override
  Future<AuthEntitie> getAuthLocal() async {
    PreferencesUser prefs = PreferencesUser();
    String? uuid = await prefs.loadPrefs(type: String, key: AppConstants.prefSchoolID);
    String? token = await prefs.loadPrefs(type: String, key: AppConstants.prefTokenAuth);
    String? personaJson = await prefs.loadPrefs(type: String, key: AppConstants.prefPersonaData);
    String? userOrAdminJson = await prefs.loadPrefs(type: String, key: AppConstants.prefUserData);
    
    PersonaModel? persona;
    UserOrAdminModel? userOrAdmin;
    
    if (personaJson != null && personaJson.isNotEmpty) {
      try {
        persona = PersonaModel.fromJson(jsonDecode(personaJson));
      } catch (e) {
        print('Error al decodificar persona: $e');
      }
    }
    
    if (userOrAdminJson != null && userOrAdminJson.isNotEmpty) {
      try {
        userOrAdmin = UserOrAdminModel.fromJson(jsonDecode(userOrAdminJson));
      } catch (e) {
        print('Error al decodificar userOrAdmin: $e');
      }
    }
    
    String correo = persona?.correo ?? '';
    
    return AuthModel(
      uuid: uuid ?? '', 
      correo: correo,
      contrasena: '',
      token: token,
      persona: persona,
      userOrAdmin: userOrAdmin,
    );
  }
  
  Future<String> getLocalTokenAuth() async {
    PreferencesUser prefs = PreferencesUser();
    String? value = await prefs.loadPrefs(type: String, key: AppConstants.prefTokenAuth);
    return value ?? '';
  }
  
  @override
  Future<AuthEntitie> refreshTokenUser() async {
    String token = await getLocalTokenAuth();
    final response = await AuthLocalDataSource().refreshToken(token: token);
    
    // Save all the data
    if (response.token != null) {
      await saveLocalTokenAuth(token: response.token!);
    }
    
    if (response is AuthModel) {
      if (response.persona != null) {
        await saveLocalPersonaData(persona: response.persona!);
      }
      
      if (response.userOrAdmin != null) {
        await saveLocalUserData(userOrAdmin: response.userOrAdmin!);
      }
    }
    
    return response;
  }
  
  @override
  Future<AuthModel> login(AuthEntitie authEntitie) async {
    try {
      print("AuthRepository: Iniciando login...");
      final response = await AuthLocalDataSource().login(authEntitie);
      print("AuthRepository: Login exitoso, guardando datos...");
      
      // Save all the data
      if (response.token != null) {
        print("AuthRepository: Guardando token");
        await saveLocalTokenAuth(token: response.token!);
      } else {
        print("AuthRepository: Token no disponible");
      }
      
      if (response.persona != null) {
        print("AuthRepository: Guardando datos de persona");
        await saveLocalPersonaData(persona: response.persona!);
        await saveLocalAuthuuid(authEntitie: AuthEntitie(
          uuid: response.persona!.uuid,
          correo: response.persona!.correo,
          contrasena: '',
        ));
      } else {
        print("AuthRepository: Datos de persona no disponibles");
      }
      
      if (response.userOrAdmin != null) {
        print("AuthRepository: Guardando datos de userOrAdmin");
        await saveLocalUserData(userOrAdmin: response.userOrAdmin!);
      } else {
        print("AuthRepository: Datos de userOrAdmin no disponibles");
      }
      
      return response;
    } catch (e) {
      print("AuthRepository: Error durante login: $e");
      throw e; // Re-lanzamos la excepción para que la maneje el nivel superior
    }
  }

  @override
  Future<void> saveLocalAuthuuid({required AuthEntitie authEntitie}) async {
    PreferencesUser prefs = PreferencesUser();
    prefs.savePrefs(
        type: String, key: AppConstants.prefSchoolID, value: authEntitie.uuid);
  }

  @override
  Future<void> saveLocalTokenAuth({required String token}) async {
    PreferencesUser prefs = PreferencesUser();
    prefs.savePrefs(
        type: String, key: AppConstants.prefTokenAuth, value: token);
  }
  
  @override
  Future<void> saveLocalPersonaData({required PersonaModel persona}) async {
    PreferencesUser prefs = PreferencesUser();
    final personaJson = jsonEncode(persona.toJson());
    prefs.savePrefs(
        type: String, key: AppConstants.prefPersonaData, value: personaJson);
  }
  
  @override
  Future<void> saveLocalUserData({required UserOrAdminModel userOrAdmin}) async {
    PreferencesUser prefs = PreferencesUser();
    final userJson = jsonEncode(userOrAdmin.toJson());
    prefs.savePrefs(
        type: String, key: AppConstants.prefUserData, value: userJson);
  }
}