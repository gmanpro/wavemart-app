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

  // Additional fields for WhatsApp-like UI
  final String? otherParticipantFirstName;
  final String? otherParticipantLastName;
  final String? listingTitle;
  final bool isAssetChat;

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
    this.otherParticipantFirstName,
    this.otherParticipantLastName,
    this.listingTitle,
    this.isAssetChat = false,
  });

  factory Conversation.fromJson(Map<String, dynamic> json, {int? currentUserId}) {
    // Extract last message from nested relationships
    String? lastMsg;
    if (json['latest_message'] is Map) {
      lastMsg = json['latest_message']['body'] ?? json['latest_message']['message'];
    } else if (json['last_message'] != null) {
      lastMsg = json['last_message'];
    }

    // Get listing info
    String? listingTitle;
    bool isAssetChat = false;
    if (json['listing'] is Map) {
      final listing = json['listing'] as Map<String, dynamic>;
      listingTitle = listing['title'];
      isAssetChat = json['listing_id'] != null;
    }

    // Determine other participant
    String? otherFirstName, otherLastName;
    if (currentUserId != null) {
      if (json['sender'] is Map && json['sender']['id'] != currentUserId) {
        otherFirstName = json['sender']['first_name'];
        otherLastName = json['sender']['last_name'];
      } else if (json['receiver'] is Map && json['receiver']['id'] != currentUserId) {
        otherFirstName = json['receiver']['first_name'];
        otherLastName = json['receiver']['last_name'];
      }
    }

    // Handle both unread_count and total_unread_count field names
    int? unreadVal = _safeInt(json['unread_count']) ?? _safeInt(json['total_unread_count']);

    return Conversation(
      id: _safeInt(json['id']) ?? 0,
      senderId: _safeInt(json['sender_id']) ?? 0,
      receiverId: _safeInt(json['receiver_id']) ?? 0,
      listingId: _safeInt(json['listing_id']),
      type: json['type'],
      subject: listingTitle ?? json['subject'],
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
      otherParticipantFirstName: otherFirstName,
      otherParticipantLastName: otherLastName,
      listingTitle: listingTitle,
      isAssetChat: isAssetChat,
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
    // Use other participant's name if available
    if (otherParticipantFirstName != null) {
      final full = [otherParticipantFirstName, otherParticipantLastName].where((e) => e != null && e.isNotEmpty).join(' ');
      if (full.isNotEmpty) return full;
    }
    if (subject != null && subject!.isNotEmpty) return subject!;
    if (listingTitle != null && listingTitle!.isNotEmpty) return listingTitle!;
    return 'Conversation #$id';
  }

  String get otherParticipantInitials {
    final first = otherParticipantFirstName ?? '';
    final last = otherParticipantLastName ?? '';
    if (first.isNotEmpty && last.isNotEmpty) {
      return '${first[0]}${last[0]}'.toUpperCase();
    }
    if (first.isNotEmpty) return first.substring(0, first.length > 1 ? 2 : 1).toUpperCase();
    return '??';
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

  // Sender info for WhatsApp-like avatars
  final String? senderFirstName;
  final String? senderLastName;

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
    this.senderFirstName,
    this.senderLastName,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    String? firstName, lastName;
    if (json['sender'] is Map) {
      firstName = json['sender']['first_name'];
      lastName = json['sender']['last_name'];
    }

    return Message(
      id: _safeInt(json['id']) ?? 0,
      conversationId: _safeInt(json['conversation_id']) ?? 0,
      senderId: _safeInt(json['sender_id']) ?? 0,
      body: json['body'] ?? json['message'] ?? '',
      isRead: json['is_read'] ?? false,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      attachmentUrl: json['attachment_url'],
      attachmentType: json['attachment_type'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      senderFirstName: firstName,
      senderLastName: lastName,
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

  String get displayTime {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  String get senderInitials {
    final first = senderFirstName ?? '';
    final last = senderLastName ?? '';
    if (first.isNotEmpty && last.isNotEmpty) {
      return '${first[0]}${last[0]}'.toUpperCase();
    }
    if (first.isNotEmpty) return first.substring(0, first.length > 1 ? 2 : 1).toUpperCase();
    return '??';
  }
}
