import '../../core/network/api_client.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/error_handler.dart';
import '../models/address.dart';

/// Service for Ethiopian address hierarchy (cascading dropdowns)
class AddressService {
  final ApiClient _apiClient;

  AddressService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Get all regions
  /// API returns simple string array: ["Tigray", "Amhara", ...]
  Future<AddressResponse> getRegions() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.regions);

      if (response.statusCode == 200) {
        final data = response.data;
        final regionNames = (data is List) 
            ? data.whereType<String>().toList() 
            : <String>[];
        
        final regions = regionNames.map((name) => Address(region: name)).toList();
        return AddressResponse(success: true, regions: regions);
      }

      return AddressResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to fetch regions',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return AddressResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Get zones by region
  /// API returns simple string array: ["Centeral", "Eastern", ...]
  Future<AddressResponse> getZones({required String region}) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.zones,
        queryParameters: {'region': region},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final zoneNames = (data is List) 
            ? data.whereType<String>().toList() 
            : <String>[];
        
        final zones = zoneNames.map((name) => Address(zone: name)).toList();
        return AddressResponse(success: true, zones: zones);
      }

      return AddressResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to fetch zones',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return AddressResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Get woredas by region and zone
  /// API returns simple string array: ["01", "02", ...]
  Future<AddressResponse> getWoredas({
    required String region,
    required String zone,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.woredas,
        queryParameters: {
          'region': region,
          'zone': zone,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final woredaNames = (data is List) 
            ? data.whereType<String>().toList() 
            : <String>[];
        
        final woredas = woredaNames.map((name) => Address(woreda: name)).toList();
        return AddressResponse(success: true, woredas: woredas);
      }

      return AddressResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to fetch woredas',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return AddressResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Get kebeles by region, zone, and woreda
  /// API returns array of {id, kebele}: [{id: 1, kebele: "Kebele 01"}, ...]
  Future<AddressResponse> getKebeles({
    required String region,
    required String zone,
    required String woreda,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.kebeles,
        queryParameters: {
          'region': region,
          'zone': zone,
          'woreda': woreda,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final kebeles = (data is List)
            ? data
                .whereType<Map>()
                .map((m) => Address(
                      id: m['id'] as int?,
                      kebele: m['kebele'] as String?,
                    ))
                .where((a) => a.kebele != null && a.kebele!.isNotEmpty)
                .toList()
            : <Address>[];
        
        return AddressResponse(success: true, kebeles: kebeles);
      }

      return AddressResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to fetch kebeles',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return AddressResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Parse address list from response
  List<Address> _parseList(dynamic data) {
    if (data is List) {
      return data.map((json) => Address.fromJson(json)).toList();
    }
    return [];
  }
}

/// Response wrapper for address operations
class AddressResponse {
  final bool success;
  final String message;
  final List<Address> regions;
  final List<Address> zones;
  final List<Address> woredas;
  final List<Address> kebeles;

  const AddressResponse({
    required this.success,
    this.message = '',
    this.regions = const [],
    this.zones = const [],
    this.woredas = const [],
    this.kebeles = const [],
  });

  @override
  String toString() =>
      'AddressResponse(success: $success, regions: ${regions.length})';
}
