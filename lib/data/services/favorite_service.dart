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
        final listings = (data['data'] as List)
            .map((json) => Listing.fromJson(json))
            .toList();

        return FavoriteResponse(
          success: true,
          listings: listings,
          currentPage: data['current_page'] ?? page,
          totalPages: data['last_page'] ?? 1,
          total: data['total'] ?? 0,
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
