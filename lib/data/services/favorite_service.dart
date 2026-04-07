import '../../core/network/api_client.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/error_handler.dart';
import '../models/listing.dart';

/// Service for managing favorite listings
class FavoriteService {
  final ApiClient _apiClient;

  FavoriteService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Get user's favorite listings
  Future<FavoriteResponse> getFavorites({
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.favorites,
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;

        // Handle different response structures safely
        List<dynamic> dataList = [];
        if (data is Map) {
          final dataListRaw = data['data'] ?? data['listings'] ?? data['items'];
          if (dataListRaw is List) {
            dataList = dataListRaw;
          } else if (dataListRaw is Map) {
            // Some APIs return data as a map with numeric keys
            dataList = dataListRaw.values.toList();
          }
        } else if (data is List) {
          dataList = data;
        }

        final listings = dataList
            .whereType<Map>()
            .map((json) => Listing.fromJson(json as Map<String, dynamic>))
            .toList();

        // Safely parse pagination fields
        int currentPage = _safeInt(data['current_page']) ?? page;
        int totalPages = _safeInt(data['last_page']) ?? 1;
        int total = _safeInt(data['total']) ?? 0;

        return FavoriteResponse(
          success: true,
          listings: listings,
          currentPage: currentPage,
          totalPages: totalPages,
          total: total,
        );
      }

      return FavoriteResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to fetch favorites',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return FavoriteResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Safely convert dynamic value to int
  int? _safeInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Add listing to favorites
  Future<FavoriteResponse> addFavorite(int listingId) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiConstants.addFavorite}/$listingId',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return FavoriteResponse(
          success: true,
          message: response.data['message'] ?? 'Added to favorites',
        );
      }

      return FavoriteResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to add favorite',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return FavoriteResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Remove listing from favorites
  Future<FavoriteResponse> removeFavorite(int listingId) async {
    try {
      final response = await _apiClient.dio.delete(
        '${ApiConstants.removeFavorite}/$listingId',
      );

      if (response.statusCode == 200) {
        return FavoriteResponse(
          success: true,
          message: response.data['message'] ?? 'Removed from favorites',
        );
      }

      return FavoriteResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to remove favorite',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return FavoriteResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Toggle favorite status
  Future<FavoriteResponse> toggleFavorite(int listingId) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiConstants.toggleFavorite}/$listingId/toggle',
      );

      if (response.statusCode == 200) {
        return FavoriteResponse(
          success: true,
          message: response.data['message'] ?? 'Favorite toggled',
          isFavorite: response.data['is_favorite'] ?? false,
        );
      }

      return FavoriteResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to toggle favorite',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return FavoriteResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }
}

/// Response wrapper for favorite operations
class FavoriteResponse {
  final bool success;
  final String message;
  final List<Listing> listings;
  final int? currentPage;
  final int? totalPages;
  final int? total;
  final bool? isFavorite;

  const FavoriteResponse({
    required this.success,
    this.message = '',
    this.listings = const [],
    this.currentPage,
    this.totalPages,
    this.total,
    this.isFavorite,
  });

  @override
  String toString() =>
      'FavoriteResponse(success: $success, listings: ${listings.length})';
}
