import '../../core/network/api_client.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/error_handler.dart';
import '../models/message.dart' as msg;

/// Service for messaging and conversations
class MessageService {
  final ApiClient _apiClient;

  MessageService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Get all conversations
  Future<ConversationResponse> getConversations({
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.messages,
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final conversations = (data['data'] as List)
            .map((json) => msg.Conversation.fromJson(json))
            .toList();

        return ConversationResponse(
          success: true,
          conversations: conversations,
          currentPage: data['current_page'] ?? page,
          totalPages: data['last_page'] ?? 1,
          total: data['total'] ?? 0,
        );
      }

      return ConversationResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to fetch conversations',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ConversationResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Get conversation messages
  Future<MessageResponse> getConversationMessages({
    required int conversationId,
    int page = 1,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.conversation}/$conversationId',
        queryParameters: {'page': page},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final messages = (data['data'] as List)
            .map((json) => msg.Message.fromJson(json))
            .toList();

        return MessageResponse(
          success: true,
          messages: messages,
          conversation: data['conversation'] != null
              ? msg.Conversation.fromJson(data['conversation'])
              : null,
        );
      }

      return MessageResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to fetch messages',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return MessageResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Send message in conversation
  Future<MessageResponse> sendMessage({
    required int conversationId,
    required String body,
    String? attachmentUrl,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiConstants.sendMessage}/$conversationId',
        data: {
          'body': body,
          if (attachmentUrl != null) 'attachment_url': attachmentUrl,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final message = response.data['data'] != null
            ? msg.Message.fromJson(response.data['data'])
            : null;

        return MessageResponse(
          success: true,
          message: 'Message sent',
          messageData: message,
        );
      }

      return MessageResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to send message',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return MessageResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Start conversation from listing
  Future<ConversationResponse> startConversationFromListing({
    required int listingId,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiConstants.startMessageFromListing}/$listingId/message',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final conversation = response.data['data'] != null
            ? msg.Conversation.fromJson(response.data['data'])
            : null;

        return ConversationResponse(
          success: true,
          conversation: conversation,
          message: 'Conversation started',
        );
      }

      return ConversationResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to start conversation',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ConversationResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Start direct conversation with user
  Future<ConversationResponse> startDirectConversation({
    required int userId,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiConstants.startDirectMessage}/$userId/message',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final conversation = response.data['data'] != null
            ? msg.Conversation.fromJson(response.data['data'])
            : null;

        return ConversationResponse(
          success: true,
          conversation: conversation,
          message: 'Conversation started',
        );
      }

      return ConversationResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to start conversation',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ConversationResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Delete conversation
  Future<ConversationResponse> deleteConversation(int conversationId) async {
    try {
      final response = await _apiClient.dio.delete(
        '${ApiConstants.deleteConversation}/$conversationId',
      );

      if (response.statusCode == 200) {
        return ConversationResponse(
          success: true,
          message: response.data['message'] ?? 'Conversation deleted',
        );
      }

      return ConversationResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to delete conversation',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ConversationResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Fetch new messages (for polling)
  Future<MessageResponse> fetchNewMessages({
    required int conversationId,
    DateTime? after,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (after != null) {
        queryParams['after'] = after.toIso8601String();
      }

      final response = await _apiClient.dio.get(
        '${ApiConstants.fetchMessages}/$conversationId/fetch',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final messages = (response.data['data'] as List)
            .map((json) => msg.Message.fromJson(json))
            .toList();

        return MessageResponse(
          success: true,
          messages: messages,
        );
      }

      return MessageResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to fetch messages',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return MessageResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }
}

/// Response wrapper for conversation operations
class ConversationResponse {
  final bool success;
  final String message;
  final List<msg.Conversation> conversations;
  final msg.Conversation? conversation;
  final int? currentPage;
  final int? totalPages;
  final int? total;

  const ConversationResponse({
    required this.success,
    this.message = '',
    this.conversations = const [],
    this.conversation,
    this.currentPage,
    this.totalPages,
    this.total,
  });
}

/// Response wrapper for message operations
class MessageResponse {
  final bool success;
  final String message;
  final List<msg.Message> messages;
  final msg.Message? messageData;
  final msg.Conversation? conversation;

  const MessageResponse({
    required this.success,
    this.message = '',
    this.messages = const [],
    this.messageData,
    this.conversation,
  });
}
