class ChatMessage {
  final String userId;
  final String? username;
  final String message;
  final DateTime? timestamp;
  final String? groupId; // Agregamos groupId para soportar los grupos
  
  ChatMessage({
    required this.userId,
    this.username,
    required this.message,
    this.timestamp,
    this.groupId, // Parámetro opcional para el ID del grupo
  });
  
  // Constructor de copia para actualizar campos específicos
  ChatMessage copyWith({
    String? userId,
    String? username,
    String? message,
    DateTime? timestamp,
    String? groupId,
  }) {
    return ChatMessage(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      groupId: groupId ?? this.groupId,
    );
  }
  
  // Método factory para crear desde un mapa (JSON)
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      userId: json['userId'] ?? json['id_usuario'] ?? 'unknown',
      username: json['nombre_usuario'],
      message: json['message'] ?? json['mensaje'] ?? '',
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
      groupId: json['groupId'] ?? json['id_grupo'],
    );
  }
  
  // Convertir a mapa (JSON)
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'nombre_usuario': username,
      'message': message,
      'timestamp': timestamp?.toIso8601String(),
      'groupId': groupId,
    };
  }
  
  // Convertir al formato específico del socket
  Map<String, dynamic> toSocketJson() {
    return {
      'id_usuario': userId,
      'mensaje': message,
      'id_grupo': groupId,
    };
  }
  
  @override
  String toString() {
    return 'ChatMessage(userId: $userId, username: $username, message: $message, timestamp: $timestamp, groupId: $groupId)';
  }
}