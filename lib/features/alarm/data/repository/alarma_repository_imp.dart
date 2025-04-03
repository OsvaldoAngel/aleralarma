import 'dart:convert';

import 'package:aleralarma/common/constants/constants.dart';
import 'package:aleralarma/features/alarm/data/remote/alarma_service.dart';
import 'package:aleralarma/features/alarm/domain/entities/alarma_entitie.dart';
import 'package:aleralarma/features/alarm/domain/entities/obtener_status_alarma_entitie.dart';
import 'package:aleralarma/features/alarm/domain/repository/alarm_repository.dart';
import 'package:aleralarma/features/auth/presentation/page/login/login_controller.dart';
import 'package:aleralarma/framework/preferences_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final alarmaRepositoryImp = Provider.autoDispose<AlarmRepository>(
    (ref) => AlarmaRepositoryImp(ref));

class AlarmaRepositoryImp implements AlarmRepository {
  final Ref ref;
  AlarmaRepositoryImp(this.ref);
  final prefs = PreferencesUser();

  @override
  Future<List<ObtenerStatusAlarmaEntitie>> OBTENERSTATUSALARMA() async {
    String uuid = await prefs.loadPrefs(type: String, key: AppConstants.prefAlarmaId) ?? "";
    print("UUID para obtener estado: $uuid");
    
    if (uuid.isEmpty) {
      print("UUID de alarma vacío, no se puede obtener estado");
      return [];
    }
    
    final response = await AlarmaService().OBTENERSTATUSALARMA(uuid);
    return response;
  }
  
  @override
  Future<void> DESACTIVARALARMA(AlarmaEntitie alarmaEntitie) async {
    // Obtener los IDs necesarios
    String uuid = await prefs.loadPrefs(type: String, key: AppConstants.prefAlarmaId) ?? "";
    String id_grupo = await prefs.loadPrefs(type: String, key: AppConstants.prefGrupoId) ?? "";
    String?  _userId;
    print("UUID para desactivar alarma: $uuid");
    print("ID de grupo: $id_grupo");
    
    if (uuid.isEmpty || id_grupo.isEmpty) {
      print("UUIDs vacíos, no se puede desactivar alarma");
      throw Exception("No se encontraron identificadores necesarios");
    }
    
    // Obtener el estado de autenticación
    final authState = ref.read(authProvider);
    
    // Obtener el tipo de persona de forma segura
    String tipoPersona = "Usuario"; // Valor por defecto
    if (authState.persona != null) {
      tipoPersona = authState.persona!.tipoPersona;
    } else {
      print("Persona es null, usando tipo de persona por defecto");
    }
 String? userDataJson = await prefs.loadPrefs(type: String, key: AppConstants.prefUserData);
    if (userDataJson != null && userDataJson.isNotEmpty) {
      try {
        final userData = jsonDecode(userDataJson);
  _userId = userData['uuid'];
        print('UserID cargado de preferencias: $_userId');
      } catch (e) {
        print('Error al decodificar datos de usuario: $e');
      }
    }
    // Crear entidad actualizada
    AlarmaEntitie updatedAlarmaEntitie = AlarmaEntitie(
      id_usuario: _userId ?? '',
      id_grupo: id_grupo, 
      tipo_usuario: tipoPersona,
      direccion: alarmaEntitie.direccion,
      coordenadas: alarmaEntitie.coordenadas,
    );

    print("Entidad para desactivar alarma creada: ${updatedAlarmaEntitie.id_usuario}, ${updatedAlarmaEntitie.tipo_usuario}");
    
    // Enviar la entidad actualizada
    return await AlarmaService().DESACTIVARALARMA(uuid, updatedAlarmaEntitie);
  }

  @override
 // También hay un problema en el repo:

@override
Future<void> ACTIVARALARMA(AlarmaEntitie alarmaEntitie) async {
  // Obtener los IDs necesarios
  String uuid = await prefs.loadPrefs(type: String, key: AppConstants.prefAlarmaId) ?? "";
  String id_grupo = await prefs.loadPrefs(type: String, key: AppConstants.prefGrupoId) ?? "";
  print("UUID para activar alarma: $uuid");
  print("ID de grupo: $id_grupo");
   String? _userId ;
  if (uuid.isEmpty || id_grupo.isEmpty) {
    print("UUIDs vacíos, no se puede activar alarma");
    throw Exception("No se encontraron identificadores necesarios");
  }
  
  // Obtener el estado de autenticación
  final authState = ref.read(authProvider);
  
  // Obtener el tipo de persona de forma segura
  String tipoPersona = "Usuario"; // Valor por defecto
  if (authState.persona != null) {
    tipoPersona = authState.persona!.tipoPersona;
  } else {
     String? userDataJson = await prefs.loadPrefs(type: String, key: AppConstants.prefUserData);
  if (userDataJson != null && userDataJson.isNotEmpty) {
    try {
      final userData = jsonDecode(userDataJson);
      _userId = userData['uuid'];
      print('UserID cargado de preferencias: $_userId');
    } catch (e) {
      print('Error al decodificar datos de usuario: $e');
    }
  }

  // ERROR: Falta cerrar el bloque else y crear la entidad dentro de la condición

  // Crear entidad actualizada
  AlarmaEntitie updatedAlarmaEntitie = AlarmaEntitie(
    id_usuario: _userId ?? '',
    id_grupo: id_grupo, 
    tipo_usuario: tipoPersona,
    direccion: alarmaEntitie.direccion,
    coordenadas: alarmaEntitie.coordenadas,
    tipo_reporte: alarmaEntitie.tipo_reporte,
  );

  print("Entidad para activar alarma creada: ${updatedAlarmaEntitie.id_usuario}, ${updatedAlarmaEntitie.tipo_usuario}");
  
  // Enviar la entidad actualizada
  return await AlarmaService().ACTIVARALARMA(uuid, updatedAlarmaEntitie);
}
}
}