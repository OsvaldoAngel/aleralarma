import 'package:aleralarma/features/auth/domain/entities/auth_entitie.dart';

class AuthModel extends AuthEntitie {
  final String? token;
  final PersonaModel? persona;
  final UserOrAdminModel? userOrAdmin;

  AuthModel({
    required String uuid,
    required String correo,
    required String contrasena,
    this.token,
    this.persona,
    this.userOrAdmin,
  }) : super(uuid: uuid, correo: correo, contrasena: contrasena);

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    // Imprimir debug para ver la estructura exacta del JSON
    print("JSON recibido en AuthModel.fromJson: $json");
    
    try {
      return AuthModel(
        uuid: json['persona'] != null ? json['persona']['uuid'] : '',
        correo: json['persona'] != null ? json['persona']['correo'] : '',
        contrasena: '',
        token: json['token'],
        persona: json['persona'] != null 
            ? PersonaModel.fromJson(json['persona']) 
            : null,
        userOrAdmin: json['userOrAdmin'] != null 
            ? UserOrAdminModel.fromJson(json['userOrAdmin']) 
            : null,
      );
    } catch (e) {
      print("Error al parsear JSON en AuthModel.fromJson: $e");
      throw Exception("Error al parsear respuesta del servidor: $e");
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (persona != null) {
      data['persona'] = persona!.toJson();
    }
    if (userOrAdmin != null) {
      data['userOrAdmin'] = userOrAdmin!.toJson();
    }
    if (token != null) {
      data['token'] = token;
    }
    return data;
  }
}

class PersonaModel {
  final String uuid;
  final String nombre;
  final String primerApellido;
  final String segundoApellido;
  final String correo;
  final String celular;
  final String tipoPersona;

  PersonaModel({
    required this.uuid,
    required this.nombre,
    required this.primerApellido,
    required this.segundoApellido,
    required this.correo,
    required this.celular,
    required this.tipoPersona,
  });

  factory PersonaModel.fromJson(Map<String, dynamic> json) {
    return PersonaModel(
      uuid: json['uuid'] ?? '',
      nombre: json['nombre'] ?? '',
      primerApellido: json['primer_apellido'] ?? '',
      segundoApellido: json['segundo_apellido'] ?? '',
      correo: json['correo'] ?? '',
      celular: json['celular'] ?? '',
      tipoPersona: json['tipo_persona'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'nombre': nombre,
      'primer_apellido': primerApellido,
      'segundo_apellido': segundoApellido,
      'correo': correo,
      'celular': celular,
      'tipo_persona': tipoPersona,
    };
  }
}

class UserOrAdminModel {
  final String uuid;
  final String idPersona;
  final String idAdministradorGlobal;
  final String idAdministradorRegional;
  final String idAdministradorColonial;
  final String lugar;
  final bool status;
  final String statusVerification;
  final String statusSolicitud;

  UserOrAdminModel({
    required this.uuid,
    required this.idPersona,
    required this.idAdministradorGlobal,
    required this.idAdministradorRegional,
    required this.idAdministradorColonial,
    required this.lugar,
    required this.status,
    required this.statusVerification,
    required this.statusSolicitud,
  });

  factory UserOrAdminModel.fromJson(Map<String, dynamic> json) {
    return UserOrAdminModel(
      uuid: json['uuid'] ?? '',
      idPersona: json['id_persona'] ?? '',
      idAdministradorGlobal: json['id_administrador_global'] ?? '',
      idAdministradorRegional: json['id_administrador_regional'] ?? '',
      idAdministradorColonial: json['id_administrador_colonial'] ?? '',
      lugar: json['lugar'] ?? '',
      status: json['status'] ?? false,
      statusVerification: json['status_verification'] ?? '',
      statusSolicitud: json['status_solicitud'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'id_persona': idPersona,
      'id_administrador_global': idAdministradorGlobal,
      'id_administrador_regional': idAdministradorRegional,
      'id_administrador_colonial': idAdministradorColonial,
      'lugar': lugar,
      'status': status,
      'status_verification': statusVerification,
      'status_solicitud': statusSolicitud,
    };
  }
}