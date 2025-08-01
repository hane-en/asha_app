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
    final title = json['name'] ?? json['title'] ?? '';

    // تحديد الأيقونة واللون بناءً على اسم الفئة
    final iconAndColor = _getIconAndColor(title);

    return CategoryModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: title,
      description: json['description'] ?? '',
      icon: iconAndColor['icon']!,
      color: iconAndColor['color']!,
      imageUrl: json['image'] ?? json['image_url'],
      servicesCount: int.tryParse(json['services_count'].toString()) ?? 0,
      isActive: json['is_active'] == true || json['is_active'] == 1,
      createdAt: json['created_at'] ?? '',
    );
  }

  // دالة لتحديد الأيقونة واللون بناءً على اسم الفئة
  static Map<String, String> _getIconAndColor(String title) {
    final lowerTitle = title.toLowerCase();

    if (lowerTitle.contains('قاعات') ||
        lowerTitle.contains('أفراح') ||
        lowerTitle.contains('حفلات')) {
      return {
        'icon': 'celebration',
        'color': '#8e24aa', // بنفسجي
      };
    } else if (lowerTitle.contains('تصوير') ||
        lowerTitle.contains('فوتو') ||
        lowerTitle.contains('كاميرا')) {
      return {
        'icon': 'camera_alt',
        'color': '#ff9800', // برتقالي
      };
    } else if (lowerTitle.contains('ديكور') ||
        lowerTitle.contains('تزيين') ||
        lowerTitle.contains('زينة')) {
      return {
        'icon': 'local_florist',
        'color': '#4caf50', // أخضر
      };
    } else if (lowerTitle.contains('جاتوهات') ||
        lowerTitle.contains('كيك') ||
        lowerTitle.contains('حلويات')) {
      return {
        'icon': 'cake',
        'color': '#e91e63', // وردي
      };
    } else if (lowerTitle.contains('موسيقى') ||
        lowerTitle.contains('صوت') ||
        lowerTitle.contains('ساوند')) {
      return {
        'icon': 'music_note',
        'color': '#2196f3', // أزرق
      };
    } else if (lowerTitle.contains('فساتين') ||
        lowerTitle.contains('أزياء') ||
        lowerTitle.contains('ملابس')) {
      return {
        'icon': 'checkroom',
        'color': '#9c27b0', // بنفسجي غامق
      };
    } else {
      return {
        'icon': 'category',
        'color': '#607d8b', // رمادي
      };
    }
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
