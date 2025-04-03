import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static String serverBase = dotenv.env['API_BASE'].toString();
  static String apikey = dotenv.env['API_KEY'].toString();

  static String prefSchoolID = 'prefuuid';
  static String prefTokenAuth = 'prefTokenAuth';
  static String prefPersonaData = 'prefPersonaData';
  static String prefUserData = 'prefUserData';
  static String prefGrupoId = 'prefGrupoId';
  static String prefAlarmaId = 'prefAlarmaId';
  static String prefGruposData = 'prefGruposData';
}