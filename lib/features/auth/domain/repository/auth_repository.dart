import 'package:aleralarma/features/auth/data/models/auth_model.dart';
import 'package:aleralarma/features/auth/domain/entities/auth_entitie.dart';

import '../../data/models/GruposUsuarioModel.dart';

abstract class AuthRepository {
  Future<void> saveLocalTokenAuth({required String token});
  Future<void> saveLocalPersonaData({required PersonaModel persona});
  Future<void> saveLocalUserData({required UserOrAdminModel userOrAdmin});
  Future<void> clearTokenAuth();
  Future<void> clearAllAuthData();
  Future<void> saveLocalAuthuuid({required AuthEntitie authEntitie});
  Future<AuthEntitie> getAuthLocal();
  Future<AuthEntitie> refreshTokenUser();
  Future<AuthEntitie> login(AuthEntitie authEntitie);
  Future<String> getLocalTokenAuth();
  
  // Métodos para gestión de grupos
  Future<GruposUsuarioModel?> obtenerYGuardarGruposUsuario(String userAdminUuid);
  Future<void> saveGruposData(GruposUsuarioModel grupos);
  Future<void> saveGrupoId(String grupoId);
  Future<void> saveAlarmaId(String alarmaId);
  Future<GruposUsuarioModel?> getGruposData();
  Future<String> getGrupoId();
  Future<String> getAlarmaId();
}