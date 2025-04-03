import 'package:aleralarma/common/settings/enviroment.dart';
import 'package:aleralarma/my_app.dart';
import 'package:aleralarma/framework/preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


String enviromentSelect = Enviroment.testing.value;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('=========ENVIROMENT SELECTED: $enviromentSelect');
  await dotenv.load(fileName: enviromentSelect);
  await PreferencesUser().initiPrefs();
  runApp(const MyApp());
}