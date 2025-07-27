import 'offer_model.dart';

class ServiceWithOffersModel {
  final int id;
  final String title;
  final String description;
  final double price;
  final String? imageUrl;
  final String? location;
  final double? rating;
  final int? reviewsCount;
  final bool isActive;
  final String createdAt;
  final CategoryInfo category;
  final ProviderInfo provider;
  final List<OfferModel> offers;
  final bool hasOffers;
  final OfferModel? bestOffer;

  ServiceWithOffersModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.imageUrl,
    this.location,
    this.rating,
    this.reviewsCount,
    required this.isActive,
    required this.createdAt,
    required this.category,
    required this.provider,
    required this.offers,
    required this.hasOffers,
    this.bestOffer,
  });

  factory ServiceWithOffersModel.fromJson(Map<String, dynamic> json) {
    final offersList =
        (json['offers'] as List<dynamic>?)
            ?.map((offer) => OfferModel.fromJson(offer))
            .toList() ??
        [];

    return ServiceWithOffersModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      imageUrl: json['image_url'],
      location: json['location'],
      rating: json['rating'] != null
          ? (json['rating'] as num).toDouble()
          : null,
      reviewsCount: json['reviews_count'],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] ?? '',
      category: CategoryInfo.fromJson(json['category'] ?? {}),
      provider: ProviderInfo.fromJson(json['provider'] ?? {}),
      offers: offersList,
      hasOffers: json['has_offers'] ?? false,
      bestOffer: json['best_offer'] != null
          ? OfferModel.fromJson(json['best_offer'])
          : null,
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
      'category': category.toJson(),
      'provider': provider.toJson(),
      'offers': offers.map((offer) => offer.toJson()).toList(),
      'has_offers': hasOffers,
      'best_offer': bestOffer?.toJson(),
    };
  }

  // تنسيق السعر
  String get formattedPrice {
    return '${price.toStringAsFixed(0)} ر.ي';
  }

  // تنسيق التقييم
  String get formattedRating {
    return rating?.toStringAsFixed(1) ?? '0.0';
  }

  // نص التقييم
  String get ratingText {
    if (rating == null) return 'لا توجد تقييمات';
    if (rating! >= 4.5) return 'ممتاز';
    if (rating! >= 4.0) return 'جيد جداً';
    if (rating! >= 3.5) return 'جيد';
    if (rating! >= 3.0) return 'مقبول';
    return 'ضعيف';
  }

  // التحقق من وجود تقييمات
  bool get hasReviews => reviewsCount != null && reviewsCount! > 0;

  // أفضل عرض صالح
  OfferModel? get validBestOffer {
    if (bestOffer == null) return null;
    return bestOffer!.isValid ? bestOffer : null;
  }

  // السعر بعد الخصم
  double get finalPrice {
    final validOffer = validBestOffer;
    return validOffer?.discountedPrice ?? price;
  }

  // تنسيق السعر النهائي
  String get formattedFinalPrice {
    return '${finalPrice.toStringAsFixed(0)} ر.ي';
  }

  // التحقق من وجود خصم
  bool get hasDiscount {
    return validBestOffer != null;
  }

  // نسبة الخصم
  int get discountPercentage {
    final validOffer = validBestOffer;
    return validOffer?.discountPercentage ?? 0;
  }

  // نص الخصم
  String get discountText {
    if (!hasDiscount) return '';
    return 'خصم $discountPercentage%';
  }

  // التوفير
  double get savings {
    final validOffer = validBestOffer;
    return validOffer?.savings ?? 0;
  }

  // تنسيق التوفير
  String get formattedSavings {
    return '${savings.toStringAsFixed(0)} ر.ي';
  }

  @override
  String toString() {
    return 'ServiceWithOffersModel(id: $id, title: $title, hasOffers: $hasOffers)';
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
}

class ProviderInfo {
  final int id;
  final String name;
  final String? phone;
  final String? email;
  final double? rating;

  ProviderInfo({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.rating,
  });

  factory ProviderInfo.fromJson(Map<String, dynamic> json) {
    return ProviderInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'],
      email: json['email'],
      rating: json['rating'] != null
          ? (json['rating'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'rating': rating,
    };
  }

  // تنسيق التقييم
  String get formattedRating {
    return rating?.toStringAsFixed(1) ?? '0.0';
  }
}
