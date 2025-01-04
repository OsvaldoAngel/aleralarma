import 'package:aleralarma/common/localization/app_localization.dart';
import 'package:aleralarma/common/routes/router.dart';
import 'package:aleralarma/common/theme/app_theme.dart';
import 'package:aleralarma/main.dart';
//import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:aleralarma/common/settings/key_global.dart';


// Modifica el provider para usar la clave global

// Modifica el provider para usar la clave global
final navigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) {
  return navigatorKey;  // Usa la clave global en lugar de crear una nueva
});
class MyApp extends StatelessWidget {
  
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return ProviderScope(
      child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            // Locale('en', 'US'),
            Locale('es', 'ES'),
          ],
          locale: const Locale('es'),
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          theme: AppThemeCustom()
              .getTheme(mode: ThemeMode.light, context: context),
          onGenerateRoute: RouterApp.generateRoute),
    );
  }
}