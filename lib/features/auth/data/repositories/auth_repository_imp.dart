import 'package:aleralarma/common/constants/constants.dart';
import 'package:aleralarma/features/auth/data/datasources/auth_local_data_source.dart';
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
  Future<AuthEntitie> getAuthLocal() async {
    PreferencesUser prefs = PreferencesUser();
    String? value =
        await prefs.loadPrefs(type: int, key: AppConstants.prefSchoolID);

    return AuthModel(uuid: value, correo: '', contrasena: '');
  }
 Future<String> getLocalTokenAuth() async {
    PreferencesUser prefs = PreferencesUser();
    String? value =
        await prefs.loadPrefs(type: String, key: AppConstants.prefTokenAuth);

    return value ?? '';
  }
  @override
Future<AuthEntitie> refreshTokenUser() async {
  String token = await getLocalTokenAuth();
  final response = await AuthLocalDataSource().refreshToken(token: token);
  
  // Only save token if it's not null
  if (response.token != null) {
    await saveLocalTokenAuth(token: response.token!);
  }
  
  return response;
}
  @override
  Future<AuthModel> login(AuthEntitie authEntitie) async {
    return await AuthLocalDataSource().login(authEntitie);
  }

  @override
  Future<void> saveLocalAuthSchool({required AuthEntitie authEntitie}) async {
    PreferencesUser prefs = PreferencesUser();
    prefs.savePrefs(
        type: int, key: AppConstants.prefSchoolID, value: authEntitie.uuid);
  }

  @override
  Future<void> saveLocalTokenAuth({required String token}) async {
    PreferencesUser prefs = PreferencesUser();

    prefs.savePrefs(
        type: String, key: AppConstants.prefTokenAuth, value: token);
  }
}
