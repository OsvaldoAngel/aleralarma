import 'dart:convert';
import 'package:aleralarma/features/auth/data/models/GruposUsuarioModel.dart';
import 'package:http/http.dart' as http;
import 'package:aleralarma/common/constants/constants.dart';

class GruposDataSource {
  Future<GruposUsuarioModel> obtenerGruposUsuario(String userAdminUuid, String token) async {
    try {
      final url = Uri.parse('${AppConstants.serverBase}/api/v1/chat/ObtenerGruposUsuario/$userAdminUuid');
      
      print("URL para obtener grupos: $url");
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-api-key': AppConstants.apikey,
        },
      );

      print("Código de respuesta grupos: ${response.statusCode}");
      print("Cuerpo de respuesta grupos: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return GruposUsuarioModel.fromJson(responseData);
      } else {
        // Mejor manejo de errores
        String errorMessage = 'Error al obtener grupos: ${response.statusCode}';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map && errorData.containsKey('message')) {
            errorMessage = 'Error al obtener grupos: ${errorData['message']}';
          }
        } catch (e) {
          print("Error al parsear respuesta de error: $e");
        }
        
        throw Exception(errorMessage);
      }
    } catch (e) {
      print("Excepción al obtener grupos: $e");
      throw Exception('Error al obtener grupos: $e');
    }
  }
}