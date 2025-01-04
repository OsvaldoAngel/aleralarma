
// chat_repository_imp.dart
import 'package:aleralarma/common/constants/constants.dart';
import 'package:aleralarma/features/chat/data/models/chat_model.dart';
import 'package:aleralarma/features/chat/domain/repository/chat_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
class ChatRepositoryImp implements ChatRepository {
  final Ref ref;
  late IO.Socket socket;
  final _messageController = StreamController<ChatMessage>.broadcast();
  
  // IDs predeterminados
  final String defaultGroupId = 'df730895-3e20-41f4-ad06-88ee2616c7f6';
  final String defaultUserId = '157789e8-009d-4d75-a92d-00df11644245';

  ChatRepositoryImp(this.ref) {
    _initSocket();
  }

  void _initSocket() {
    socket = IO.io('https://5bsgwh36-3001.usw3.devtunnels.ms', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'reconnection': true,
    });

    socket.onConnect((_) {
      print('Conectado al socket');
      socket.emit('unirse_grupo', {
        'id_usuario': defaultUserId,
        'id_grupo': defaultGroupId,
      });
    });

    socket.on('recibir_mensaje', (data) {
      final message = ChatMessage.fromJson(data);
      _messageController.add(message);
    });

    socket.on('historial_mensajes', (data) {
      for (var msg in data) {
        final message = ChatMessage.fromJson(msg);
        _messageController.add(message);
      }
    });
  }

  @override
  void connectSocket() {
    if (!socket.connected) {
      socket.connect();
    }
  }

  @override
  void disconnectSocket() {
    socket.disconnect();
  }

  @override
  void sendMessage(String message) {
    socket.emit('enviar_mensaje', {
      'id_usuario': defaultUserId,
      'id_grupo': defaultGroupId,
      'mensaje': message,
    });
  }

  @override
  Stream<ChatMessage> get messageStream => _messageController.stream;
}
