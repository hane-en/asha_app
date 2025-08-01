class AdModel {
  final int id;
  final String title;
  final String description;
  final String image;
  final bool isActive;
  final String? startDate;
  final String? endDate;
  final String createdAt;
  final String? providerName;
  final int? providerId;
  final String? link;
  final bool hasLink;

  AdModel({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.isActive,
    this.startDate,
    this.endDate,
    required this.createdAt,
    this.providerName,
    this.providerId,
    this.link,
    this.hasLink = false,
  });

  // Getter for validation
  bool get isValid => id > 0 && title.isNotEmpty && isActive;

  // Getter for priority (using providerId as priority for now)
  int get priority => providerId ?? 0;

  // Convert string dates to DateTime
  DateTime? get startDateTime {
    if (startDate == null) return null;
    try {
      return DateTime.parse(startDate!);
    } catch (e) {
      return null;
    }
  }

  DateTime? get endDateTime {
    if (endDate == null) return null;
    try {
      return DateTime.parse(endDate!);
    } catch (e) {
      return null;
    }
  }

  factory AdModel.fromJson(Map<String, dynamic> json) {
    return AdModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? json['imageUrl'] ?? '',
      isActive: json['is_active'] == true || json['is_active'] == 1,
      startDate: json['start_date'],
      endDate: json['end_date'],
      createdAt: json['created_at'] ?? '',
      providerName: json['provider_name'] ?? json['providerName'],
      providerId: json['provider_id'] != null
          ? int.tryParse(json['provider_id'].toString())
          : null,
      link: json['link_url'] ?? json['link'],
      hasLink: json['has_link'] == true || (json['link_url'] != null && json['link_url'].toString().isNotEmpty),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image': image,
      'is_active': isActive,
      'start_date': startDate,
      'end_date': endDate,
      'created_at': createdAt,
      'provider_name': providerName,
      'provider_id': providerId,
      'link': link,
    };
  }
}
