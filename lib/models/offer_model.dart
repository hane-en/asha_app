class OfferModel {
  final int id;
  final String title;
  final String description;
  final double originalPrice;
  final double discountedPrice;
  final int discountPercentage;
  final String validFrom;
  final String validUntil;
  final bool isActive;

  OfferModel({
    required this.id,
    required this.title,
    required this.description,
    required this.originalPrice,
    required this.discountedPrice,
    required this.discountPercentage,
    required this.validFrom,
    required this.validUntil,
    required this.isActive,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      originalPrice: (json['original_price'] ?? 0.0).toDouble(),
      discountedPrice: (json['discounted_price'] ?? 0.0).toDouble(),
      discountPercentage: json['discount_percentage'] ?? 0,
      validFrom: json['valid_from'] ?? '',
      validUntil: json['valid_until'] ?? '',
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'original_price': originalPrice,
      'discounted_price': discountedPrice,
      'discount_percentage': discountPercentage,
      'valid_from': validFrom,
      'valid_until': validUntil,
      'is_active': isActive,
    };
  }

  // التحقق من صلاحية العرض
  bool get isValid {
    if (!isActive) return false;

    final now = DateTime.now();
    final from = DateTime.tryParse(validFrom);
    final until = DateTime.tryParse(validUntil);

    if (from == null || until == null) return false;

    return now.isAfter(from) && now.isBefore(until);
  }

  // تنسيق السعر الأصلي
  String get formattedOriginalPrice {
    return '${originalPrice.toStringAsFixed(0)} ر.ي';
  }

  // تنسيق السعر المخفض
  String get formattedDiscountedPrice {
    return '${discountedPrice.toStringAsFixed(0)} ر.ي';
  }

  // تنسيق نسبة الخصم
  String get formattedDiscountPercentage {
    return '$discountPercentage%';
  }

  // حساب التوفير
  double get savings {
    return originalPrice - discountedPrice;
  }

  // تنسيق التوفير
  String get formattedSavings {
    return '${savings.toStringAsFixed(0)} ر.ي';
  }

  @override
  String toString() {
    return 'OfferModel(id: $id, title: $title, discountPercentage: $discountPercentage%)';
  }
}
