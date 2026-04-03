import '../../core/network/api_client.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/error_handler.dart';
import '../models/notification.dart' as app;

/// Service for managing notifications
class NotificationService {
  final ApiClient _apiClient;

  NotificationService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Get user's notifications
  Future<NotificationResponse> getNotifications({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.notifications,
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final notifications = (data['data'] as List)
            .map((json) => app.Notification.fromJson(json))
            .toList();

        return NotificationResponse(
          success: true,
          notifications: notifications,
          currentPage: data['current_page'] ?? page,
          totalPages: data['last_page'] ?? 1,
          total: data['total'] ?? 0,
        );
      }

      return NotificationResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to fetch notifications',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return NotificationResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Get unread notification count
  Future<NotificationCountResponse> getUnreadCount() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.unreadCount);

      if (response.statusCode == 200) {
        return NotificationCountResponse(
          success: true,
          count: response.data['count'] ?? response.data['unread_count'] ?? 0,
        );
      }

      return const NotificationCountResponse(
        success: false,
        count: 0,
      );
    } catch (e) {
      return const NotificationCountResponse(success: false, count: 0);
    }
  }

  /// Mark notification as read
  Future<NotificationResponse> markAsRead(int notificationId) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.markAsRead}/$notificationId/read',
      );

      if (response.statusCode == 200) {
        return NotificationResponse(
          success: true,
          message: response.data['message'] ?? 'Marked as read',
        );
      }

      return NotificationResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to mark as read',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return NotificationResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Mark all notifications as read
  Future<NotificationResponse> markAllAsRead() async {
    try {
      final response = await _apiClient.dio.post(ApiConstants.markAllAsRead);

      if (response.statusCode == 200) {
        return NotificationResponse(
          success: true,
          message: response.data['message'] ?? 'All marked as read',
        );
      }

      return NotificationResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to mark all as read',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return NotificationResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Delete notification
  Future<NotificationResponse> deleteNotification(int notificationId) async {
    try {
      final response = await _apiClient.dio.delete(
        '${ApiConstants.deleteNotification}/$notificationId',
      );

      if (response.statusCode == 200) {
        return NotificationResponse(
          success: true,
          message: response.data['message'] ?? 'Notification deleted',
        );
      }

      return NotificationResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to delete notification',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return NotificationResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }
}

/// Response wrapper for notification operations
class NotificationResponse {
  final bool success;
  final String message;
  final List<app.Notification> notifications;
  final int? currentPage;
  final int? totalPages;
  final int? total;

  const NotificationResponse({
    required this.success,
    this.message = '',
    this.notifications = const [],
    this.currentPage,
    this.totalPages,
    this.total,
  });
}

/// Response wrapper for notification count
class NotificationCountResponse {
  final bool success;
  final int count;

  const NotificationCountResponse({
    required this.success,
    required this.count,
  });
}
