import 'package:flutter/material.dart';
import 'service_category_model.dart';

class ProviderServiceWithCategories {
  final int id;
  final String title;
  final String description;
  final double price;
  final List<String> images;
  final String city;
  final bool isActive;
  final bool isVerified;
  final String createdAt;
  final Map<String, dynamic> category;
  final List<ServiceCategory> serviceCategories;

  // حقول إضافية للتوافق مع النموذج القديم
  final String? location;
  final double rating;
  final int reviewsCount;
  final int bookingsCount;
  final int offersCount;
  final List<Map<String, dynamic>> reviews;

  ProviderServiceWithCategories({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.images,
    required this.city,
    required this.isActive,
    required this.isVerified,
    required this.createdAt,
    required this.category,
    required this.serviceCategories,
    this.location,
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.bookingsCount = 0,
    this.offersCount = 0,
    this.reviews = const [],
  });

  factory ProviderServiceWithCategories.fromJson(Map<String, dynamic> json) {
    return ProviderServiceWithCategories(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      images: List<String>.from(json['images'] ?? []),
      city: json['city'] ?? '',
      isActive: json['is_active'] ?? false,
      isVerified: json['is_verified'] ?? false,
      createdAt: json['created_at'] ?? '',
      category: Map<String, dynamic>.from(json['category'] ?? {}),
      serviceCategories:
          (json['service_categories'] as List<dynamic>?)
              ?.map((categoryJson) => ServiceCategory.fromJson(categoryJson))
              .toList() ??
          [],
      location: json['location'],
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewsCount: json['reviews_count'] ?? 0,
      bookingsCount: json['bookings_count'] ?? 0,
      offersCount: json['offers_count'] ?? 0,
      reviews: List<Map<String, dynamic>>.from(json['reviews'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'images': images,
      'city': city,
      'is_active': isActive,
      'is_verified': isVerified,
      'created_at': createdAt,
      'category': category,
      'service_categories': serviceCategories
          .map((category) => category.toJson())
          .toList(),
      'location': location,
      'rating': rating,
      'reviews_count': reviewsCount,
      'bookings_count': bookingsCount,
      'offers_count': offersCount,
      'reviews': reviews,
    };
  }

  // Getters for formatted data
  String get formattedPrice => '${price.toStringAsFixed(2)} ريال';
  String get statusText => isActive ? 'نشط' : 'غير نشط';
  Color get statusColor => isActive ? Colors.green : Colors.red;
  String get mainImage => images.isNotEmpty ? images.first : '';
  int get categoriesCount => serviceCategories.length;
  bool get hasCategories => serviceCategories.isNotEmpty;

  // Additional getters for compatibility
  String get imageUrl => mainImage;
  String get formattedRating => rating.toStringAsFixed(1);
  bool get hasReviews => reviewsCount > 0;

  // Category getters
  String get categoryName => category['name'] ?? '';
}
