// chat_repository.dart
import 'package:aleralarma/features/chat/data/datasources/chat_local_data_source.dart';
import 'package:aleralarma/features/chat/data/models/chat_model.dart';
import 'package:aleralarma/features/chat/domain/repository/chat_repository.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

// chat_repository_imp.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aleralarma/features/auth/presentation/page/login/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aleralarma/common/settings/routes_names.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatControllerProvider = StateNotifierProvider<ChatController, List<ChatMessage>>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return ChatController(repository, ref);
});

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
