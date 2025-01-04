
// lib/features/chat/data/models/chat_message.dart
class ChatMessage {
  final String userId;
  final String message;
  final DateTime timestamp;

  ChatMessage({
    required this.userId,
    required this.message,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      userId: json['id_usuario'],
      message: json['mensaje'],
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}