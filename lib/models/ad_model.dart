class AdModel {
  AdModel({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    this.link,
    this.isActive = true,
    this.priority = 0,
    this.startDate,
    this.endDate,
    this.createdAt,
    this.updatedAt,
    this.providerName,
    this.providerId,
  });

  factory AdModel.fromJson(Map<String, dynamic> json) => AdModel(
    id: json['id'] ?? 0,
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    image: json['image'] ?? '',
    link: json['link'],
    isActive: json['is_active'] ?? true,
    priority: json['priority'] ?? 0,
    startDate: json['start_date'] != null
        ? DateTime.tryParse(json['start_date'])
        : null,
    endDate: json['end_date'] != null
        ? DateTime.tryParse(json['end_date'])
        : null,
    createdAt: json['created_at'] != null
        ? DateTime.tryParse(json['created_at'])
        : null,
    updatedAt: json['updated_at'] != null
        ? DateTime.tryParse(json['updated_at'])
        : null,
    providerName: json['provider_name'],
    providerId: json['provider_id'],
  );
  final int id;
  final String title;
  final String description;
  final String image;
  final String? link;
  final bool isActive;
  final int priority;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? providerName;
  final int? providerId;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'image': image,
    'link': link,
    'is_active': isActive,
    'priority': priority,
    'start_date': startDate?.toIso8601String(),
    'end_date': endDate?.toIso8601String(),
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'provider_name': providerName,
    'provider_id': providerId,
  };

  AdModel copyWith({
    int? id,
    String? title,
    String? description,
    String? image,
    String? link,
    bool? isActive,
    int? priority,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? providerName,
    int? providerId,
  }) => AdModel(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    image: image ?? this.image,
    link: link ?? this.link,
    isActive: isActive ?? this.isActive,
    priority: priority ?? this.priority,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    providerName: providerName ?? this.providerName,
    providerId: providerId ?? this.providerId,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AdModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'AdModel(id: $id, title: $title, isActive: $isActive)';

  bool get isValid {
    if (!isActive) return false;
    final now = DateTime.now();
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    return true;
  }

  bool get hasLink => link != null && link!.isNotEmpty;
}
