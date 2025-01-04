import 'package:aleralarma/common/settings/routes_names.dart';
import 'package:aleralarma/features/auth/presentation/page/login/login_page.dart';
import 'package:aleralarma/features/auth/presentation/page/splashScreen/splashScreen.dart';
import 'package:aleralarma/features/chat/presentation/page/chat_page.dart';
import 'package:aleralarma/features/user/presentation/page/home_page/home_page.dart';
import 'package:flutter/material.dart';

class RouterApp {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutesNames.homePage:
        return MaterialPageRoute(
          builder: (_) => HomePage(),
        );
      case RoutesNames.splashScreen:
        return MaterialPageRoute(
          builder: (_) => SplashPage(),
        );
            case RoutesNames.login:
        return MaterialPageRoute(
          builder: (_) => LoginPage2(),
        );
      case RoutesNames.acceptTravelPage:
       
        return MaterialPageRoute(
          builder: (_) => ChatPage(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Ruta no encontrada: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
