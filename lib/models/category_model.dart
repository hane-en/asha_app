import 'package:flutter/material.dart';

class CategoryModel {
  final int id;
  final String title;
  final String description;
  final String icon;
  final String color;
  final String? imageUrl;
  final int servicesCount;
  final bool isActive;
  final String createdAt;

  CategoryModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.imageUrl,
    required this.servicesCount,
    required this.isActive,
    required this.createdAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? 'category',
      color: json['color'] ?? '#8e24aa',
      imageUrl: json['image_url'],
      servicesCount: json['services_count'] ?? 0,
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'color': color,
      'image_url': imageUrl,
      'services_count': servicesCount,
      'is_active': isActive,
      'created_at': createdAt,
    };
  }

  // تحويل اسم الأيقونة إلى IconData
  IconData get iconData {
    switch (icon.toLowerCase()) {
      case 'meeting_room':
        return Icons.meeting_room;
      case 'cake':
        return Icons.cake;
      case 'celebration':
        return Icons.celebration;
      case 'camera_alt':
        return Icons.camera_alt;
      case 'checkroom':
        return Icons.checkroom;
      case 'music_note':
        return Icons.music_note;
      case 'restaurant':
        return Icons.restaurant;
      case 'local_florist':
        return Icons.local_florist;
      case 'videocam':
        return Icons.videocam;
      case 'car':
        return Icons.directions_car;
      case 'hotel':
        return Icons.hotel;
      case 'spa':
        return Icons.spa;
      default:
        return Icons.category;
    }
  }

  // تحويل اللون من String إلى Color
  Color get colorData {
    try {
      return Color(int.parse(color.replaceAll('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF8e24aa); // لون افتراضي
    }
  }

  @override
  String toString() {
    return 'CategoryModel(id: $id, title: $title, servicesCount: $servicesCount)';
  }
}
