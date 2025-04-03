import 'package:aleralarma/features/chat/data/datasources/chat_remote.dart';
import 'package:aleralarma/features/chat/data/models/chat_model.dart';
import 'package:aleralarma/features/chat/domain/repository/chat_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatRepositoryImp implements ChatRepository {
  final Ref ref;
  late final SocketService _socketService;
  
  ChatRepositoryImp(this.ref) {
    _socketService = SocketService();
  }

  @override
  Future<void> connectSocket() async {
    await _socketService.connect();
  }

  @override
  void disconnectSocket() {
    _socketService.disconnect();
  }

  @override
  void sendMessage(String message) {
    _socketService.emitMessage(message);
  }

  @override
  Stream<ChatMessage> get messageStream => _socketService.messageStream;
  
  @override
  void updateUserId(String newUserId) {
    _socketService.updateUserId(newUserId);
  }
  
  @override
  void updateGroupId(String newGroupId) {
    _socketService.updateGroupId(newGroupId);
  }
  
  @override
  void dispose() {
    _socketService.dispose();
  }
}