import 'package:flutter/material.dart';

class ProviderServiceModel {
  final int id;
  final String title;
  final String description;
  final double price;
  final String? imageUrl;
  final String? location;
  final double rating;
  final int reviewsCount;
  final bool isActive;
  final String createdAt;
  final String updatedAt;
  final CategoryInfo category;
  final int offersCount;
  final int bookingsCount;
  final List<ServiceReview> reviews;

  ProviderServiceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.imageUrl,
    this.location,
    required this.rating,
    required this.reviewsCount,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
    required this.offersCount,
    required this.bookingsCount,
    required this.reviews,
  });

  factory ProviderServiceModel.fromJson(Map<String, dynamic> json) {
    final reviewsList =
        (json['reviews'] as List<dynamic>?)
            ?.map((review) => ServiceReview.fromJson(review))
            .toList() ??
        [];

    return ProviderServiceModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      imageUrl: json['image_url'],
      location: json['location'],
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewsCount: json['reviews_count'] ?? 0,
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      category: CategoryInfo.fromJson(json['category'] ?? {}),
      offersCount: json['offers_count'] ?? 0,
      bookingsCount: json['bookings_count'] ?? 0,
      reviews: reviewsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'location': location,
      'rating': rating,
      'reviews_count': reviewsCount,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'category': category.toJson(),
      'offers_count': offersCount,
      'bookings_count': bookingsCount,
      'reviews': reviews.map((review) => review.toJson()).toList(),
    };
  }

  // تنسيق السعر
  String get formattedPrice {
    return '${price.toStringAsFixed(0)} ر.ي';
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

  // التحقق من وجود تقييمات
  bool get hasReviews => reviewsCount > 0;

  // التحقق من وجود عروض
  bool get hasOffers => offersCount > 0;

  // التحقق من وجود حجوزات
  bool get hasBookings => bookingsCount > 0;

  // حالة الخدمة
  String get statusText {
    if (!isActive) return 'غير نشط';
    return 'نشط';
  }

  // لون حالة الخدمة
  Color get statusColor {
    if (!isActive) return Colors.red;
    return Colors.green;
  }

  // تاريخ الإنشاء
  String get formattedCreatedAt {
    try {
      final date = DateTime.parse(createdAt);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return createdAt;
    }
  }

  // تاريخ آخر تحديث
  String get formattedUpdatedAt {
    try {
      final date = DateTime.parse(updatedAt);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return updatedAt;
    }
  }

  @override
  String toString() {
    return 'ProviderServiceModel(id: $id, title: $title, rating: $rating, reviewsCount: $reviewsCount)';
  }
}

class ServiceReview {
  final int id;
  final int rating;
  final String comment;
  final String createdAt;
  final String userName;
  final String? userPhone;

  ServiceReview({
    required this.id,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.userName,
    this.userPhone,
  });

  factory ServiceReview.fromJson(Map<String, dynamic> json) {
    return ServiceReview(
      id: json['id'] ?? 0,
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      createdAt: json['created_at'] ?? '',
      userName: json['user_name'] ?? '',
      userPhone: json['user_phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt,
      'user_name': userName,
      'user_phone': userPhone,
    };
  }

  // تنسيق التاريخ
  String get formattedDate {
    try {
      final date = DateTime.parse(createdAt);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return createdAt;
    }
  }

  // نص التقييم
  String get ratingText {
    switch (rating) {
      case 5:
        return 'ممتاز';
      case 4:
        return 'جيد جداً';
      case 3:
        return 'جيد';
      case 2:
        return 'مقبول';
      case 1:
        return 'ضعيف';
      default:
        return 'غير محدد';
    }
  }

  // لون التقييم
  Color get ratingColor {
    switch (rating) {
      case 5:
        return Colors.green;
      case 4:
        return Colors.lightGreen;
      case 3:
        return Colors.orange;
      case 2:
        return Colors.deepOrange;
      case 1:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  String toString() {
    return 'ServiceReview(id: $id, rating: $rating, userName: $userName)';
  }
}

class CategoryInfo {
  final int id;
  final String name;
  final String color;

  CategoryInfo({required this.id, required this.name, required this.color});

  factory CategoryInfo.fromJson(Map<String, dynamic> json) {
    return CategoryInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      color: json['color'] ?? '#8e24aa',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'color': color};
  }

  // تحويل اللون من String إلى Color
  Color get colorData {
    try {
      return Color(int.parse(color.replaceAll('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF8e24aa); // لون افتراضي
    }
  }
}
