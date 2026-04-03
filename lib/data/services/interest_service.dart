import '../../core/network/api_client.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/error_handler.dart';

/// Service for interest requests on listings
class InterestService {
  final ApiClient _apiClient;

  InterestService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Get user's interest requests
  Future<InterestResponse> getMyInterests({
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.myInterests,
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final interests = (data['data'] as List)
            .map((json) => InterestRequest.fromJson(json))
            .toList();

        return InterestResponse(
          success: true,
          interests: interests,
          currentPage: data['current_page'] ?? page,
          totalPages: data['last_page'] ?? 1,
          total: data['total'] ?? 0,
        );
      }

      return InterestResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to fetch interests',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return InterestResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Express interest in a listing
  Future<InterestResponse> expressInterest({
    required int listingId,
    String? message,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiConstants.expressInterest}/$listingId/interest',
        data: {
          if (message != null && message.isNotEmpty) 'message': message,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final interest = response.data['data'] != null
            ? InterestRequest.fromJson(response.data['data'])
            : null;

        return InterestResponse(
          success: true,
          message: response.data['message'] ?? 'Interest expressed',
          interest: interest,
        );
      }

      return InterestResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to express interest',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return InterestResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Cancel interest request
  Future<InterestResponse> cancelInterest(int interestId) async {
    try {
      final response = await _apiClient.dio.delete(
        '${ApiConstants.cancelInterest}/$interestId',
      );

      if (response.statusCode == 200) {
        return InterestResponse(
          success: true,
          message: response.data['message'] ?? 'Interest cancelled',
        );
      }

      return InterestResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to cancel interest',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return InterestResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }
}

/// Response wrapper for interest operations
class InterestResponse {
  final bool success;
  final String message;
  final List<InterestRequest> interests;
  final InterestRequest? interest;
  final int? currentPage;
  final int? totalPages;
  final int? total;

  const InterestResponse({
    required this.success,
    this.message = '',
    this.interests = const [],
    this.interest,
    this.currentPage,
    this.totalPages,
    this.total,
  });
}

/// Interest Request model
class InterestRequest {
  final int id;
  final int listingId;
  final int userId;
  final String status;
  final String? message;
  final String? responseMessage;
  final String? createdAt;

  const InterestRequest({
    required this.id,
    required this.listingId,
    required this.userId,
    required this.status,
    this.message,
    this.responseMessage,
    this.createdAt,
  });

  factory InterestRequest.fromJson(Map<String, dynamic> json) {
    return InterestRequest(
      id: json['id'] ?? 0,
      listingId: json['listing_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      status: json['status'] ?? 'pending',
      message: json['message'],
      responseMessage: json['response_message'],
      createdAt: json['created_at'],
    );
  }

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';
}
