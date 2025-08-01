import 'package:flutter/material.dart';

class ProviderModel {
  final int id;
  final String name;
  final String? description;
  final String? profileImage;
  final double rating;
  final int reviewCount;
  final bool isVerified;
  final bool isActive;
  final String? bio;
  final String? website;
  final String? address;
  final String city;
  final String country;
  final double? latitude;
  final double? longitude;
  final String createdAt;
  final String updatedAt;
  final int servicesCount;
  final int bookingsCount;

  ProviderModel({
    required this.id,
    required this.name,
    this.description,
    this.profileImage,
    required this.rating,
    required this.reviewCount,
    required this.isVerified,
    required this.isActive,
    this.bio,
    this.website,
    this.address,
    required this.city,
    required this.country,
    this.latitude,
    this.longitude,
    required this.createdAt,
    required this.updatedAt,
    required this.servicesCount,
    required this.bookingsCount,
  });

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    return ProviderModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      profileImage: json['profile_image'],
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      isVerified: json['is_verified'] ?? false,
      isActive: json['is_active'] ?? true,
      bio: json['bio'],
      website: json['website'],
      address: json['address'],
      city: json['city'] ?? 'إب',
      country: json['country'] ?? 'اليمن',
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      servicesCount: json['services_count'] ?? 0,
      bookingsCount: json['bookings_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'profile_image': profileImage,
      'rating': rating,
      'review_count': reviewCount,
      'is_verified': isVerified,
      'is_active': isActive,
      'bio': bio,
      'website': website,
      'address': address,
      'city': city,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'services_count': servicesCount,
      'bookings_count': bookingsCount,
    };
  }

  // تنسيق التقييم
  String get formattedRating {
    return rating.toStringAsFixed(1);
  }

  // نص التقييم
  String get ratingText {
    if (rating == 0) return 'لا توجد تقييمات';
    if (rating >= 4.5) return 'ممتاز';
    if (rating >= 4.0) return 'جيد جداً';
    if (rating >= 3.5) return 'جيد';
    if (rating >= 3.0) return 'مقبول';
    return 'ضعيف';
  }

  // لون التقييم
  Color get ratingColor {
    if (rating >= 4.5) return Colors.green;
    if (rating >= 4.0) return Colors.lightGreen;
    if (rating >= 3.5) return Colors.orange;
    if (rating >= 3.0) return Colors.orangeAccent;
    return Colors.red;
  }

  // الحرف الأول من الاسم
  String get firstLetter {
    return name.isNotEmpty ? name[0].toUpperCase() : 'م';
  }

  // هل المزود موثق
  String get verificationStatus {
    return isVerified ? 'موثق' : 'غير موثق';
  }

  // لون حالة التوثيق
  Color get verificationColor {
    return isVerified ? Colors.green : Colors.grey;
  }
} 