import 'package:json_annotation/json_annotation.dart';
import 'dart:convert'; // Added for json.decode

@JsonSerializable()
class Service {
  final int id;
  @JsonKey(name: 'provider_id')
  final int providerId;
  @JsonKey(name: 'category_id')
  final int categoryId;
  final String title;
  final String description;
  final double price;
  @JsonKey(name: 'original_price')
  final double? originalPrice;
  final int duration;
  final List<String> images;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'is_verified')
  final bool isVerified;
  @JsonKey(name: 'is_featured')
  final bool isFeatured;
  final double rating;
  @JsonKey(name: 'total_ratings')
  final int totalRatings;
  @JsonKey(name: 'booking_count')
  final int bookingCount;
  @JsonKey(name: 'favorite_count')
  final int favoriteCount;
  final Map<String, dynamic>? specifications;
  final List<String> tags;
  final String location;
  final double? latitude;
  final double? longitude;
  final String address;
  final String city;
  @JsonKey(name: 'max_guests')
  final int? maxGuests;
  @JsonKey(name: 'cancellation_policy')
  final String? cancellationPolicy;
  @JsonKey(name: 'deposit_required')
  final bool depositRequired;
  @JsonKey(name: 'deposit_amount')
  final double? depositAmount;
  @JsonKey(name: 'payment_terms')
  final Map<String, dynamic>? paymentTerms;
  final Map<String, dynamic>? availability;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;
  @JsonKey(name: 'category_name')
  final String? categoryName;
  @JsonKey(name: 'provider_name')
  final String? providerName;
  @JsonKey(name: 'provider_rating')
  final double? providerRating;
  @JsonKey(name: 'provider_image')
  final String? providerImage;

  Service({
    required this.id,
    required this.providerId,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.duration,
    required this.images,
    required this.isActive,
    required this.isVerified,
    required this.isFeatured,
    required this.rating,
    required this.totalRatings,
    required this.bookingCount,
    required this.favoriteCount,
    this.specifications,
    required this.tags,
    required this.location,
    this.latitude,
    this.longitude,
    required this.address,
    required this.city,
    this.maxGuests,
    this.cancellationPolicy,
    required this.depositRequired,
    this.depositAmount,
    this.paymentTerms,
    this.availability,
    required this.createdAt,
    required this.updatedAt,
    this.categoryName,
    this.providerName,
    this.providerRating,
    this.providerImage,
  });

  factory Service.fromJson(Map<String, dynamic> json) => Service(
    id: int.tryParse(json['id'].toString()) ?? 0,
    providerId: int.tryParse(json['provider_id'].toString()) ?? 0,
    categoryId: int.tryParse(json['category_id'].toString()) ?? 0,
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    price: (json['price'] as num?)?.toDouble() ?? 0.0,
    originalPrice: (json['original_price'] as num?)?.toDouble(),
    duration: int.tryParse(json['duration'].toString()) ?? 0,
    images: _parseJsonList(json['images']),
    isActive: json['is_active'] == true || json['is_active'] == 1,
    isVerified: json['is_verified'] == true || json['is_verified'] == 1,
    isFeatured: json['is_featured'] == true || json['is_featured'] == 1,
    rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    totalRatings: int.tryParse(json['total_ratings'].toString()) ?? 0,
    bookingCount: int.tryParse(json['booking_count'].toString()) ?? 0,
    favoriteCount: int.tryParse(json['favorite_count'].toString()) ?? 0,
    specifications: _parseJsonMap(json['specifications']),
    tags: _parseJsonList(json['tags']),
    location: json['location'] ?? '',
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
    address: json['address'] ?? '',
    city: json['city'] ?? '',
    maxGuests: json['max_guests'] != null
        ? int.tryParse(json['max_guests'].toString())
        : null,
    cancellationPolicy: json['cancellation_policy'],
    depositRequired:
        json['deposit_required'] == true || json['deposit_required'] == 1,
    depositAmount: (json['deposit_amount'] as num?)?.toDouble(),
    paymentTerms: _parseJsonMap(json['payment_terms']),
    availability: _parseJsonMap(json['availability']),
    createdAt: json['created_at'] ?? '',
    updatedAt: json['updated_at'] ?? '',
    categoryName: json['category_name'],
    providerName: json['provider_name'],
    providerRating: (json['provider_rating'] as num?)?.toDouble(),
    providerImage: json['provider_image'],
  );

  // Helper method to parse JSON strings or lists
  static List<String> _parseJsonList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    if (value is String) {
      try {
        final decoded = json.decode(value) as List;
        return decoded.map((e) => e.toString()).toList();
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  // Helper method to parse JSON strings or maps
  static Map<String, dynamic>? _parseJsonMap(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is String) {
      try {
        return json.decode(value) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'provider_id': providerId,
    'category_id': categoryId,
    'title': title,
    'description': description,
    'price': price,
    'original_price': originalPrice,
    'duration': duration,
    'images': images,
    'is_active': isActive,
    'is_verified': isVerified,
    'is_featured': isFeatured,
    'rating': rating,
    'total_ratings': totalRatings,
    'booking_count': bookingCount,
    'favorite_count': favoriteCount,
    'specifications': specifications,
    'tags': tags,
    'location': location,
    'latitude': latitude,
    'longitude': longitude,
    'address': address,
    'city': city,
    'max_guests': maxGuests,
    'cancellation_policy': cancellationPolicy,
    'deposit_required': depositRequired,
    'deposit_amount': depositAmount,
    'payment_terms': paymentTerms,
    'availability': availability,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'category_name': categoryName,
    'provider_name': providerName,
    'provider_rating': providerRating,
    'provider_image': providerImage,
  };
}
