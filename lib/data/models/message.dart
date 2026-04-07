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
    // Extract sender/receiver info from nested relationships if available
    String? senderName;
    String? receiverName;
    if (json['sender'] is Map) {
      final sender = json['sender'] as Map<String, dynamic>;
      senderName = '${sender['first_name'] ?? ''} ${sender['last_name'] ?? ''}'.trim();
    }
    if (json['receiver'] is Map) {
      final receiver = json['receiver'] as Map<String, dynamic>;
      receiverName = '${receiver['first_name'] ?? ''} ${receiver['last_name'] ?? ''}'.trim();
    }

    // Get last message from latestMessage relationship
    String? lastMsg;
    if (json['latest_message'] is Map) {
      lastMsg = json['latest_message']['body'] ?? json['latest_message']['message'];
    } else if (json['last_message'] != null) {
      lastMsg = json['last_message'];
    }

    // Get subject from listing relationship
    String? subj;
    if (json['listing'] is Map) {
      final listing = json['listing'] as Map<String, dynamic>;
      subj = listing['title'] ?? (listing['property_type'] == 'house' ? 'House Listing' : 'Land Listing');
    }

    // Handle both unread_count and total_unread_count field names
    int? unreadVal = _safeInt(json['unread_count']);
    if (unreadVal == null) {
      unreadVal = _safeInt(json['total_unread_count']);
    }

    return Conversation(
      id: _safeInt(json['id']) ?? 0,
      senderId: _safeInt(json['sender_id']) ?? 0,
      receiverId: _safeInt(json['receiver_id']) ?? 0,
      listingId: _safeInt(json['listing_id']),
      type: json['type'],
      subject: subj ?? json['subject'],
      lastMessage: lastMsg,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'])
          : null,
      unreadCount: unreadVal,
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
