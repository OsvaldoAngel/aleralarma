import 'package:aleralarma/common/settings/routes_names.dart';
import 'package:aleralarma/common/theme/app_theme.dart';
import 'package:aleralarma/features/alarm/presentation/page/alarma_button.dart';
import 'package:aleralarma/features/alarm/presentation/page/alarma_controller.dart';
import 'package:aleralarma/features/auth/presentation/page/login/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickalert/quickalert.dart';

class AlarmPage extends ConsumerStatefulWidget {
  const AlarmPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AlarmPage> createState() => _AlarmPageState();
}

class _AlarmPageState extends ConsumerState<AlarmPage> {
  @override
  void initState() {   
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Refrescar el estado de la alarma cuando se carga la página
      ref.read(alarmControllerProvider.notifier).refreshAlarmStatus();
    });
  }

  // Método para mostrar QuickAlert de confirmación de cierre de sesión
  void _showLogoutConfirmation() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'Cerrar Sesión',
      text: '¿Estás seguro de que deseas cerrar sesión?',
      confirmBtnText: 'Sí, cerrar sesión',
      cancelBtnText: 'Cancelar',
      confirmBtnColor: AppTheme.primaryColor,
      onConfirmBtnTap: () {
        Navigator.of(context).pop(); // Cerrar el diálogo
        _logout();
      },
    );
  }

  // Método para realizar el logout
  void _logout() {
    // Llamar al método logout del AuthNotifier
    ref.read(authProvider.notifier).logout();
    
    // Navegar a la pantalla de login
    Navigator.pushNamedAndRemoveUntil(
      context,
      RoutesNames.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Observamos el estado de la alarma para cambios
    final alarmState = ref.watch(alarmControllerProvider);
    
    // Calculamos el padding bottom para la barra de navegación
    final bottomPadding = MediaQuery.of(context).padding.bottom + 70;

    return Theme(
      data: AppTheme.themeData,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundGrey,
        appBar: _buildAppBar(),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildHeaderSection(alarmState),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildSectionTitle('Acciones de Emergencia'),
                    const SizedBox(height: 16),
                    // Usamos nuestro botón dinámico que cambia según el estado
                    const DynamicAlarmButton(),
                    const SizedBox(height: 16),
                    _buildSecurityOptions(),
                    const SizedBox(height: 24),
                    _buildActivityList(alarmState),
                    // Botón para cerrar sesión
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: _buildLogoutButton(),
                    ),
                    // Padding para la barra de navegación
                    SizedBox(height: bottomPadding),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Refrescar el estado de la alarma al pulsar el botón
            ref.read(alarmControllerProvider.notifier).refreshAlarmStatus();
          },
          backgroundColor: AppTheme.floatingActionButtonColor,
          elevation: AppTheme.elevationMedium,
          child: const Icon(Icons.refresh, color: Colors.white),
        ),
      ),
    );
  }

  // Nuevo método para el botón de cierre de sesión
  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _showLogoutConfirmation,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppTheme.primaryColor,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.smallRadius),
            side: BorderSide(color: AppTheme.dividerColor),
          ),
          elevation: 0,
        ),
        icon: Icon(Icons.logout),
        label: Text(
          'Cerrar Sesión',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.backgroundColor,
      elevation: 0,
      centerTitle: false,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.paddingSmall),
            decoration: BoxDecoration(
              color: AppTheme.appBarLogoColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.smallRadius),
            ),
            child: Icon(
              Icons.shield_outlined,
              color: AppTheme.appBarLogoColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'AlertaAlarma',
            style: AppTheme.headingMedium,
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.notifications_outlined, 
            color: AppTheme.textPrimaryColor
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(
            Icons.person_outlined, 
            color: AppTheme.textPrimaryColor
          ),
          onPressed: () {
            // Podríamos mostrar un perfil o menú de usuario aquí
            _showUserMenu();
          },
        ),
      ],
    );
  }

  // Método para mostrar el menú de usuario
  void _showUserMenu() {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: position,
      items: <PopupMenuEntry>[
        PopupMenuItem(
          child: ListTile(
            leading: Icon(Icons.person, color: AppTheme.primaryColor),
            title: Text('Mi Perfil'),
            contentPadding: EdgeInsets.zero,
          ),
          onTap: () {
            // Navegar al perfil
          },
        ),
        PopupMenuItem(
          child: ListTile(
            leading: Icon(Icons.settings, color: AppTheme.primaryColor),
            title: Text('Configuración'),
            contentPadding: EdgeInsets.zero,
          ),
          onTap: () {
            // Navegar a configuración
          },
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          child: ListTile(
            leading: Icon(Icons.logout, color: AppTheme.primaryColor),
            title: Text('Cerrar Sesión'),
            contentPadding: EdgeInsets.zero,
          ),
          onTap: () {
            // Pequeño retraso para que el menú se cierre antes de mostrar el diálogo
            Future.delayed(Duration(milliseconds: 100), () {
              _showLogoutConfirmation();
            });
          },
        ),
      ],
      elevation: 8.0,
    );
  }

  Widget _buildHeaderSection(AlarmState state) {
    // Color e icono basado en el estado de la alarma
    final Color statusColor = state.status == AlarmStatus.secure 
        ? AppTheme.secureColor 
        : AppTheme.panicColor;
    
    final IconData statusIcon = state.status == AlarmStatus.secure
        ? Icons.verified_outlined
        : Icons.warning_amber_rounded;
    
    final String statusText = state.statusText;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppTheme.paddingMedium, 
        AppTheme.paddingMedium, 
        AppTheme.paddingMedium, 
        30
      ),
      decoration: AppTheme.headerDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seguridad en Casa',
            style: AppTheme.headingLarge,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              AppTheme.createStatusIndicator(state.status == AlarmStatus.secure),
              const SizedBox(width: 8),
              Text(
                statusText,
                style: AppTheme.statusText,
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      statusIcon,
                      size: 14,
                      color: statusColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      state.isActive ? 'Activo' : 'Inactivo',
                      style: TextStyle(
                        fontSize: 12,
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (state.isLoading)
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTheme.sectionTitle,
          ),
          if (title == 'Actividad Reciente')
            TextButton(
              onPressed: () {},
              child: Text(
                'Ver Todo',
                style: TextStyle(
                  color: AppTheme.communicationColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSecurityOptions() {
    return SizedBox(
      height: 130, // Aumentado a 130 para evitar overflow
      child: Row(
        children: [
          Expanded(
            child: _buildOptionCard(
              'Chat Grupal',
              Icons.chat_bubble_outline,
              AppTheme.communicationColor,
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  RoutesNames.chat,
                  (route) => false,
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildOptionCard(
              'Contactos\nde Emergencia',
              Icons.contact_phone,
              AppTheme.successColor,
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  // Método modificado para crear tarjetas de opciones con menos padding
  Widget _buildOptionCard(String title, IconData icon, Color color, {required Function() onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
          child: Padding(
            padding: const EdgeInsets.all(10), // Reducido para evitar overflow
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
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
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12, // Tamaño reducido
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

  // Widget para la lista de actividad
  Widget _buildActivityList(AlarmState alarmState) {
    return SizedBox(
      height: 90, // Altura reducida para la lista
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildActivityItem(
            'Opciones de seguridad',
            'Administra tu cuenta',
            Icons.security,
            AppTheme.secureColor,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String time, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.smallRadius),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: AppTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}