import 'dart:convert';

class ChatMessage {
  int id;
  final int userId;
  final int receiverId;
  final String message;
  final DateTime timestamp;
  bool isRead;

  ChatMessage({
    required this.id,
    required this.userId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });

  ChatMessage copyWith({
    int? id,
    int? userId,
    int? receiverId,
    String? message,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return ChatMessage(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        receiverId: receiverId ?? this.receiverId,
        message: message ?? this.message,
        timestamp: timestamp ?? this.timestamp,
        isRead: isRead ?? this.isRead);
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] as int? ?? 0,
      userId: map['userId'] as int? ?? 0,
      receiverId: map['receiverId'] as int? ?? 0,
      message: map['message'] as String? ?? '',
      timestamp: DateTime.parse(map['timestamp']),
      isRead: (map['isRead'] as int?) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead ? 1 : 0
    };
  }

  String toJson() => json.encode(toMap());

  factory ChatMessage.fromJson(String source) =>
      ChatMessage.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ChatMessage{id: $id, userId: $userId,receiverId : $receiverId, message: $message, timestamp: $timestamp}';
  }
}
