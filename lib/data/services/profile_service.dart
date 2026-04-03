import '../../core/network/api_client.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/error_handler.dart';
import '../models/user.dart';

/// Service for user profile management
class ProfileService {
  final ApiClient _apiClient;

  ProfileService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Get current user profile
  Future<ProfileResponse> getProfile() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.profile);

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final user = User.fromJson(data);
        final stats = response.data['stats'];

        return ProfileResponse(
          success: true,
          user: user,
          stats: stats != null ? ProfileStats.fromJson(stats) : null,
        );
      }

      return ProfileResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to fetch profile',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ProfileResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Update user profile
  Future<ProfileResponse> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await _apiClient.dio.patch(
        ApiConstants.updateProfile,
        data: profileData,
      );

      if (response.statusCode == 200) {
        final user = response.data['data'] != null
            ? User.fromJson(response.data['data'])
            : null;

        return ProfileResponse(
          success: true,
          message: response.data['message'] ?? 'Profile updated successfully',
          user: user,
        );
      }

      return ProfileResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to update profile',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ProfileResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Delete user account
  Future<ProfileResponse> deleteAccount() async {
    try {
      final response = await _apiClient.dio.delete(ApiConstants.deleteProfile);

      if (response.statusCode == 200) {
        return ProfileResponse(
          success: true,
          message: response.data['message'] ?? 'Account deleted successfully',
        );
      }

      return ProfileResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to delete account',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ProfileResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Get public user profile
  Future<ProfileResponse> getPublicProfile(int userId) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.publicProfile}/$userId',
      );

      if (response.statusCode == 200) {
        final user = User.fromJson(response.data['data'] ?? response.data);
        return ProfileResponse(success: true, user: user);
      }

      return ProfileResponse(
        success: false,
        message: response.data['message'] ?? 'User not found',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ProfileResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }
}

/// Response wrapper for profile operations
class ProfileResponse {
  final bool success;
  final String message;
  final User? user;
  final ProfileStats? stats;

  const ProfileResponse({
    required this.success,
    this.message = '',
    this.user,
    this.stats,
  });
}

/// User profile statistics
class ProfileStats {
  final int totalListings;
  final int totalFavorites;
  final int unreadMessages;

  const ProfileStats({
    this.totalListings = 0,
    this.totalFavorites = 0,
    this.unreadMessages = 0,
  });

  factory ProfileStats.fromJson(Map<String, dynamic> json) {
    return ProfileStats(
      totalListings: json['total_listings'] ?? 0,
      totalFavorites: json['total_favorites'] ?? 0,
      unreadMessages: json['unread_messages'] ?? 0,
    );
  }
}
