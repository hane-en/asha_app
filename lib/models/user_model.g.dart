// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String,
  userType: json['user_type'] as String,
  profileImage: json['profile_image'] as String?,
  isVerified: json['is_verified'] as bool,
  isActive: json['is_active'] as bool,
  rating: (json['rating'] as num).toDouble(),
  reviewCount: (json['review_count'] as num).toInt(),
  bio: json['bio'] as String?,
  website: json['website'] as String?,
  address: json['address'] as String?,
  city: json['city'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  isYemeniAccount: json['is_yemeni_account'] as bool,
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'phone': instance.phone,
  'user_type': instance.userType,
  'profile_image': instance.profileImage,
  'is_verified': instance.isVerified,
  'is_active': instance.isActive,
  'rating': instance.rating,
  'review_count': instance.reviewCount,
  'bio': instance.bio,
  'website': instance.website,
  'address': instance.address,
  'city': instance.city,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'is_yemeni_account': instance.isYemeniAccount,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};
