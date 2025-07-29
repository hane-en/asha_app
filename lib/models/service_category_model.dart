class ServiceCategory {
  final int id;
  final int serviceId;
  final String name;
  final String description;
  final double price;
  final String image;
  final String? size;
  final String? dimensions;
  final String? location;
  final int quantity;
  final String? duration;
  final String? materials;
  final String? additionalFeatures;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  ServiceCategory({
    required this.id,
    required this.serviceId,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    this.size,
    this.dimensions,
    this.location,
    this.quantity = 1,
    this.duration,
    this.materials,
    this.additionalFeatures,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id'] ?? 0,
      serviceId: json['service_id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      image: json['image'] ?? '',
      size: json['size'],
      dimensions: json['dimensions'],
      location: json['location'],
      quantity: json['quantity'] ?? 1,
      duration: json['duration'],
      materials: json['materials'],
      additionalFeatures: json['additional_features'],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_id': serviceId,
      'name': name,
      'description': description,
      'price': price,
      'image': image,
      'size': size,
      'dimensions': dimensions,
      'location': location,
      'quantity': quantity,
      'duration': duration,
      'materials': materials,
      'additional_features': additionalFeatures,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  ServiceCategory copyWith({
    int? id,
    int? serviceId,
    String? name,
    String? description,
    double? price,
    String? image,
    String? size,
    String? dimensions,
    String? location,
    int? quantity,
    String? duration,
    String? materials,
    String? additionalFeatures,
    bool? isActive,
    String? createdAt,
    String? updatedAt,
  }) {
    return ServiceCategory(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      image: image ?? this.image,
      size: size ?? this.size,
      dimensions: dimensions ?? this.dimensions,
      location: location ?? this.location,
      quantity: quantity ?? this.quantity,
      duration: duration ?? this.duration,
      materials: materials ?? this.materials,
      additionalFeatures: additionalFeatures ?? this.additionalFeatures,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ServiceCategory(id: $id, serviceId: $serviceId, name: $name, price: $price)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServiceCategory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class ServiceCategoryResponse {
  final bool success;
  final String message;
  final List<ServiceCategory> data;
  final Map<String, dynamic>? serviceInfo;
  final int totalCategories;

  ServiceCategoryResponse({
    required this.success,
    required this.message,
    required this.data,
    this.serviceInfo,
    required this.totalCategories,
  });

  factory ServiceCategoryResponse.fromJson(Map<String, dynamic> json) {
    return ServiceCategoryResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => ServiceCategory.fromJson(item))
              .toList() ??
          [],
      serviceInfo: json['service_info'],
      totalCategories: json['total_categories'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
      'service_info': serviceInfo,
      'total_categories': totalCategories,
    };
  }
}
