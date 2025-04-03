import 'dart:convert';
import 'package:aleralarma/common/constants/constants.dart';
import 'package:aleralarma/features/alarm/data/model/alarma_model.dart';
import 'package:aleralarma/features/alarm/data/model/obtener_status_alarma_model.dart';
import 'package:aleralarma/features/alarm/domain/entities/alarma_entitie.dart';
import 'package:aleralarma/features/alarm/domain/entities/obtener_status_alarma_entitie.dart';
import 'package:http/http.dart' as http;

class AlarmaService {
  Future<List<ObtenerStatusAlarmaEntitie>> OBTENERSTATUSALARMA(String uuid) async {
    try {
      // Construir la URL
      final url = Uri.parse('${AppConstants.serverBase}/api/v1/alarma/status/$uuid');
      
      print("Consultando estado de alarma: $url");
      
      // Realizar la solicitud HTTP
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': AppConstants.apikey,
        },
      );

      // Verificar si la solicitud fue exitosa
      if (response.statusCode == 200) {
        // Imprimir respuesta para debug
        print("Respuesta de estado de alarma: ${response.body}");
        
        // Decodificar la respuesta JSON
        final dynamic decodedData = jsonDecode(response.body);
        
        // Manejar el formato específico que estás recibiendo
        if (decodedData is Map && decodedData.containsKey('status') && decodedData['status'] is List) {
          // Formato {"status":[{"status_alarma":"Panico","status":true}]}
          final List<dynamic> statusList = decodedData['status'];
          print("Lista de estados extraída: $statusList");
          return statusList.map((json) => ObtenerStatusAlarmaModel.fromJson(json)).toList();
        }
        
        // Mantén el código existente para manejar otros formatos posibles
        else if (decodedData is List) {
          // Si es una lista, convertimos cada elemento
          return decodedData.map((json) => ObtenerStatusAlarmaModel.fromJson(json)).toList();
        } else if (decodedData is Map) {
          // Si es un mapa, revisamos si contiene una clave "status"
          if (decodedData.containsKey('status_alarma')) {
            // Si el mapa es directamente un objeto de estado, lo convertimos y devolvemos en una lista
            return [ObtenerStatusAlarmaModel.fromJson(decodedData as Map<String, dynamic>)];
          } else if (decodedData.containsKey('data') && decodedData['data'] is List) {
            // Si el mapa contiene una clave "data" que es una lista, convertimos cada elemento de esa lista
            return (decodedData['data'] as List).map((json) => ObtenerStatusAlarmaModel.fromJson(json)).toList();
          } else if (decodedData.containsKey('data') && decodedData['data'] is Map) {
            // Si "data" es un mapa individual, lo convertimos y devolvemos en una lista
            return [ObtenerStatusAlarmaModel.fromJson(decodedData['data'])];
          } else {
            // Si no hay un formato reconocible, devolvemos una lista vacía
            print("Formato de respuesta no reconocido: $decodedData");
            return [];
          }
        } else {
          // Si no es ni lista ni mapa, devolvemos una lista vacía
          print("Formato de respuesta no reconocido: $decodedData");
          return [];
        }
      } else {
        // Si la solicitud no fue exitosa, lanzar una excepción con el mensaje de error
        String errorMessage = 'Error al obtener estado de alarma: ${response.statusCode}';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map && errorData.containsKey('message')) {
            errorMessage = 'Error al obtener estado de alarma: ${errorData['message']}';
          }
        } catch (e) {
          // Si no se puede decodificar el cuerpo de la respuesta, usar el mensaje predeterminado
        }
        
        throw Exception(errorMessage);
      }
    } catch (e) {
      // Capturar cualquier error durante la solicitud y relanzarlo
      print("Error al obtener estado de alarma: $e");
      throw Exception('Error al obtener estado de alarma: $e');
    }
  }

  Future<void> ACTIVARALARMA(String uuid, AlarmaEntitie alarmaEntitie) async {
    try {
      // Construir la URL con el uuid del grupo
      final url = Uri.parse('${AppConstants.serverBase}/api/v1/alarma/activate/$uuid');
      
      // Convertir la entidad a modelo para asegurar que tenemos el método toJson
      final alarmaModel = AlarmaModel.fromEntity(alarmaEntitie);
      
      // Imprimir datos para debug
      print("Activando alarma: $url");
      print("Datos enviados: ${alarmaModel.toJson()}");
      
      // Realizar la solicitud HTTP
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': AppConstants.apikey,
        },
        body: jsonEncode(alarmaModel.toJson()),
      );

      // Imprimir respuesta para debug
      print("Respuesta activación: ${response.statusCode} - ${response.body}");

      // Verificar si la solicitud fue exitosa
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Operación exitosa, no necesitamos devolver nada
        print('Alarma activada correctamente');
        return;
      } else {
        // Si la solicitud no fue exitosa, lanzar una excepción con el mensaje de error
        String errorMessage = 'Error al activar alarma: ${response.statusCode}';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map && errorData.containsKey('message')) {
            errorMessage = 'Error al activar alarma: ${errorData['message']}';
          }
        } catch (e) {
          // Si no se puede decodificar el cuerpo de la respuesta, usar el mensaje predeterminado
        }
        
        throw Exception(errorMessage);
      }
    } catch (e) {
      // Capturar cualquier error durante la solicitud y relanzarlo
      print("Error al activar alarma: $e");
      throw Exception('Error al activar alarma: $e');
    }
  }

  Future<void> DESACTIVARALARMA(String uuid, AlarmaEntitie alarmaEntitie) async {
    try {
      // Construir la URL con el uuid del grupo
      final url = Uri.parse('${AppConstants.serverBase}/api/v1/alarma/desactivate/$uuid');
      
      // Convertir la entidad a modelo para asegurar que tenemos el método toJson
      final alarmaModel = AlarmaModel.fromEntity(alarmaEntitie);
      
      // Imprimir datos para debug
      print("Desactivando alarma: $url");
      print("Datos enviados: ${alarmaModel.toJson()}");
      
      // Realizar la solicitud HTTP
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': AppConstants.apikey,
        },
        body: jsonEncode(alarmaModel.toJson()),
      );

      // Imprimir respuesta para debug
      print("Respuesta desactivación: ${response.statusCode} - ${response.body}");

      // Verificar si la solicitud fue exitosa
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Operación exitosa, no necesitamos devolver nada
        print('Alarma desactivada correctamente');
        return;
      } else {
        // Si la solicitud no fue exitosa, lanzar una excepción con el mensaje de error
        String errorMessage = 'Error al desactivar alarma: ${response.statusCode}';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map && errorData.containsKey('message')) {
            errorMessage = 'Error al desactivar alarma: ${errorData['message']}';
          }
        } catch (e) {
          // Si no se puede decodificar el cuerpo de la respuesta, usar el mensaje predeterminado
        }
        
        throw Exception(errorMessage);
      }
    } catch (e) {
      // Capturar cualquier error durante la solicitud y relanzarlo
      print("Error al desactivar alarma: $e");
      throw Exception('Error al desactivar alarma: $e');
    }
  }
}