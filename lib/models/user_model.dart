import 'dart:convert';

class UserModel {

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
    this.profileImage,
    this.address,
    this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.isVerified = false,
    this.verificationCode,
    this.lastLoginAt,
    this.deviceToken,
    this.preferences,
    this.rating,
    this.reviewCount,
    this.bio,
    this.website,
    this.socialMedia,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      profileImage: json['profile_image'],
      address: json['address'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      isActive: json['is_active'] ?? true,
      isVerified: json['is_verified'] ?? false,
      verificationCode: json['verification_code'],
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.tryParse(json['last_login_at'])
          : null,
      deviceToken: json['device_token'],
      preferences: json['preferences'] != null
          ? Map<String, dynamic>.from(json['preferences'])
          : null,
      rating: json['rating'],
      reviewCount: json['review_count'],
      bio: json['bio'],
      website: json['website'],
      socialMedia: json['social_media'],
    );
  final int id;
  final String name;
  final String phone;
  final String email;
  final String role;
  final String? profileImage;
  final String? address;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final bool isVerified;
  final String? verificationCode;
  final DateTime? lastLoginAt;
  final String? deviceToken;
  final Map<String, dynamic>? preferences;
  final int? rating;
  final int? reviewCount;
  final String? bio;
  final String? website;
  final String? socialMedia;

  Map<String, dynamic> toJson() => {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role,
      'profile_image': profileImage,
      'address': address,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_active': isActive,
      'is_verified': isVerified,
      'verification_code': verificationCode,
      'last_login_at': lastLoginAt?.toIso8601String(),
      'device_token': deviceToken,
      'preferences': preferences,
      'rating': rating,
      'review_count': reviewCount,
      'bio': bio,
      'website': website,
      'social_media': socialMedia,
    };

  UserModel copyWith({
    int? id,
    String? name,
    String? phone,
    String? email,
    String? role,
    String? profileImage,
    String? address,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    bool? isVerified,
    String? verificationCode,
    DateTime? lastLoginAt,
    String? deviceToken,
    Map<String, dynamic>? preferences,
    int? rating,
    int? reviewCount,
    String? bio,
    String? website,
    String? socialMedia,
  }) => UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      verificationCode: verificationCode ?? this.verificationCode,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      deviceToken: deviceToken ?? this.deviceToken,
      preferences: preferences ?? this.preferences,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      bio: bio ?? this.bio,
      website: website ?? this.website,
      socialMedia: socialMedia ?? this.socialMedia,
    );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'UserModel(id: $id, name: $name, phone: $phone, email: $email, role: $role)';

  // Role checks
  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get isProvider => role.toLowerCase() == 'provider';
  bool get isUser => role.toLowerCase() == 'user';

  // Status checks
  bool get canLogin => isActive && isVerified;
  bool get needsVerification => !isVerified;
  bool get isSuspended => !isActive;

  // Profile completeness
  bool get hasCompleteProfile =>
      name.isNotEmpty &&
      phone.isNotEmpty &&
      email.isNotEmpty &&
      address != null &&
      address!.isNotEmpty;

  double get profileCompleteness {
    var completedFields = 0;
    final totalFields = 5; // name, phone, email, address, profileImage

    if (name.isNotEmpty) completedFields++;
    if (phone.isNotEmpty) completedFields++;
    if (email.isNotEmpty) completedFields++;
    if (address != null && address!.isNotEmpty) completedFields++;
    if (profileImage != null && profileImage!.isNotEmpty) completedFields++;

    return completedFields / totalFields;
  }

  // Rating helpers
  double get averageRating => rating?.toDouble() ?? 0.0;
  bool get hasReviews => reviewCount != null && reviewCount! > 0;
  String get formattedRating => averageRating.toStringAsFixed(1);

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

  String get timeSinceLastLogin {
    if (lastLoginAt == null) return 'لم يسجل دخول من قبل';
    final now = DateTime.now();
    final difference = now.difference(lastLoginAt!);

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

  // Display helpers
  String get displayName => name.isNotEmpty ? name : 'مستخدم غير معروف';
  String get displayEmail => email.isNotEmpty ? email : 'لا يوجد بريد إلكتروني';
  String get displayPhone => phone.isNotEmpty ? phone : 'لا يوجد رقم هاتف';
  String get displayAddress =>
      address?.isNotEmpty == true ? address! : 'لا يوجد عنوان';

  // Validation helpers
  bool get isValidEmail =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  bool get isValidPhone =>
      RegExp(r'^(05|5)(5|0|3|6|4|9|1|8|7)([0-9]{7})$').hasMatch(phone);
  bool get hasValidProfile => isValidEmail && isValidPhone && name.isNotEmpty;

  // Preferences helpers
  String? getPreference(String key) => preferences?[key];
  void setPreference(String key, value) {
    preferences?[key] = value;
  }

  // Social media helpers
  Map<String, String> get socialMediaLinks {
    if (socialMedia == null) return {};
    try {
      return Map<String, String>.from(json.decode(socialMedia!));
    } catch (e) {
      return {};
    }
  }

  String? getSocialMediaLink(String platform) => socialMediaLinks[platform];

  // Utility methods
  String get initials {
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  bool get hasProfileImage => profileImage != null && profileImage!.isNotEmpty;
  bool get hasBio => bio != null && bio!.isNotEmpty;
  bool get hasWebsite => website != null && website!.isNotEmpty;
}
