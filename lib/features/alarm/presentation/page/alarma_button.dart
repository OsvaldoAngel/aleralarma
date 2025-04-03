import 'dart:math';
import 'package:aleralarma/common/theme/app_theme.dart';
import 'package:aleralarma/features/alarm/presentation/page/alarma_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DynamicAlarmButton extends ConsumerStatefulWidget {
  const DynamicAlarmButton({Key? key}) : super(key: key);

  @override
  ConsumerState<DynamicAlarmButton> createState() => _DynamicAlarmButtonState();
}

class _DynamicAlarmButtonState extends ConsumerState<DynamicAlarmButton> 
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Escuchar cambios de la animación para actualizar el estado en el provider
    _animationController.addListener(() {
      try {
        ref.read(alarmControllerProvider.notifier).updateAnimationProgress(
          _animationController.value
        );
      } catch (e) {
        print('Error updating animation progress: $e');
      }
    });

    // Manejar la finalización de la animación
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        ref.read(alarmControllerProvider.notifier).completeAnimation();
        _animationController.reset();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos el estado actual de la alarma
    final alarmState = ref.watch(alarmControllerProvider);
    
    // Controlar el estado de la animación según el provider
    if (alarmState.isAnimating && !_animationController.isAnimating) {
      _animationController.forward();
    } else if (!alarmState.isAnimating && _animationController.isAnimating) {
      _animationController.reset();
    }
    
    // Definimos gradientes según el estado usando AppTheme
    final LinearGradient gradientColors = alarmState.status == AlarmStatus.secure 
        ? AppTheme.secureGradient
        : AppTheme.panicGradient;
    
    final Color shadowColor = alarmState.status == AlarmStatus.secure
        ? AppTheme.secureColor
        : AppTheme.panicColor;
    
    // Texto a mostrar en el botón
    final String mainText = alarmState.status == AlarmStatus.secure
        ? 'ACTIVAR ALARMA'
        : 'DESACTIVAR ALARMA';
    
    final String subText = alarmState.isAnimating
        ? 'Mantén presionado para ${alarmState.status == AlarmStatus.secure ? 'activar' : 'desactivar'}...'
        : 'Mantén presionado para ${alarmState.status == AlarmStatus.secure ? 'activar' : 'desactivar'}';

    return GestureDetector(
      onLongPress: () {
        ref.read(alarmControllerProvider.notifier).startAnimation();
      },
      onLongPressUp: () {
        ref.read(alarmControllerProvider.notifier).cancelAnimation();
      },
      child: Container(
        width: double.infinity,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
        ),
        child: Stack(
          children: [
            // Fondo base
            Container(
              decoration: BoxDecoration(
                gradient: gradientColors,
                borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
            
            // Línea de progreso
            if (alarmState.isAnimating || alarmState.isCompleted)
              CustomPaint(
                painter: ProgressBorderPainter(
                  progress: alarmState.animationProgress,
                  borderColor: Colors.white,
                  borderWidth: 3.0,
                  cornerRadius: AppTheme.mediumRadius,
                  isDashed: false,
                ),
                child: Container(),
              ),
            
            // Flash de activación
            AnimatedOpacity(
              opacity: alarmState.isCompleted ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
                ),
              ),
            ),
            
            // Indicador de carga
            if (alarmState.isLoading)
              AppTheme.loadingIndicator(color: Colors.white, size: 30),
            
            // Contenido del botón
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingMedium),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppTheme.paddingSmall),
                        decoration: AppTheme.iconCircleDecoration,
                        child: Icon(
                          alarmState.status == AlarmStatus.secure
                              ? Icons.warning_amber_rounded
                              : Icons.notification_important,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppTheme.paddingMedium),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mainText,
                            style: AppTheme.alarmMainText,
                          ),
                          Text(
                            subText,
                            style: AppTheme.alarmSubText,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(AppTheme.paddingSmall),
                    decoration: AppTheme.iconCircleDecoration,
                    child: Icon(
                      alarmState.status == AlarmStatus.secure
                          ? Icons.arrow_forward_ios
                          : Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// CustomPainter para dibujar el borde de progreso
class ProgressBorderPainter extends CustomPainter {
  final double progress;
  final Color borderColor;
  final double borderWidth;
  final double cornerRadius;
  final bool isDashed;

  ProgressBorderPainter({
    required this.progress,
    required this.borderColor,
    required this.borderWidth,
    required this.cornerRadius,
    this.isDashed = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      borderWidth / 2,
      borderWidth / 2,
      size.width - borderWidth,
      size.height - borderWidth,
    );

    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(cornerRadius),
    );

    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;

    // Calcular el perímetro total del RRect
    final perimeter = 2 * (size.width + size.height) - 4 * cornerRadius + 2 * pi * cornerRadius;
    
    // Calcular la longitud a dibujar basada en el progreso
    final drawLength = perimeter * progress;
    
    Path path = Path();
    
    // Punto inicial (esquina superior izquierda)
    final double startX = cornerRadius;
    final double startY = 0;
    path.moveTo(startX, startY);
    
    // Variables para seguir la longitud dibujada
    double currentLength = 0;
    
    // Función para añadir un segmento al path
    void addSegment(Path path, double length, Function(Path, double) drawFunction) {
      if (currentLength + length <= drawLength) {
        // Dibujar todo el segmento
        drawFunction(path, length);
        currentLength += length;
      } else if (currentLength < drawLength) {
        // Dibujar solo parte del segmento
        double remainingLength = drawLength - currentLength;
        drawFunction(path, remainingLength);
        currentLength = drawLength; // Ya hemos dibujado todo lo que se necesita
      }
      // Si currentLength >= drawLength, no hacemos nada
    }

    // Lado superior
    addSegment(path, size.width - 2 * cornerRadius, (p, l) {
      p.relativeLineTo(l, 0);
    });

    // Esquina superior derecha
    addSegment(path, pi * cornerRadius / 2, (p, l) {
      double angle = l / cornerRadius;
      p.addArc(
        Rect.fromCircle(
          center: Offset(size.width - cornerRadius, cornerRadius),
          radius: cornerRadius,
        ),
        -pi / 2,
        angle,
      );
    });

    // Lado derecho
    addSegment(path, size.height - 2 * cornerRadius, (p, l) {
      p.relativeLineTo(0, l);
    });

    // Esquina inferior derecha
    addSegment(path, pi * cornerRadius / 2, (p, l) {
      double angle = l / cornerRadius;
      p.addArc(
        Rect.fromCircle(
          center: Offset(size.width - cornerRadius, size.height - cornerRadius),
          radius: cornerRadius,
        ),
        0,
        angle,
      );
    });

    // Lado inferior
    addSegment(path, size.width - 2 * cornerRadius, (p, l) {
      p.relativeLineTo(-l, 0);
    });

    // Esquina inferior izquierda
    addSegment(path, pi * cornerRadius / 2, (p, l) {
      double angle = l / cornerRadius;
      p.addArc(
        Rect.fromCircle(
          center: Offset(cornerRadius, size.height - cornerRadius),
          radius: cornerRadius,
        ),
        pi / 2,
        angle,
      );
    });

    // Lado izquierdo
    addSegment(path, size.height - 2 * cornerRadius, (p, l) {
      p.relativeLineTo(0, -l);
    });

    // Esquina superior izquierda
    addSegment(path, pi * cornerRadius / 2, (p, l) {
      double angle = l / cornerRadius;
      p.addArc(
        Rect.fromCircle(
          center: Offset(cornerRadius, cornerRadius),
          radius: cornerRadius,
        ),
        pi,
        angle,
      );
    });

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ProgressBorderPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.borderColor != borderColor ||
           oldDelegate.borderWidth != borderWidth ||
           oldDelegate.cornerRadius != cornerRadius ||
           oldDelegate.isDashed != isDashed;
  }
}