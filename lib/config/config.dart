import '../utils/helpers.dart';

class Config {
  // API Configuration
  static const String apiBaseUrl = 'http://localhost/new_backend';
  // static const String apiBaseUrl = 'http://localhost/asha_app_backend';
  // static const String apiBaseUrl = 'http://192.168.1.3/asha_app_backend';
  // إذا كنت على جهاز حقيقي، غيّرها إلى: http://192.168.x.x/backend_php/api

  // App Configuration
  static const String appName = ' تطبيق آشا';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'تطبيق خدمات المناسبات - تطبيق شامل لخدمات الأعراس وجميع المناسبات';
  static const String appAuthor = 'Asha Services Team';
  static const String appEmail = 'asha_app@gmail.com';

  // Timeout Configuration
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  static const int requestTimeout = 60000; // 60 seconds

  // Pagination Configuration
  static const int itemsPerPage = 10;
  static const int maxItemsPerPage = 50;
  static const int defaultPageSize = 20;

  // Image Configuration
  static const String defaultImageUrl = 'https://via.placeholder.com/300x200';
  static const double maxImageSize = 5; // MB
  static const List<String> allowedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
  ];
  static const int maxImageWidth = 1920;
  static const int maxImageHeight = 1080;

  // Validation Configuration
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minPhoneLength = 10;
  static const int maxPhoneLength = 15;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int minDescriptionLength = 10;
  static const int maxDescriptionLength = 500;
  static const double minPrice = 0;
  static const double maxPrice = 100000;

  // Cache Configuration
  static const int cacheExpirationHours = 24;
  static const int userSessionTimeout = 7200; // 2 hours in seconds
  static const int refreshTokenExpiration = 604800; // 7 days in seconds

  // Security Configuration
  static const int maxLoginAttempts = 5;
  static const int lockoutDuration = 900; // 15 minutes in seconds
  static const bool enableBiometricAuth = true;
  static const bool enableTwoFactorAuth = false;

  // Notification Configuration
  static const bool enablePushNotifications = true;
  static const bool enableEmailNotifications = true;
  static const bool enableSMSNotifications = false;
  static const int notificationRetryAttempts = 3;

  // File Upload Configuration
  static const int maxFileSize = 10; // MB
  static const List<String> allowedFileTypes = ['pdf', 'doc', 'docx', 'txt'];
  static const String uploadDirectory = 'uploads/';
  static const bool enableFileCompression = true;

  // Database Configuration
  static const int maxDatabaseConnections = 10;
  static const int databaseQueryTimeout = 30; // seconds
  static const bool enableDatabaseLogging = false;

  // Error Messages
  static const String networkErrorMessage = 'خطأ في الاتصال بالشبكة';
  static const String serverErrorMessage = 'خطأ في الخادم';
  static const String unknownErrorMessage = 'خطأ غير معروف';
  static const String validationErrorMessage = 'بيانات غير صحيحة';
  static const String authenticationErrorMessage = 'خطأ في المصادقة';
  static const String authorizationErrorMessage = 'غير مصرح لك بالوصول';
  static const String timeoutErrorMessage = 'انتهت مهلة الاتصال';
  static const String fileUploadErrorMessage = 'خطأ في رفع الملف';
  static const String databaseErrorMessage = 'خطأ في قاعدة البيانات';

  // Success Messages
  static const String loginSuccessMessage = 'تم تسجيل الدخول بنجاح';
  static const String registrationSuccessMessage = 'تم التسجيل بنجاح';
  static const String updateSuccessMessage = 'تم التحديث بنجاح';
  static const String deleteSuccessMessage = 'تم الحذف بنجاح';
  static const String saveSuccessMessage = 'تم الحفظ بنجاح';

  // User Roles
  static const String roleUser = 'user';
  static const String roleProvider = 'provider';
  static const String roleAdmin = 'admin';

  // Service Categories
  static const List<String> serviceCategories = [
    'تصوير',
    'مطاعم',
    'قاعات',
    'موسيقى',
    'ديكور',
    'نقل',
    'أخرى',
  ];

  // Booking Status
  static const String statusPending = 'pending';
  static const String statusConfirmed = 'confirmed';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';

  // Payment Methods
  static const List<String> paymentMethods = ['نقداً', 'بنك الكريمي'];

  // Payment Method Values
  static const String paymentMethodCash = 'cash';
  static const String paymentMethodKareemi = 'kareemi_bank';

  // Rating Configuration
  static const int minRating = 1;
  static const int maxRating = 5;
  static const double defaultRating = 0;

  // UI Configuration
  static const double defaultPadding = 16;
  static const double defaultMargin = 8;
  static const double defaultBorderRadius = 8;
  static const double defaultElevation = 2;
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);

  // Colors (for reference)
  static const int primaryColorValue = 0xFF2196F3;
  static const int secondaryColorValue = 0xFF1976D2;
  static const int accentColorValue = 0xFF03A9F4;
  static const int errorColorValue = 0xFFD32F2F;
  static const int successColorValue = 0xFF388E3C;
  static const int warningColorValue = 0xFFF57C00;
  static const int infoColorValue = 0xFF1976D2;

  // Environment Configuration
  static const bool isDevelopment = true;
  static const bool isProduction = false;
  static const bool enableDebugMode = true;
  static const bool enableLogging = true;

  // Feature Flags
  static const bool enableAdvancedSearch = true;
  static const bool enableFilters = true;
  static const bool enableSorting = true;
  static const bool enablePagination = true;
  static const bool enableInfiniteScroll = false;
  static const bool enableOfflineMode = false;
  static const bool enableDataSync = true;
}
