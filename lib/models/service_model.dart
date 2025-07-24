class ServiceModel {
  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.category,
    required this.providerId,
    required this.providerName,
    this.providerPhone,
    this.providerEmail,
    this.providerImage,
    this.image,
    this.images,
    this.rating,
    this.reviewCount,
    this.isFeatured = false,
    this.isVerified = false,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.bookingCount,
    this.favoriteCount,
    this.specifications,
    this.tags,
    this.location,
    this.latitude,
    this.longitude,
    this.address,
    this.city,
    this.duration,
    this.maxGuests,
    this.cancellationPolicy,
    this.depositRequired,
    this.depositAmount,
    this.paymentTerms,
    this.availability,
    this.distance,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) => ServiceModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      originalPrice: json['original_price'] != null
          ? (json['original_price'] as num).toDouble()
          : null,
      category: json['category'] ?? '',
      providerId: json['provider_id'] ?? 0,
      providerName: json['provider_name'] ?? '',
      providerPhone: json['provider_phone'],
      providerEmail: json['provider_email'],
      providerImage: json['provider_image'],
      image: json['image'],
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      rating: json['rating'] != null
          ? (json['rating'] as num).toDouble()
          : null,
      reviewCount: json['review_count'],
      isFeatured: json['is_featured'] ?? false,
      isVerified: json['is_verified'] ?? false,
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      bookingCount: json['booking_count'],
      favoriteCount: json['favorite_count'],
      specifications: json['specifications'] != null
          ? Map<String, dynamic>.from(json['specifications'])
          : null,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      location: json['location'],
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      address: json['address'],
      city: json['city'],
      duration: json['duration'],
      maxGuests: json['max_guests'],
      cancellationPolicy: json['cancellation_policy'],
      depositRequired: json['deposit_required'],
      depositAmount: json['deposit_amount'] != null
          ? (json['deposit_amount'] as num).toDouble()
          : null,
      paymentTerms: json['payment_terms'] != null
          ? List<String>.from(json['payment_terms'])
          : null,
      availability: json['availability'] != null
          ? Map<String, dynamic>.from(json['availability'])
          : null,
      distance: json['distance'] != null
          ? (json['distance'] as num).toDouble()
          : null,
    );
  final int id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final String category;
  final int providerId;
  final String providerName;
  final String? providerPhone;
  final String? providerEmail;
  final String? providerImage;
  final String? image;
  final List<String>? images;
  final double? rating;
  final int? reviewCount;
  final bool isFeatured;
  final bool isVerified;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? bookingCount;
  final int? favoriteCount;
  final Map<String, dynamic>? specifications;
  final List<String>? tags;
  final String? location;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? city;
  final int? duration; // in minutes
  final int? maxGuests;
  final String? cancellationPolicy;
  final bool? depositRequired;
  final double? depositAmount;
  final List<String>? paymentTerms;
  final Map<String, dynamic>? availability;
  final double? distance;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'price': price,
    'original_price': originalPrice,
    'category': category,
    'provider_id': providerId,
    'provider_name': providerName,
    'provider_phone': providerPhone,
    'provider_email': providerEmail,
    'provider_image': providerImage,
    'image': image,
    'images': images,
    'rating': rating,
    'review_count': reviewCount,
    'is_featured': isFeatured,
    'is_verified': isVerified,
    'is_active': isActive,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'booking_count': bookingCount,
    'favorite_count': favoriteCount,
    'specifications': specifications,
    'tags': tags,
    'location': location,
    'latitude': latitude,
    'longitude': longitude,
    'address': address,
    'city': city,
    'duration': duration,
    'max_guests': maxGuests,
    'cancellation_policy': cancellationPolicy,
    'deposit_required': depositRequired,
    'deposit_amount': depositAmount,
    'payment_terms': paymentTerms,
    'availability': availability,
    'distance': distance,
  };

  ServiceModel copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    double? originalPrice,
    String? category,
    int? providerId,
    String? providerName,
    String? providerPhone,
    String? providerEmail,
    String? providerImage,
    String? image,
    List<String>? images,
    double? rating,
    int? reviewCount,
    bool? isFeatured,
    bool? isVerified,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? bookingCount,
    int? favoriteCount,
    Map<String, dynamic>? specifications,
    List<String>? tags,
    String? location,
    double? latitude,
    double? longitude,
    String? address,
    String? city,
    int? duration,
    int? maxGuests,
    String? cancellationPolicy,
    bool? depositRequired,
    double? depositAmount,
    List<String>? paymentTerms,
    Map<String, dynamic>? availability,
    double? distance,
  }) => ServiceModel(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    price: price ?? this.price,
    originalPrice: originalPrice ?? this.originalPrice,
    category: category ?? this.category,
    providerId: providerId ?? this.providerId,
    providerName: providerName ?? this.providerName,
    providerPhone: providerPhone ?? this.providerPhone,
    providerEmail: providerEmail ?? this.providerEmail,
    providerImage: providerImage ?? this.providerImage,
    image: image ?? this.image,
    images: images ?? this.images,
    rating: rating ?? this.rating,
    reviewCount: reviewCount ?? this.reviewCount,
    isFeatured: isFeatured ?? this.isFeatured,
    isVerified: isVerified ?? this.isVerified,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    bookingCount: bookingCount ?? this.bookingCount,
    favoriteCount: favoriteCount ?? this.favoriteCount,
    specifications: specifications ?? this.specifications,
    tags: tags ?? this.tags,
    location: location ?? this.location,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    address: address ?? this.address,
    city: city ?? this.city,
    duration: duration ?? this.duration,
    maxGuests: maxGuests ?? this.maxGuests,
    cancellationPolicy: cancellationPolicy ?? this.cancellationPolicy,
    depositRequired: depositRequired ?? this.depositRequired,
    depositAmount: depositAmount ?? this.depositAmount,
    paymentTerms: paymentTerms ?? this.paymentTerms,
    availability: availability ?? this.availability,
    distance: distance ?? this.distance,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServiceModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ServiceModel(id: $id, name: $name, category: $category, price: $price)';

  // Price helpers
  String get formattedPrice => '${price.toStringAsFixed(2)} ريال';
  String get formattedOriginalPrice =>
      originalPrice != null ? '${originalPrice!.toStringAsFixed(2)} ريال' : '';
  bool get hasDiscount => originalPrice != null && originalPrice! > price;
  double get discountPercentage {
    if (!hasDiscount) return 0;
    return ((originalPrice! - price) / originalPrice! * 100).roundToDouble();
  }

  String get discountText =>
      hasDiscount ? 'خصم ${discountPercentage.toInt()}%' : '';

  // Rating helpers
  String get formattedRating => rating?.toStringAsFixed(1) ?? '0.0';
  String get ratingText {
    if (rating == null) return 'لا توجد تقييمات';
    if (rating! >= 4.5) return 'ممتاز';
    if (rating! >= 4.0) return 'جيد جداً';
    if (rating! >= 3.5) return 'جيد';
    if (rating! >= 3.0) return 'مقبول';
    return 'ضعيف';
  }

  bool get hasReviews => reviewCount != null && reviewCount! > 0;

  // Status helpers
  String get statusText {
    if (!isActive) return 'غير متاح';
    if (isFeatured) return 'مميز';
    if (isVerified) return 'موثق';
    return 'متاح';
  }

  // Popularity helpers
  bool get isPopular => bookingCount != null && bookingCount! > 10;
  bool get isTrending => favoriteCount != null && favoriteCount! > 5;

  // Time helpers
  String get timeSinceCreated {
    if (createdAt == null) return '';
    final now = DateTime.now();
    final difference = now.difference(createdAt!);

    if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }

  // Duration helpers
  String get formattedDuration {
    if (duration == null) return '';
    if (duration! < 60) {
      return '$duration دقيقة';
    } else if (duration! < 1440) {
      final hours = (duration! / 60).floor();
      final minutes = duration! % 60;
      if (minutes > 0) {
        return '$hours ساعة و $minutes دقيقة';
      }
      return '$hours ساعة';
    } else {
      final days = (duration! / 1440).floor();
      return '$days يوم';
    }
  }

  // Capacity helpers
  String get capacityText {
    if (maxGuests == null) return '';
    return 'لـ $maxGuests شخص';
  }

  // Image helpers
  String get mainImage => image ?? images?.firstOrNull ?? '';
  List<String> get allImages {
    final imageList = <String>[];
    if (image != null && image!.isNotEmpty) imageList.add(image!);
    if (images != null) imageList.addAll(images!);
    return imageList;
  }

  bool get hasImages => allImages.isNotEmpty;

  // Tags helpers
  List<String> get displayTags => tags ?? [];
  bool get hasTags => tags != null && tags!.isNotEmpty;

  // Location helpers
  bool get hasLocation => location != null && location!.isNotEmpty;
  bool get hasCoordinates => latitude != null && longitude != null;
  String get formattedDistance {
    if (distance == null) return '';
    if (distance! < 1) {
      return '${(distance! * 1000).round()} متر';
    } else if (distance! < 10) {
      return '${distance!.toStringAsFixed(1)} كم';
    } else {
      return '${distance!.round()} كم';
    }
  }

  String get locationText {
    if (city != null && city!.isNotEmpty) {
      return city!;
    } else if (address != null && address!.isNotEmpty) {
      return address!;
    } else if (location != null && location!.isNotEmpty) {
      return location!;
    }
    return 'موقع غير محدد';
  }

  // Validation helpers
  bool get isValid => name.isNotEmpty && description.isNotEmpty && price > 0;
  bool get hasCompleteInfo =>
      isValid && category.isNotEmpty && providerName.isNotEmpty;

  // Search helpers
  bool matchesSearch(String query) {
    final lowercaseQuery = query.toLowerCase();
    return name.toLowerCase().contains(lowercaseQuery) ||
        description.toLowerCase().contains(lowercaseQuery) ||
        category.toLowerCase().contains(lowercaseQuery) ||
        providerName.toLowerCase().contains(lowercaseQuery) ||
        (tags?.any((tag) => tag.toLowerCase().contains(lowercaseQuery)) ??
            false);
  }

  // Availability helpers
  bool get isAvailable {
    if (!isActive) return false;
    if (availability == null) return true;
    // Add custom availability logic here
    return true;
  }

  // Deposit helpers
  String get depositText {
    if (depositRequired != true) return 'لا يتطلب عربون';
    if (depositAmount != null) {
      return 'عربون ${depositAmount!.toStringAsFixed(2)} ريال';
    }
    return 'يتطلب عربون';
  }

  // Payment terms helpers
  List<String> get displayPaymentTerms => paymentTerms ?? [];
  bool get hasPaymentTerms => paymentTerms != null && paymentTerms!.isNotEmpty;
}
