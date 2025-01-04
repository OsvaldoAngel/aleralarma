
import 'package:aleralarma/features/auth/domain/entities/auth_entitie.dart';

class AuthModel extends AuthEntitie {
  AuthModel({
    String? uuid,
    String? correo,
    String? contrasena,
    String? token,
    String? dato,
  }) : super(
          uuid: uuid,
          correo: correo,
          contrasena: contrasena,
          token: token,
          dato: dato,
        );


  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      uuid: json['uuid'],
      correo: json['correo'],
      contrasena: json['contrasena'],
      token: json['token'],
      dato: json['dato'],
    );
  }

  factory AuthModel.fromEntity(AuthEntitie entity) {
    return AuthModel(
      uuid: entity.uuid,
      correo: entity.correo,
      contrasena: entity.contrasena,
      token: entity.token,
      dato: entity.dato
    );
  }

   Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'correo': correo,
      'contrasena': contrasena,
      'token': token,
      'dato': dato,
    };
  }
}
