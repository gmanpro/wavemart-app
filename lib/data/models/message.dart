/// Conversation Model
class Conversation {
  final int id;
  final int senderId;
  final int receiverId;
  final int? listingId;
  final String? type;
  final String? subject;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int? unreadCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Conversation({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.listingId,
    this.type,
    this.subject,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount,
    required this.createdAt,
    this.updatedAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: _safeInt(json['id']) ?? 0,
      senderId: _safeInt(json['sender_id']) ?? 0,
      receiverId: _safeInt(json['receiver_id']) ?? 0,
      listingId: _safeInt(json['listing_id']),
      type: json['type'],
      subject: json['subject'],
      lastMessage: json['last_message'],
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'])
          : null,
      unreadCount: _safeInt(json['unread_count']),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  /// Safely convert dynamic value to int
  static int? _safeInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    if (value is bool) return value ? 1 : 0;
    return null;
  }

  String get displayTitle {
    if (subject != null && subject!.isNotEmpty) return subject!;
    if (listingId != null) return 'Listing #$listingId';
    return 'Conversation #$id';
  }

  String get previewText {
    if (lastMessage != null && lastMessage!.isNotEmpty) {
      return lastMessage!;
    }
    return 'No messages yet';
  }
}

/// Message Model
class Message {
  final int id;
  final int conversationId;
  final int senderId;
  final String body;
  final bool isRead;
  final DateTime? readAt;
  final String? attachmentUrl;
  final String? attachmentType;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.body,
    this.isRead = false,
    this.readAt,
    this.attachmentUrl,
    this.attachmentType,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? 0,
      conversationId: json['conversation_id'] ?? 0,
      senderId: json['sender_id'] ?? 0,
      body: json['body'] ?? '',
      isRead: json['is_read'] ?? false,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      attachmentUrl: json['attachment_url'],
      attachmentType: json['attachment_type'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  String get displayTime {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }
}
