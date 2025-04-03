import 'package:flutter/material.dart';

class AppTheme {
  // Color principal (azul oscuro) - base del diseño
  static const primaryColor = Color(0xFF1F2937);
  
  // Color secundario (dorado) - destacados y acentos
  static const accentColor = Color(0xFFB8860B);
  
  // Color para elementos de alarma segura (verde)
  static const secureColor = Color(0xFF4CAF50);
  
  // Color para elementos de alarma de pánico (rojo)
  static const panicColor = Color(0xFFFF3B3B);
  
  // Color púrpura para chat y comunicaciones
  static const communicationColor = Color(0xFF6C63FF);
  
  // Colores básicos
  static const backgroundColor = Colors.white;
  static const cardColor = Colors.white;
  static const errorColor = Colors.red;
  static const disabledColor = Color(0xFFBDBDBD);
  
  // Colores para estados
  static const successColor = Color(0xFF4CAF50);
  static const warningColor = Color(0xFFFFC107);
  static const infoColor = Color(0xFF2196F3);
  
  // Colores para textos
  static const textPrimaryColor = Color(0xFF1F2937);
  static const textSecondaryColor = Color(0xFF6B7280);
  static const textLightColor = Colors.white;
  
  // Grises para fondos y separadores
  static final backgroundGrey = Color(0xFFF5F7FA);
  static final dividerColor = Color(0xFFE4E7EB);
  static final shadowColor = Colors.black.withOpacity(0.1);
  
  // Variables adicionales para AlarmPage
  static const appBarLogoColor = communicationColor;
  static const headerCardColor = Colors.white;
  static const activityItemColor = Colors.white;
  static const optionCardColor = Colors.white;
  static const floatingActionButtonColor = communicationColor;
  
  // Radios de borde
  static final smallRadius = 8.0;
  static final mediumRadius = 16.0;
  static final largeRadius = 24.0;
  static final circularRadius = 50.0;

  // Bordes especiales
  static final headerBottomRadius = BorderRadius.only(
    bottomLeft: Radius.circular(25),
    bottomRight: Radius.circular(25),
  );

  // Espaciados
  static const paddingSmall = 8.0;
  static const paddingMedium = 16.0;
  static const paddingLarge = 24.0;
  
  // Elevación
  static const elevationSmall = 2.0;
  static const elevationMedium = 4.0;
  static const elevationLarge = 8.0;
  
  // Sombras
  static final lightShadow = BoxShadow(
    color: Colors.black.withOpacity(0.05),
    blurRadius: 10,
    offset: const Offset(0, 2),
  );
  
  static final mediumShadow = BoxShadow(
    color: Colors.black.withOpacity(0.1),
    blurRadius: 10,
    offset: const Offset(0, 4),
  );
  
  // Decoración de tarjetas para opciones
  static BoxDecoration get optionCardDecoration => BoxDecoration(
    color: optionCardColor,
    borderRadius: BorderRadius.circular(mediumRadius),
    boxShadow: [lightShadow],
  );
  
  // Decoración para el encabezado
  static BoxDecoration get headerDecoration => BoxDecoration(
    color: headerCardColor,
    borderRadius: headerBottomRadius,
    boxShadow: [
      BoxShadow(
        color: Color(0x0D000000),
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ],
  );
  
  // Estilos de texto
  static TextStyle get headingLarge => const TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );

  static TextStyle get headingMedium => const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );

  static TextStyle get headingSmall => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );
  
  static TextStyle get sectionTitle => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Color(0xFF374151),
  );
  
  static TextStyle get statusText => TextStyle(
    fontSize: 14,
    color: textSecondaryColor,
    fontWeight: FontWeight.w500,
  );
  
  static TextStyle get optionCardTitle => TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: communicationColor,
  );
  
  static TextStyle get buttonText => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textLightColor,
  );
  
  static TextStyle get bodyLarge => const TextStyle(
    fontSize: 16,
    color: textPrimaryColor,
  );
  
  static TextStyle get bodyMedium => const TextStyle(
    fontSize: 14,
    color: textPrimaryColor,
  );
  
  static TextStyle get bodySmall => const TextStyle(
    fontSize: 12,
    color: textSecondaryColor,
  );
  
  // Estilos específicos
  static TextStyle get accentText => const TextStyle(
    color: accentColor,
    fontWeight: FontWeight.bold,
  );
  
  static TextStyle get alarmMainText => const TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
  
  static TextStyle get alarmSubText => const TextStyle(
    color: Colors.white,
    fontSize: 12,
  );
  
  // Decoraciones comunes
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(mediumRadius),
    boxShadow: [
      BoxShadow(
        color: shadowColor,
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );
  
  static BoxDecoration get iconCircleDecoration => BoxDecoration(
    color: Colors.white.withOpacity(0.2),
    shape: BoxShape.circle,
  );

  // Gradientes para estados de alarma
  static LinearGradient get secureGradient => const LinearGradient(
    colors: [secureColor, Color(0xFF66BB6A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient get panicGradient => const LinearGradient(
    colors: [panicColor, Color(0xFFFF5C5C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Tema principal de la aplicación
  static ThemeData get themeData => ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundGrey,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      tertiary: communicationColor,
      error: errorColor,
    ),
    
    // Barra de navegación
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundColor,
      foregroundColor: textPrimaryColor,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: textPrimaryColor,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
    
    // Botones elevados
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: accentColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    
    // Botones de texto
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: communicationColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    
    // Campos de texto
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: backgroundGrey,
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
      labelStyle: TextStyle(color: textSecondaryColor),
      hintStyle: TextStyle(color: textSecondaryColor.withOpacity(0.7)),
    ),
    
    // Tarjetas
    cardTheme: CardTheme(
      color: cardColor,
      elevation: elevationSmall,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(mediumRadius),
      ),
    ),
    
    // Divisores
    dividerTheme: DividerThemeData(
      color: dividerColor,
      thickness: 1,
      space: 1,
    ),
    
    // Iconos
    iconTheme: const IconThemeData(
      color: primaryColor,
      size: 24,
    ),
    
    // Floating Action Button
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: floatingActionButtonColor,
      foregroundColor: textLightColor,
    ),
    
    // Progreso Circular
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: communicationColor,
    ),
    
    // Switch
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return accentColor;
        }
        return null;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return accentColor.withOpacity(0.5);
        }
        return null;
      }),
    ),
    
    // TabBar
    tabBarTheme: const TabBarTheme(
      labelColor: accentColor,
      unselectedLabelColor: textSecondaryColor,
      indicatorColor: accentColor,
      labelStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
      unselectedLabelStyle: TextStyle(
        fontWeight: FontWeight.normal,
        fontSize: 14,
      ),
    ),
  );

  // Métodos para crear widgets comunes con el tema aplicado
  
  // Botón principal de la aplicación
  static Widget createPrimaryButton({
    required String text,
    required VoidCallback onPressed,
    bool isFullWidth = true,
    EdgeInsetsGeometry? padding,
    double? height,
  }) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height ?? 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: padding,
        ),
        child: Text(text),
      ),
    );
  }
  
  // Indicador de carga
  static Widget loadingIndicator({Color? color, double size = 40}) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(color ?? accentColor),
          strokeWidth: 3,
        ),
      ),
    );
  }
  
  // Campo de texto personalizado
  static Widget createTextField({
    required TextEditingController controller,
    String? labelText,
    String? hintText,
    bool obscureText = false,
    IconData? prefixIcon,
    Widget? suffix,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    String? Function(String?)? validator,
    Function(String)? onChanged,
    Function(String)? onSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffix: suffix,
      ),
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
    );
  }
  
  // Método específico para crear un indicador de estado (círculo coloreado)
  static Widget createStatusIndicator(bool isActive) {
    final Color statusColor = isActive ? secureColor : panicColor;
    
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: statusColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.4),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
  static Widget createOptionCard({
  required String title, 
  required IconData icon, 
  required Color color, 
  required VoidCallback onTap
}) {
  return Container(
    decoration: optionCardDecoration,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(mediumRadius),
        child: Padding(
          padding: const EdgeInsets.all(10), // Reducido de paddingMedium a 10
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(paddingSmall),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(height: 6), // Reducido de paddingSmall a 6
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12, // Reducido de 13 a 12
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}