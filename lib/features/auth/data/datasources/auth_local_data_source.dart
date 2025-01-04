import 'dart:convert';

import 'package:aleralarma/common/constants/constants.dart';
import 'package:aleralarma/common/error/api_errors.dart';
import 'package:aleralarma/features/auth/data/models/auth_model.dart';
import 'package:aleralarma/features/auth/domain/entities/auth_entitie.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class AuthLocalDataSource {
    String defaultApiServer = AppConstants.serverBase;
Future<AuthModel> login(AuthEntitie authEntitie) async {
    try {
      var response = await http.post(
        Uri.parse('$defaultApiServer/api/v1/admin/global/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(AuthModel.fromEntity(authEntitie).toJson()),
      );

      if (response.statusCode == 200) {
        final dataUTF8 = utf8.decode(response.bodyBytes);
        final responseDecode = jsonDecode(dataUTF8);
        
        // Create AuthModel with initial login token
        final authModel = AuthModel(token: responseDecode['token']);
        
        // Get refreshed token
        return await refreshToken(token: authModel.token ?? '');
      } else {
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Error en el inicio de sesión');
      }
    } catch (e, stackTrace) {
      debugPrint('ERROR: ${e.toString()}, $stackTrace');
      rethrow;
    }
  }

  Future<AuthModel> refreshToken({required String token}) async {
    if (token.isEmpty) {
      throw Exception('Token no válido');
    }

    Uri url = Uri.parse('$defaultApiServer/api/v1/usuario/validate/$token');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'}
      );

      if (response.statusCode == 200) {
        final dataUTF8 = utf8.decode(response.bodyBytes);
        final responseData = jsonDecode(dataUTF8);
        
        return AuthModel(
          token: responseData['dato'],
          // Add any other user data that comes in the response
          uuid: responseData['uuid'],
          correo: responseData['email'],
        );
      }
      throw ApiExceptionCustom(response: response);
    } catch (e, stackTrace) {
      debugPrint('ERROR url: refreshToken $url');
      debugPrint('ERROR: refreshToken ${e.toString()}, $stackTrace');
      rethrow;
    }
  }
}