/// Subscription Plan Model
class SubscriptionPlan {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final double price;
  final int durationMonths;
  final int maxListings;
  final int? maxFeaturedListings;
  final bool isActive;
  final int? sortOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.price,
    this.durationMonths = 1,
    this.maxListings = 1,
    this.maxFeaturedListings,
    this.isActive = true,
    this.sortOrder,
    this.createdAt,
    this.updatedAt,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'],
      price: _parseDouble(json['price']),
      durationMonths: json['duration_months'] ?? 1,
      maxListings: json['max_listings'] ?? 1,
      maxFeaturedListings: json['max_featured_listings'],
      isActive: json['is_active'] ?? true,
      sortOrder: json['sort_order'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  /// Parse double from various types (String, num, double)
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  String get displayPrice => '${price.toStringAsFixed(0)} ETB';

  String get durationLabel {
    if (durationMonths == 1) return '1 Month';
    if (durationMonths == 3) return '3 Months';
    if (durationMonths == 6) return '6 Months';
    if (durationMonths == 12) return '1 Year';
    return '$durationMonths Months';
  }

  bool get isFree => price == 0;
}

/// User Subscription Model
class Subscription {
  final int id;
  final int userId;
  final int planId;
  final String status;
  final DateTime startsAt;
  final DateTime? endsAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final SubscriptionPlan? plan;

  Subscription({
    required this.id,
    required this.userId,
    required this.planId,
    this.status = 'active',
    required this.startsAt,
    this.endsAt,
    this.createdAt,
    this.updatedAt,
    this.plan,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      planId: json['plan_id'] ?? 0,
      status: json['status'] ?? 'active',
      startsAt: json['starts_at'] != null
          ? DateTime.parse(json['starts_at'])
          : DateTime.now(),
      endsAt: json['ends_at'] != null ? DateTime.parse(json['ends_at']) : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      plan:
          json['plan'] != null ? SubscriptionPlan.fromJson(json['plan']) : null,
    );
  }

  bool get isActive =>
      status == 'active' && (endsAt == null || endsAt!.isAfter(DateTime.now()));
  bool get isExpired => endsAt != null && endsAt!.isBefore(DateTime.now());

  int get daysRemaining {
    if (endsAt == null) return 999;
    return endsAt!.difference(DateTime.now()).inDays;
  }
}
