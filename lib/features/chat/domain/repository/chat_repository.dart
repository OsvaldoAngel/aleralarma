import 'package:aleralarma/features/chat/data/models/chat_model.dart';

abstract class ChatRepository {
  // Métodos para comunicarse con el socket
  Future<void> connectSocket();
  void disconnectSocket();
  void sendMessage(String message);
  Stream<ChatMessage> get messageStream;
  
  // Métodos para actualizar configuración
  void updateUserId(String newUserId);
  void updateGroupId(String newGroupId);
  
  // Limpieza de recursos
  void dispose();
}