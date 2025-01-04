import 'package:aleralarma/features/auth/domain/entities/auth_entitie.dart';

abstract class AuthRepository {

  Future<void> saveLocalTokenAuth({required String token});
  Future<void> clearTokenAuth();
  Future<void> saveLocalAuthSchool({required AuthEntitie authEntitie});
  Future<AuthEntitie> getAuthLocal();
  Future<AuthEntitie> refreshTokenUser();

    Future<AuthEntitie> login(
   AuthEntitie authEntitie
  );
 Future<String> getLocalTokenAuth();
}
