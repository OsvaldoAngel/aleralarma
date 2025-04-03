import 'package:aleralarma/common/settings/routes_names.dart';
import 'package:aleralarma/common/theme/app_theme.dart';
import 'package:aleralarma/features/alarm/presentation/page/alarma_button.dart';
import 'package:aleralarma/features/auth/data/provite/provite.dart' as authProvite;
import 'package:aleralarma/features/auth/presentation/page/login/login_controller.dart';
import 'package:aleralarma/features/chat/data/models/chat_model.dart';
import 'package:aleralarma/features/chat/presentation/page/controller_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // No necesitamos inicializar datos aquí, el controlador se encarga de todo
  }

  @override
  Widget build(BuildContext context) {
    // Observar todo el estado del chat
    final chatState = ref.watch(chatControllerProvider);
    
    // Extraer valores para mayor legibilidad
    final isLoading = chatState.isLoading;
    final isLoadingMessages = chatState.isLoadingMessages;
    final messages = chatState.messages;
    final currentUserId = chatState.currentUserId;
    final gruposData = chatState.gruposData;
    final currentGroupName = chatState.currentGroupName;
    
    // Automatizar el scroll cuando hay nuevos mensajes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && messages.isNotEmpty) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    return Theme(
      data: AppTheme.themeData,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: isLoading
            ? Center(child: AppTheme.loadingIndicator())
            : Column(
                children: [
                  _buildGroupInfo(gruposData, currentGroupName),
                  Expanded(
                    child: _buildMessageContent(messages, currentUserId, isLoadingMessages),
                  ),
                  _buildMessageInput(),
                ],
              ),
      ),
    );
  }

  Widget _buildMessageContent(List<ChatMessage> messages, String? currentUserId, bool isLoadingMessages) {
    if (isLoadingMessages) {
      // Muestra un indicador de carga de mensajes
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppTheme.loadingIndicator(
              color: AppTheme.communicationColor,
              size: 40,
            ),
            SizedBox(height: 16),
            Text(
              'Cargando mensajes...',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    } else if (messages.isEmpty) {
      // Muestra el estado vacío solo si no hay mensajes y no estamos cargando
      return _buildEmptyState();
    } else {
      // Muestra la lista de mensajes
      return _buildChatList(messages, currentUserId);
    }
  } 
  
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.primaryColor,
      elevation: 0,
      actions: [
        // Usar Flexible para manejar el espacio disponible
        Flexible(
          child: Align(
            alignment: Alignment.centerRight,
            child: DynamicAlarmButton(),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupInfo(gruposData, currentGroupName) {
    if (gruposData == null || gruposData.grupos.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundGrey,
        border: Border(bottom: BorderSide(color: AppTheme.dividerColor, width: 1)),
      ),
      child: Row(
        children: [
          // Botón de "Regresar" para volver a la página anterior
          IconButton(
            icon: Icon(Icons.arrow_back, color: AppTheme.communicationColor),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                RoutesNames.alarm,
                (route) => false,
              );
            },
          ),
          
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.communicationColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.location_on_outlined,
              color: AppTheme.communicationColor,
              size: 22,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chat grupal de seguridad',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  currentGroupName ?? 'Cargando...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
          if (gruposData.grupos.length > 1)
            PopupMenuButton<String>(
              icon: Icon(Icons.swap_horiz, color: AppTheme.communicationColor),
              tooltip: 'Cambiar grupo',
              onSelected: _handleGroupChange,
              itemBuilder: (context) => gruposData.grupos.map((grupo) {
                return PopupMenuItem<String>(
                  value: grupo.grupoId,
                  child: Row(
                    children: [
                      Icon(
                        grupo.grupoId == ref.read(chatControllerProvider).currentGroupId
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: AppTheme.communicationColor,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        grupo.grupoLugar.toUpperCase(),
                        style: TextStyle(
                          fontWeight: grupo.grupoId == ref.read(chatControllerProvider).currentGroupId
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // Método para manejar el cambio de grupo
  void _handleGroupChange(String groupId) {
    // Llamar al método del controlador para cambiar de grupo
    ref.read(chatControllerProvider.notifier).changeGroup(groupId);
  }

  Widget _buildChatList(List<ChatMessage> messages, String? currentUserId) {
    // Ordenar los mensajes por fecha para asegurar el orden cronológico correcto
    final sortedMessages = List<ChatMessage>.from(messages);
    sortedMessages.sort((a, b) {
      // Si alguna de las fechas es null, colocamos ese mensaje al final
      if (a.timestamp == null) return 1;
      if (b.timestamp == null) return -1;
      return a.timestamp!.compareTo(b.timestamp!);
    });

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: sortedMessages.length,
      itemBuilder: (context, index) {
        final message = sortedMessages[index];
        
        // Verificamos si es el primer mensaje o si es de un día diferente al mensaje anterior
        final isFirstMessage = index == 0;
        final isNewDay = !isFirstMessage ? 
            !_isSameDay(sortedMessages[index-1].timestamp, message.timestamp) : 
            true;
        
        // Verificamos si el mensaje es consecutivo del mismo usuario
        final isConsecutiveMessage = index > 0 &&
            sortedMessages[index - 1].userId == message.userId &&
            _isSameDay(sortedMessages[index - 1].timestamp, message.timestamp);

        return Column(
          children: [
            // Solo mostramos el separador de fecha si es un nuevo día
            if (isNewDay) _buildDateSeparator(message.timestamp),
            _buildMessage(message, !isConsecutiveMessage, currentUserId),
          ],
        );
      },
    );
  }

  // Separador de fecha para los mensajes
  Widget _buildDateSeparator(DateTime? timestamp) {
    if (timestamp == null) return SizedBox.shrink();

    final formattedDate = _formatDate(timestamp);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: AppTheme.dividerColor)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.backgroundGrey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                formattedDate,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ),
          ),
          Expanded(child: Divider(color: AppTheme.dividerColor)),
        ],
      ),
    );
  }

  // Estado vacío mejorado visualmente
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.communicationColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: AppTheme.communicationColor,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'No hay mensajes aún',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Sé el primero en enviar un mensaje a este grupo de seguridad',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondaryColor,
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              _messageController.text = '¡Hola a todos! 👋';
              FocusScope.of(context).requestFocus(FocusNode());
            },
            icon: Icon(Icons.waving_hand),
            label: Text('Iniciar conversación'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.communicationColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Burbujas de chat rediseñadas y mejoradas
  Widget _buildMessage(ChatMessage message, bool showUserInfo, String? currentUserId) {
    // Usamos el ID de usuario actual para determinar si el mensaje es mío
    final isMe = currentUserId != null && message.userId == currentUserId;

    return Padding(
      padding: EdgeInsets.only(
        top: showUserInfo ? 16 : 4,
        bottom: 4,
        left: isMe ? 60 : 0,
        right: isMe ? 0 : 60,
      ),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe && showUserInfo && message.username != null && message.username!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 48, bottom: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.username ?? 'Usuario',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isMe && showUserInfo) ...[
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.communicationColor.withOpacity(0.2),
                  child: Text(
                    _getInitials(message.username ?? 'U'),
                    style: TextStyle(
                      color: AppTheme.communicationColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? AppTheme.communicationColor : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: isMe ? Radius.circular(18) : showUserInfo ? Radius.circular(4) : Radius.circular(18),
                      topRight: isMe ? showUserInfo ? Radius.circular(4) : Radius.circular(18) : Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.shadowColor,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.message,
                        style: TextStyle(
                          color: isMe ? Colors.white : AppTheme.textPrimaryColor,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(message.timestamp),
                            style: TextStyle(
                              fontSize: 11,
                              color: isMe ? Colors.white.withOpacity(0.7) : AppTheme.textSecondaryColor,
                            ),
                          ),
                          if (isMe) ...[
                            SizedBox(width: 4),
                            Icon(
                              Icons.done_all,
                              size: 14,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Campo de entrada de mensajes rediseñado
  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: AppTheme.communicationColor),
            onPressed: () {
              // Mostrar opciones adicionales
              showModalBottomSheet(
                context: context,
                builder: (context) => _buildMessageOptions(),
              );
            },
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.backgroundGrey,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Escribe tu mensaje...',
                  hintStyle: TextStyle(color: AppTheme.textSecondaryColor),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                onSubmitted: _sendMessage,
              ),
            ),
          ),
          SizedBox(width: 8),
          InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () => _sendMessage(_messageController.text),
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.communicationColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Opciones adicionales para mensajes
  Widget _buildMessageOptions() {
    final options = [
      {
        'icon': Icons.camera_alt_outlined,
        'label': 'Foto',
        'color': Colors.blue,
      },
      {
        'icon': Icons.image_outlined,
        'label': 'Galería',
        'color': Colors.green,
      },
      {
        'icon': Icons.mic_outlined,
        'label': 'Audio',
        'color': Colors.orange,
      },
      {
        'icon': Icons.location_on_outlined,
        'label': 'Ubicación',
        'color': Colors.red,
      },
      {
        'icon': Icons.warning_amber_outlined,
        'label': 'Emergencia',
        'color': Colors.red,
      },
      {
        'icon': Icons.info_outline,
        'label': 'Reportar',
        'color': Colors.purple,
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              'Enviar contenido',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
          ),
          SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: options.length,
            itemBuilder: (context, index) {
              return _buildOptionItem(
                options[index]['icon'] as IconData,
                options[index]['label'] as String,
                options[index]['color'] as Color,
              );
            },
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  // Item individual para las opciones
  Widget _buildOptionItem(IconData icon, String label, Color color) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        // Futura implementación de acciones específicas
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }

  // Enviar un mensaje
  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    
    ref.read(chatControllerProvider.notifier).sendMessage(text);
    _messageController.clear();
    
    // Scroll al último mensaje
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Funciones de utilidad
  String _formatTime(DateTime? timestamp) {
    if (timestamp == null) return '';
    return DateFormat('HH:mm').format(timestamp);
  }

  String _formatDate(DateTime? timestamp) {
    if (timestamp == null) return '';
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    
    // Creamos una fecha que solo contiene año, mes y día (sin horas, minutos, etc.)
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDate == today) {
      return 'Hoy';
    } else if (messageDate == yesterday) {
      return 'Ayer';
    } else {
      // Para otras fechas, usamos el formato localizado
      // Asegúrate de que el locale 'es' esté disponible en tu aplicación
      return DateFormat('EEEE d MMMM', 'es').format(timestamp);
    }
  }

  bool _isSameDay(DateTime? date1, DateTime? date2) {
    if (date1 == null || date2 == null) return false;
    
    // Comparamos año, mes y día para determinar si es el mismo día
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    
    final parts = name.split(' ');
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    } else {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}