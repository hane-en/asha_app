import 'package:flutter/material.dart';

<<<<<<< HEAD
class AppColors {
  static const Color primaryColor = Color(0xFF8e24aa);
  static const Color secondaryColor = Color(0xFF9c27b0);
  static const Color accentColor = Color(0xFFe1bee7);
  static const Color backgroundColor = Color(0xFFF3E5F5);
  static const Color textColor = Colors.black87;
  static const Color white = Colors.white;
  static const Color grey = Colors.grey;
}
=======
// الألوان الرئيسية
const Color primaryColor = Color(0xFF8e24aa);
const Color secondaryColor = Color(0xFFE1BEE7);
const Color accentColor = Color(0xFF4A148C);
>>>>>>> cb84a2eea26d79ad48594283002ea73596c659d0

final ThemeData lightTheme = ThemeData(
  primarySwatch: Colors.purple,
  primaryColor: const Color(0xFF8e24aa),
  scaffoldBackgroundColor: const Color(0xFFF3E5F5),
  fontFamily: 'Cairo',
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF8e24aa),
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF8e24aa),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF8e24aa), width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.red),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    labelStyle: const TextStyle(color: Colors.grey),
  ),
  cardTheme: const CardThemeData(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    ),
    bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
    bodyMedium: TextStyle(fontSize: 14, color: Colors.black87),
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.purple,
  primaryColor: const Color(0xFF8e24aa),
  scaffoldBackgroundColor: const Color(0xFF1A1A1A),
  fontFamily: 'Cairo',
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF8e24aa),
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF8e24aa),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF8e24aa), width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.red),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    labelStyle: const TextStyle(color: Colors.grey),
  ),
  cardTheme: const CardThemeData(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    bodyLarge: TextStyle(fontSize: 16, color: Colors.white),
    bodyMedium: TextStyle(fontSize: 14, color: Colors.white),
  ),
);

class AppConstants {
  // App Information
  static const String appName = 'تطبيق آشا لخدمات المناسبات';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'تطبيق شامل لإدارة خدمات المناسبات';

  // User Roles
  static const String roleUser = 'user';
  static const String roleProvider = 'provider';
  static const String roleAdmin = 'admin';

  // Booking Status
  static const String statusPending = 'pending';
  static const String statusConfirmed = 'confirmed';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';

  // Service Categories
  static const List<String> serviceCategories = [
    'تصوير',
    'تنسيق',
    'ضيافة',
    'موسيقى',
    'نقل',
    'أخرى',
  ];

  // Service Categories Icons
  static const Map<String, String> categoryIcons = {
    'تصوير': '📸',
    'تنسيق': '🎨',
    'ضيافة': '🍽️',
    'موسيقى': '🎵',
    'نقل': '🚗',
    'أخرى': '📋',
  };

  // Service Categories Colors
  static const Map<String, int> categoryColors = {
    'تصوير': 0xFF2196F3, // Blue
    'تنسيق': 0xFF4CAF50, // Green
    'ضيافة': 0xFFFF9800, // Orange
    'موسيقى': 0xFF9C27B0, // Purple
    'نقل': 0xFF607D8B, // Blue Grey
    'أخرى': 0xFF795548, // Brown
  };

  // Error Messages
  static const String errorNetwork = 'خطأ في الاتصال بالشبكة';
  static const String errorServer = 'خطأ في الخادم';
  static const String errorUnknown = 'خطأ غير معروف';
  static const String errorValidation = 'بيانات غير صحيحة';
  static const String errorTimeout = 'انتهت مهلة الاتصال';
  static const String errorNoData = 'لا توجد بيانات';

  // Success Messages
  static const String successLogin = 'تم تسجيل الدخول بنجاح';
  static const String successRegister = 'تم التسجيل بنجاح';
  static const String successLogout = 'تم تسجيل الخروج بنجاح';
  static const String successBooking = 'تم الحجز بنجاح';
  static const String successUpdate = 'تم التحديث بنجاح';
  static const String successDelete = 'تم الحذف بنجاح';
  static const String successAdd = 'تم الإضافة بنجاح';

  // Validation Messages
  static const String validationRequired = 'هذا الحقل مطلوب';
  static const String validationEmail = 'البريد الإلكتروني غير صحيح';
  static const String validationPhone = 'رقم الهاتف غير صحيح';
  static const String validationPassword =
      'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
  static const String validationPasswordMatch = 'كلمتا المرور غير متطابقتين';
  static const String validationName = 'الاسم يجب أن يكون حرفين على الأقل';
  static const String validationPrice = 'السعر يجب أن يكون رقم صحيح';
  static const String validationDescription =
      'الوصف يجب أن يكون 10 أحرف على الأقل';

  // UI Constants
  static const double defaultPadding = 16;
  static const double smallPadding = 8;
  static const double largePadding = 24;
  static const double defaultRadius = 8;
  static const double largeRadius = 12;
  static const double defaultElevation = 2;
  static const double largeElevation = 4;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Cache Keys
  static const String cacheUser = 'user_cache';
  static const String cacheToken = 'token_cache';
  static const String cacheSettings = 'settings_cache';
  static const String cacheFavorites = 'favorites_cache';

  // API Endpoints
  static const String endpointLogin = 'login.php';
  static const String endpointRegister = 'register.php';
  static const String endpointLogout = 'logout.php';
  static const String endpointServices = 'services.php';
  static const String endpointBookings = 'bookings.php';
  static const String endpointUsers = 'users.php';
  static const String endpointAds = 'ads.php';

  // File Extensions
  static const List<String> allowedImageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
  ];
  static const List<String> allowedDocumentExtensions = ['pdf', 'doc', 'docx'];
  static const double maxImageSize = 5; // MB
  static const double maxDocumentSize = 10; // MB

  // Pagination
  static const int defaultPageSize = 10;
  static const int maxPageSize = 50;

  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String displayDateFormat = 'dd/MM/yyyy';
  static const String displayTimeFormat = 'HH:mm';

  // Currency
  static const String currency = 'ريال';
  static const String currencySymbol = 'ر.ي';

  // Phone Number Format
  static const String phoneFormat = '###-###-####';
  static const String phonePrefix = '+967';

  // Social Media Links
  static const String facebookUrl = 'https://facebook.comasha_app';
  static const String twitterUrl = 'https://twitter.com/asha_app';
  static const String instagramUrl = 'https://instagram.com/asha_app';
  static const String websiteUrl = 'https://asha_app.com';

  // Support Information
  static const String supportEmail = 'asha_app@gmail.com';
  static const String supportPhone = '+967-771-746-678';
  static const String supportWhatsapp = '+967-771-746-678';

  // App Store Links
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.asha_app.app';
  static const String appStoreUrl =
      'https://apps.apple.com/app/asha_app/id123456789';

  // Privacy Policy and Terms
  static const String privacyPolicyUrl = 'https://asha_app.com/privacy';
  static const String termsOfServiceUrl = 'https://asha_app.com/terms';

  // Default Images
  static const String defaultUserImage = 'assets/images/default_user.png';
  static const String defaultServiceImage = 'assets/images/default_service.png';
  static const String defaultAdImage = 'assets/images/default_ad.png';
  static const String logoImage = 'assets/images/logo.png';

  // Notification Types
  static const String notificationBooking = 'booking';
  static const String notificationMessage = 'message';
  static const String notificationSystem = 'system';
  static const String notificationPromotion = 'promotion';

  // Payment Methods
  static const List<String> paymentMethods = [
    'بطاقة ائتمان',
    'بطاقة مدى',
    'Apple Pay',
    'Google Pay',
    'نقداً',
  ];

  // Rating Options
  static const List<int> ratingOptions = [1, 2, 3, 4, 5];

  // Booking Time Slots
  static const List<String> timeSlots = [
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
    '18:00',
    '19:00',
    '20:00',
  ];

  // Languages
  static const List<String> supportedLanguages = ['ar', 'en'];
  static const String defaultLanguage = 'ar';

  // Themes
  static const List<String> availableThemes = ['light', 'dark', 'system'];
  static const String defaultTheme = 'system';
}
