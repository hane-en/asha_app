import 'package:json_annotation/json_annotation.dart';

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
    id: json['id'] as int,
    providerId: json['provider_id'] as int,
    categoryId: json['category_id'] as int,
    title: json['title'] as String,
    description: json['description'] as String,
    price: (json['price'] as num).toDouble(),
    originalPrice: (json['original_price'] as num?)?.toDouble(),
    duration: json['duration'] as int,
    images: (json['images'] as List<dynamic>).map((e) => e as String).toList(),
    isActive: json['is_active'] as bool,
    isVerified: json['is_verified'] as bool,
    isFeatured: json['is_featured'] as bool,
    rating: (json['rating'] as num).toDouble(),
    totalRatings: json['total_ratings'] as int,
    bookingCount: json['booking_count'] as int,
    favoriteCount: json['favorite_count'] as int,
    specifications: json['specifications'] as Map<String, dynamic>?,
    tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
    location: json['location'] as String,
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
    address: json['address'] as String,
    city: json['city'] as String,
    maxGuests: json['max_guests'] as int?,
    cancellationPolicy: json['cancellation_policy'] as String?,
    depositRequired: json['deposit_required'] as bool,
    depositAmount: (json['deposit_amount'] as num?)?.toDouble(),
    paymentTerms: json['payment_terms'] as Map<String, dynamic>?,
    availability: json['availability'] as Map<String, dynamic>?,
    createdAt: json['created_at'] as String,
    updatedAt: json['updated_at'] as String,
    categoryName: json['category_name'] as String?,
    providerName: json['provider_name'] as String?,
    providerRating: (json['provider_rating'] as num?)?.toDouble(),
    providerImage: json['provider_image'] as String?,
  );

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
