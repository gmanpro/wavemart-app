import '../../core/network/api_client.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/error_handler.dart';
import '../models/listing.dart';

/// Service for managing property listings
class ListingService {
  final ApiClient _apiClient;

  ListingService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Get all active listings with optional filters
  ///
  /// Supports query params: type, listing_type, location, price_min, price_max, etc.
  Future<ListingResponse> getListings({
    int page = 1,
    int perPage = 15,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'per_page': perPage,
        if (filters != null) ...filters,
      };

      final response = await _apiClient.dio.get(
        ApiConstants.listings,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final listings = (response.data['data'] as List)
            .map((json) => Listing.fromJson(json))
            .toList();

        return ListingResponse(
          success: true,
          listings: listings,
          currentPage: response.data['current_page'] ?? page,
          totalPages: response.data['last_page'] ?? 1,
          total: response.data['total'] ?? 0,
        );
      }

      return ListingResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to fetch listings',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ListingResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Get featured listings only
  Future<ListingResponse> getFeaturedListings({
    int page = 1,
    int perPage = 12,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.featuredListings,
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

        return ListingResponse(
          success: true,
          listings: listings,
          currentPage: data['current_page'] ?? page,
          totalPages: data['last_page'] ?? 1,
          total: data['total'] ?? 0,
        );
      }

      return ListingResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to fetch featured listings',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ListingResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Get single listing details
  Future<ListingDetailResponse> getListingDetail(int listingId) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.listingDetail}/$listingId',
      );

      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data['data'] ?? response.data;
        final listing = Listing.fromJson(data);
        return ListingDetailResponse(success: true, listing: listing);
      }

      if (response.statusCode == 401) {
        return ListingDetailResponse(
          success: false,
          message: 'Please log in to view property details.',
        );
      }

      final message = response.data is Map
          ? (response.data['message'] ?? 'Listing not found')
          : 'Server returned an unexpected response.';
      return ListingDetailResponse(
        success: false,
        message: message,
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ListingDetailResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Get similar listings
  Future<ListingResponse> getSimilarListings(int listingId) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.similarListings}/$listingId/similar',
      );

      if (response.statusCode == 200) {
        final listings = (response.data['data'] as List)
            .map((json) => Listing.fromJson(json))
            .toList();

        return ListingResponse(success: true, listings: listings);
      }

      return ListingResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to fetch similar listings',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ListingResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Create a new listing
  Future<ListingResponse> createListing({
    required Map<String, dynamic> listingData,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.createListing,
        data: listingData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ListingResponse(
          success: true,
          message: 'Listing created successfully',
        );
      }

      return ListingResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to create listing',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ListingResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Update an existing listing
  Future<ListingResponse> updateListing({
    required int listingId,
    required Map<String, dynamic> listingData,
  }) async {
    try {
      final response = await _apiClient.dio.put(
        '${ApiConstants.updateListing}/$listingId',
        data: listingData,
      );

      if (response.statusCode == 200) {
        return ListingResponse(
          success: true,
          message: 'Listing updated successfully',
        );
      }

      return ListingResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to update listing',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ListingResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Delete a listing
  Future<ListingResponse> deleteListing(int listingId) async {
    try {
      final response = await _apiClient.dio.delete(
        '${ApiConstants.deleteListing}/$listingId',
      );

      if (response.statusCode == 200) {
        return ListingResponse(
          success: true,
          message: 'Listing deleted successfully',
        );
      }

      return ListingResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to delete listing',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ListingResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Make listing featured
  Future<ListingResponse> featureListing(int listingId) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiConstants.featureListing}/$listingId/feature',
      );

      if (response.statusCode == 200) {
        return ListingResponse(
          success: true,
          message: 'Listing featured successfully',
        );
      }

      return ListingResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to feature listing',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ListingResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }
}

/// Response wrapper for listing operations
class ListingResponse {
  final bool success;
  final String message;
  final List<Listing> listings;
  final int? currentPage;
  final int? totalPages;
  final int? total;

  const ListingResponse({
    required this.success,
    this.message = '',
    this.listings = const [],
    this.currentPage,
    this.totalPages,
    this.total,
  });

  @override
  String toString() =>
      'ListingResponse(success: $success, listings: ${listings.length})';
}

/// Response wrapper for single listing detail
class ListingDetailResponse {
  final bool success;
  final String message;
  final Listing? listing;

  const ListingDetailResponse({
    required this.success,
    this.message = '',
    this.listing,
  });
}
