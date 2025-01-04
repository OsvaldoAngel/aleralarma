import 'dart:async';

import 'package:aleralarma/common/constants/constants.dart';
import 'package:aleralarma/features/chat/data/models/chat_model.dart';
import 'package:aleralarma/features/chat/data/repositories/chat_repository_imp.dart';

// lib/features/chat/data/providers/chat_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aleralarma/features/chat/domain/repository/chat_repository.dart';

// Provider para el repositorio
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImp(ref);
});

// Provider para el controlador
final chatControllerProvider = StateNotifierProvider<ChatController, List<ChatMessage>>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return ChatController(repository, ref);
});

// Controlador
class ChatController extends StateNotifier<List<ChatMessage>> {
  final ChatRepository _repository;
  final Ref _ref;
  StreamSubscription? _messageSubscription;

  ChatController(this._repository, this._ref) : super([]) {
    _init();
  }

  void _init() {
    _repository.connectSocket();
    _messageSubscription = _repository.messageStream.listen((message) {
      state = [...state, message];
    });
  }

  void sendMessage(String message) {
    _repository.sendMessage(message);
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _repository.disconnectSocket();
    super.dispose();
  }
}
