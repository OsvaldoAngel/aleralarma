
import 'package:aleralarma/features/chat/data/models/chat_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

abstract class ChatRepository {
  void connectSocket();
  void disconnectSocket();
  void sendMessage(String message);
  Stream<ChatMessage> get messageStream;
}