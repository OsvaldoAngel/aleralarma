import 'package:aleralarma/common/theme/app_theme.dart';
import 'package:aleralarma/features/auth/presentation/page/login/login_controller.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class TopShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 50);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 30);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint =
        Offset(size.width - (size.width / 4), size.height - 80);
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class BottomShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(0, 40);

    var firstControlPoint = Offset(size.width / 4, 0);
    var firstEndPoint = Offset(size.width / 2, 30);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint = Offset(size.width - (size.width / 4), 80);
    var secondEndPoint = Offset(size.width, 20);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class LoginPage2 extends ConsumerWidget {
  const LoginPage2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Theme(
      data: AppTheme.themeData,
      child: Scaffold(
        body: Stack(
          children: [
            // Curva superior
            FadeInDown(
              duration: const Duration(milliseconds: 1200),
              child: ClipPath(
                clipper: TopShapeClipper(),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.primaryColor,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            ),

            // Curva inferior
            Positioned(
              bottom: -MediaQuery.of(context).size.height * 0.1,
              left: 0,
              right: 0,
              child: FadeInUp(
                duration: const Duration(milliseconds: 1200),
                child: ClipPath(
                  clipper: BottomShapeClipper(),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.primaryColor,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Contenido principal
            SafeArea(
              child: Column(
                children: [
                  // Header animado
                  FadeInDown(
                    duration: const Duration(milliseconds: 1000),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                         
                          Expanded(
                            child: Center(
                              child: Text(
                                'LOGIN',
                                style: TextStyle(
                                  color: AppTheme.accentColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                  ),

                  // Contenido del formulario centrado
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: FadeIn(
                          duration: const Duration(milliseconds: 1500),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.all(20),
                            width: double.infinity,
                            constraints: const BoxConstraints(
                              maxWidth: 400,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Logo con bounce
                                BounceInDown(
                                  duration: const Duration(milliseconds: 1500),
                                  child: Image.asset(
                                    'assets/img/icono-escudo.png',
                                    width: 120,
                                    height: 120,
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Texto de bienvenida con fade
                                FadeInLeft(
                                  duration: const Duration(milliseconds: 1000),
                                  child: Text(
                                    'Bienvenido',
                                    style: TextStyle(
                                      color: AppTheme.communicationColor,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Campo de usuario con fade
                                FadeInLeft(
                                  delay: const Duration(milliseconds: 200),
                                  duration: const Duration(milliseconds: 1000),
                                  child: AppTheme.createTextField(
                                    controller: authState.emailController,
                                    labelText: 'Usuario',
                                    prefixIcon: Icons.person,
                                    textInputAction: TextInputAction.next,
                                  ),
                                ),

                                const SizedBox(height: 15),

                                // Campo de contraseña con fade
                                FadeInLeft(
                                  delay: const Duration(milliseconds: 400),
                                  duration: const Duration(milliseconds: 1000),
                                  child: AppTheme.createTextField(
                                    controller: authState.passwordController,
                                    labelText: 'Contraseña',
                                    prefixIcon: Icons.lock,
                                    obscureText: true,
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: (_) {
                                      ref.read(authProvider.notifier).login(context);
                                    },
                                  ),
                                ),

                                const SizedBox(height: 30),

                                // Botón con bounce
                                BounceInUp(
                                  delay: const Duration(milliseconds: 600),
                                  duration: const Duration(milliseconds: 1000),
                                  child: AppTheme.createPrimaryButton(
                                    text: 'Login',
                                    onPressed: () {
                                      ref.read(authProvider.notifier).login(context);
                                    },
                                    height: 50,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Overlay de carga
            if (authState.isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: SpinKitFadingCube(
                    color: AppTheme.accentColor,
                    size: 50.0,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}