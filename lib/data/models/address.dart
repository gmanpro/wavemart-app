/// Address Model - Ethiopian hierarchical address system
class Address {
  final int? id;
  final String? region;
  final String? zone;
  final String? woreda;
  final String? kebele;
  final String? specificLocation;

  Address({
    this.id,
    this.region,
    this.zone,
    this.woreda,
    this.kebele,
    this.specificLocation,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      region: json['region'],
      zone: json['zone'],
      woreda: json['woreda'],
      kebele: json['kebele'],
      specificLocation: json['specific_location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'region': region,
      'zone': zone,
      'woreda': woreda,
      'kebele': kebele,
      'specific_location': specificLocation,
    };
  }

  String get fullAddress {
    final parts = [region, zone, woreda, kebele, specificLocation]
        .where((e) => e != null && e.isNotEmpty)
        .toList();
    return parts.join(', ');
  }

  String get shortAddress {
    final parts = [zone, kebele, specificLocation]
        .where((e) => e != null && e.isNotEmpty)
        .toList();
    return parts.join(', ');
  }

  @override
  String toString() => 'Address($fullAddress)';
}

/// Region model for cascading dropdowns
class Region {
  final int id;
  final String name;
  final String nameAmharic;
  final String nameTigrinya;

  Region({
    required this.id,
    required this.name,
    required this.nameAmharic,
    required this.nameTigrinya,
  });

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      id: json['id'],
      name: json['name'],
      nameAmharic: json['name_amharic'] ?? '',
      nameTigrinya: json['name_tigrinya'] ?? '',
    );
  }
}

/// Zone model
class Zone {
  final int id;
  final int regionId;
  final String name;
  final String nameAmharic;
  final String nameTigrinya;

  Zone({
    required this.id,
    required this.regionId,
    required this.name,
    required this.nameAmharic,
    required this.nameTigrinya,
  });

  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      id: json['id'],
      regionId: json['region_id'],
      name: json['name'],
      nameAmharic: json['name_amharic'] ?? '',
      nameTigrinya: json['name_tigrinya'] ?? '',
    );
  }
}

/// Woreda model
class Woreda {
  final int id;
  final int zoneId;
  final String name;
  final String nameAmharic;
  final String nameTigrinya;

  Woreda({
    required this.id,
    required this.zoneId,
    required this.name,
    required this.nameAmharic,
    required this.nameTigrinya,
  });

  factory Woreda.fromJson(Map<String, dynamic> json) {
    return Woreda(
      id: json['id'],
      zoneId: json['zone_id'],
      name: json['name'],
      nameAmharic: json['name_amharic'] ?? '',
      nameTigrinya: json['name_tigrinya'] ?? '',
    );
  }
}

/// Kebele model
class Kebele {
  final int id;
  final int woredaId;
  final String name;
  final String nameAmharic;
  final String nameTigrinya;

  Kebele({
    required this.id,
    required this.woredaId,
    required this.name,
    required this.nameAmharic,
    required this.nameTigrinya,
  });

  factory Kebele.fromJson(Map<String, dynamic> json) {
    return Kebele(
      id: json['id'],
      woredaId: json['woreda_id'],
      name: json['name'],
      nameAmharic: json['name_amharic'] ?? '',
      nameTigrinya: json['name_tigrinya'] ?? '',
    );
  }
}
