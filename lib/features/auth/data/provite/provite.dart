import 'dart:async';

import 'package:aleralarma/features/auth/data/provite/provite.dart';
import 'package:aleralarma/features/auth/presentation/page/login/login_controller.dart';
import 'package:aleralarma/features/chat/data/models/chat_model.dart';
import 'package:aleralarma/features/chat/data/repositories/chat_repository_imp.dart';
import 'package:aleralarma/features/chat/domain/repository/chat_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Provider para el repositorio
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImp(ref);
});

// Provider para el controlador
final chatControllerProvider = StateNotifierProvider<ChatController, List<ChatMessage>>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return ChatController(repository, ref);
});

class ChatController extends StateNotifier<List<ChatMessage>> {
  final ChatRepository _repository;
  final Ref _ref;
  StreamSubscription? _messageSubscription;
  bool _isInitialized = false;
  
  // Set para rastrear mensajes ya recibidos y evitar duplicados
  final Set<String> _processedMessageIds = {};
  
  // Grupo actual
  String? _currentGroupId;

  ChatController(this._repository, this._ref) : super([]) {
    _init();
  }

  Future<void> _init() async {
    if (_isInitialized) return;
    
    try {
      await _repository.connectSocket();
      
      // Cancelar cualquier suscripción previa para evitar duplicados
      _messageSubscription?.cancel();
      
      _messageSubscription = _repository.messageStream.listen(_handleNewMessage);
      
      print('ChatController inicializado correctamente');
      _isInitialized = true;
    } catch (e) {
      print('Error al inicializar ChatController: $e');
    }
  }
  
  void _handleNewMessage(ChatMessage message) {
    // Verificar si el mensaje tiene contenido
    if (message.message.isEmpty) {
      print('Mensaje recibido vacío, ignorando');
      return;
    }
    
    // Generar un ID único para el mensaje basado en su contenido y remitente
    final messageId = '${message.userId}-${message.message}-${message.timestamp?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch}';
    
    // Verificar si ya procesamos este mensaje
    if (_processedMessageIds.contains(messageId)) {
      print('Mensaje duplicado ignorado: $messageId');
      return;
    }
    
    print('Nuevo mensaje recibido: ${message.message} de ${message.username}');
    
    // Añadimos timestamp si no existe
    final updatedMessage = message.timestamp == null
        ? message.copyWith(timestamp: DateTime.now())
        : message;
    
    // Registrar que hemos procesado este mensaje
    _processedMessageIds.add(messageId);
    
    // Limitar el tamaño del conjunto para evitar fugas de memoria
    if (_processedMessageIds.length > 100) {
      _processedMessageIds.remove(_processedMessageIds.first);
    }
    
    // Añadir el mensaje al estado
    state = [...state, updatedMessage];
  }

  void sendMessage(String message) {
    if (message.trim().isEmpty) return;
    
    try {
      // Obtenemos información del usuario actual para el mensaje
      final authState = _ref.read(authProvider);
      String? username;
      String userId = 'unknown_user';
      
      if (authState.userOrAdmin != null) {
        userId = authState.userOrAdmin!.uuid;
      }
      
      if (authState.persona != null) {
        username = '${authState.persona!.nombre} ${authState.persona!.primerApellido}';
      } else if (authState.userOrAdmin != null) {
        username = authState.persona!.primerApellido ?? 'Usuario';
      }
      
      print('Enviando mensaje como: $username (ID: $userId)');
      
      final newMessage = ChatMessage(
        userId: userId,
        username: username,
        message: message,
        timestamp: DateTime.now(),
      );
      
      // Añadir el mensaje al estado para mostrar inmediatamente
      state = [...state, newMessage];
      
      // Enviar el mensaje al servidor
      _repository.sendMessage(message);
    } catch (e) {
      print('Error al enviar mensaje: $e');
    }
  }
  
  void updateGroupId(String groupId) {
    if (_currentGroupId != groupId) {
      _currentGroupId = groupId;
      clearMessages();
      _repository.updateGroupId(groupId);
      print('Cambiado a grupo: $groupId');
    }
  }
  
  void clearMessages() {
    state = [];
    _processedMessageIds.clear();
    print('Mensajes limpiados');
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _repository.disconnectSocket();
    super.dispose();
  }
}