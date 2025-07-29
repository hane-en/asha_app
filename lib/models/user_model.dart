import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String name;
  final String email;
  final String phone;
  @JsonKey(name: 'user_type')
  final String userType;
  @JsonKey(name: 'profile_image')
  final String? profileImage;
  @JsonKey(name: 'is_verified')
  final bool isVerified;
  @JsonKey(name: 'is_active')
  final bool isActive;
  final double rating;
  @JsonKey(name: 'review_count')
  final int reviewCount;
  final String? bio;
  final String? website;
  final String? address;
  final String? city;
  final double? latitude;
  final double? longitude;
  @JsonKey(name: 'is_yemeni_account')
  final bool isYemeniAccount;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.userType,
    this.profileImage,
    required this.isVerified,
    required this.isActive,
    required this.rating,
    required this.reviewCount,
    this.bio,
    this.website,
    this.address,
    this.city,
    this.latitude,
    this.longitude,
    required this.isYemeniAccount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: int.tryParse(json['id'].toString()) ?? 0,
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    phone: json['phone'] ?? '',
    userType: json['user_type'] ?? 'user',
    profileImage: json['profile_image'],
    isVerified: json['is_verified'] == true || json['is_verified'] == 1,
    isActive: json['is_active'] == true || json['is_active'] == 1,
    rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    reviewCount: int.tryParse(json['review_count'].toString()) ?? 0,
    bio: json['bio'],
    website: json['website'],
    address: json['address'],
    city: json['city'],
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
    isYemeniAccount:
        json['is_yemeni_account'] == true || json['is_yemeni_account'] == 1,
    createdAt: json['created_at'] ?? '',
    updatedAt: json['updated_at'] ?? '',
  );
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
