import 'dart:convert';
import 'package:aleralarma/features/auth/data/models/auth_model.dart';
import 'package:aleralarma/features/auth/domain/entities/auth_entitie.dart';
import 'package:http/http.dart' as http;
import 'package:aleralarma/common/constants/constants.dart';

class AuthLocalDataSource {
  Future<AuthModel> login(AuthEntitie authEntitie) async {
    try {
      final url = Uri.parse('${AppConstants.serverBase}/api/v1/admin/global/login');
      
      // Imprimir información de depuración
      print("URL de login: $url");
      print("Enviando email: ${authEntitie.correo}");
      
      final payload = {
        'correo': authEntitie.correo,
        'contrasena': authEntitie.contrasena,
      };
      
      print("Payload: ${jsonEncode(payload)}");
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': AppConstants.apikey,
        },
        body: jsonEncode(payload),
      );

      // Imprimir respuesta para depuración
      print("Código de respuesta: ${response.statusCode}");
      print("Cuerpo de respuesta: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return AuthModel.fromJson(responseData);
      } else {
        // Mejor manejo de errores para entender qué está fallando
        String errorMessage = 'Error en login: ${response.statusCode}';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map && errorData.containsKey('message')) {
            errorMessage = 'Error en login: ${errorData['message']}';
          }
          
          // Loguear errores de validación detallados si están disponibles
          if (errorData is Map && errorData.containsKey('errors') && errorData['errors'] is List) {
            final errors = errorData['errors'] as List;
            for (var error in errors) {
              if (error is Map && error.containsKey('property') && error.containsKey('constraints')) {
                print("Error en campo ${error['property']}: ${error['constraints']}");
              }
            }
          }
        } catch (e) {
          print("Error al parsear respuesta de error: $e");
        }
        
        throw Exception(errorMessage);
      }
    } catch (e) {
      print("Excepción durante el login: $e");
      throw Exception('Error en login: $e');
    }
  }

  Future<AuthModel> refreshToken({required String token}) async {
    try {
      final url = Uri.parse('${AppConstants.serverBase}/api/v1/usuario/validate/$token');
      
      print("URL de refresh token: $url");
      print("Token utilizado: $token");
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-api-key': AppConstants.apikey, // Agregando API key por si acaso
        }
      );

      print("Código de respuesta refresh: ${response.statusCode}");
      print("Cuerpo de respuesta refresh: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return AuthModel.fromJson(responseData);
      } else {
        // Mejor manejo de errores
        String errorMessage = 'Error al refrescar token: ${response.statusCode}';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map && errorData.containsKey('message')) {
            errorMessage = 'Error al refrescar token: ${errorData['message']}';
          }
        } catch (_) {}
        
        throw Exception(errorMessage);
      }
    } catch (e) {
      print("Excepción durante refresh token: $e");
      throw Exception('Error al refrescar token: $e');
    }
  }
}