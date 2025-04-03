
// splash_page.dart
import 'package:aleralarma/common/settings/routes_names.dart';
import 'package:aleralarma/features/auth/presentation/page/splashScreen/SplashController.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashPage extends ConsumerWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(splashControllerProvider, (previous, next) {
      next.when(
        data: (_) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            RoutesNames.alarm,
            (route) => false,
          );
        },
        error: (error, _) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            RoutesNames.login,
            (route) => false,
          );
        },
        loading: () {
          // Keep showing splash screen while loading
        },
      );
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tu logo o imagen de splash aquí
            Image.asset(
              'assets/img/icono-escudo.png',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}