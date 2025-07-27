import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';
import 'dart:io' show Platform, SocketException;
import 'dart:io' show InternetAddress;
import 'dart:math';
import 'dart:convert';

class Helpers {
  // تنسيق التاريخ
  static String formatDate(DateTime date, {String format = 'dd/MM/yyyy'}) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  // تنسيق الوقت
  static String formatTime(DateTime time, {String format = 'HH:mm'}) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  // تنسيق التاريخ والوقت
  static String formatDateTime(
    DateTime dateTime, {
    String format = 'dd/MM/yyyy HH:mm',
  }) => '${formatDate(dateTime)} ${formatTime(dateTime)}';

  // تنسيق السعر
  static String formatPrice(double price) =>
      '${price.toStringAsFixed(2)} ${AppConstants.currency}';

  static String convertArabicNumbers(String input) {
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    for (int i = 0; i < arabic.length; i++) {
      input = input.replaceAll(arabic[i], english[i]);
    }
    return input.replaceAll(RegExp(r'[^0-9]'), '');
  }

  static String formatPhoneNumber(String phone) {
    final clean = convertArabicNumbers(phone);
    final validPrefixes = ['77', '78', '70', '73', '71'];
    if (clean.length == 9 &&
        validPrefixes.any((prefix) => clean.startsWith(prefix))) {
      return '${clean.substring(0, 3)}-${clean.substring(3, 6)}-${clean.substring(6)}';
    }
    return clean;
  }

  // تنظيف رقم الهاتف
  static String cleanPhoneNumber(String phone) =>
      phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

  // التحقق من صحة البريد الإلكتروني
  static bool isValidEmail(String email) =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

  static bool isValidPhone(String phone) {
    final clean = convertArabicNumbers(phone).replaceAll(RegExp(r'[^0-9]'), '');
    return RegExp(r'^(77|78|70|71|73)[0-9]{7}$').hasMatch(clean);
  }

  // الحصول على لون الفئة
  static Color getCategoryColor(String category) {
    final colorValue = AppConstants.categoryColors[category] ?? 0xFF795548;
    return Color(colorValue);
  }

  // الحصول على أيقونة الفئة
  static String getCategoryIcon(String category) =>
      AppConstants.categoryIcons[category] ?? '📋';

  // الحصول على نص حالة الحجز
  static String getBookingStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'في الانتظار';
      case 'confirmed':
        return 'مؤكد';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }

  // الحصول على لون حالة الحجز
  static Color getBookingStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // الحصول على نص دور المستخدم
  static String getUserRoleText(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'مدير النظام';
      case 'provider':
        return 'مزود الخدمة';
      case 'user':
        return 'مستخدم';
      default:
        return 'مستخدم';
    }
  }

  // الحصول على أيقونة دور المستخدم
  static IconData getUserRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'provider':
        return Icons.business;
      case 'user':
        return Icons.person;
      default:
        return Icons.person;
    }
  }

  // تحويل حجم الملف إلى نص مقروء
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  // الحصول على الوقت المنقضي
  static String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

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

  // الحصول على اليوم بالعربية
  static String getArabicDay(int day) {
    switch (day) {
      case 1:
        return 'الأحد';
      case 2:
        return 'الاثنين';
      case 3:
        return 'الثلاثاء';
      case 4:
        return 'الأربعاء';
      case 5:
        return 'الخميس';
      case 6:
        return 'الجمعة';
      case 7:
        return 'السبت';
      default:
        return '';
    }
  }

  // الحصول على الشهر بالعربية
  static String getArabicMonth(int month) {
    switch (month) {
      case 1:
        return 'يناير';
      case 2:
        return 'فبراير';
      case 3:
        return 'مارس';
      case 4:
        return 'أبريل';
      case 5:
        return 'مايو';
      case 6:
        return 'يونيو';
      case 7:
        return 'يوليو';
      case 8:
        return 'أغسطس';
      case 9:
        return 'سبتمبر';
      case 10:
        return 'أكتوبر';
      case 11:
        return 'نوفمبر';
      case 12:
        return 'ديسمبر';
      default:
        return '';
    }
  }

  // تنسيق التاريخ بالعربية
  static String formatDateArabic(DateTime date) =>
      '${getArabicDay(date.weekday)} ${date.day} ${getArabicMonth(date.month)} ${date.year}';

  // الحصول على تقييم النجوم
  static Widget buildRatingStars(double rating, {double size = 20}) => Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(5, (index) {
      if (index < rating.floor()) {
        return Icon(Icons.star, color: Colors.amber, size: size);
      } else if (index == rating.floor() && rating % 1 > 0) {
        return Icon(Icons.star_half, color: Colors.amber, size: size);
      } else {
        return Icon(Icons.star_border, color: Colors.amber, size: size);
      }
    }),
  );

  // الحصول على لون التقييم
  static Color getRatingColor(double rating) {
    if (rating >= 4.5) {
      return Colors.green;
    } else if (rating >= 3.5) {
      return Colors.blue;
    } else if (rating >= 2.5) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  // الحصول على نص التقييم
  static String getRatingText(double rating) {
    if (rating >= 4.5) {
      return 'ممتاز';
    } else if (rating >= 3.5) {
      return 'جيد جداً';
    } else if (rating >= 2.5) {
      return 'جيد';
    } else if (rating >= 1.5) {
      return 'مقبول';
    } else {
      return 'ضعيف';
    }
  }

  // التحقق من صحة الرابط
  static bool isValidUrl(String url) {
    try {
      Uri.parse(url);
      return true;
    } catch (e) {
      return false;
    }
  }

  // الحصول على امتداد الملف
  static String getFileExtension(String fileName) =>
      fileName.split('.').last.toLowerCase();

  // التحقق من نوع الملف
  static bool isImageFile(String fileName) {
    final extension = getFileExtension(fileName);
    return AppConstants.allowedImageExtensions.contains(extension);
  }

  static bool isDocumentFile(String fileName) {
    final extension = getFileExtension(fileName);
    return AppConstants.allowedDocumentExtensions.contains(extension);
  }

  // الحصول على اسم الملف بدون امتداد
  static String getFileNameWithoutExtension(String fileName) =>
      fileName.split('.').first;

  // تقصير النص
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }

  // الحصول على أول حرف من النص
  static String getInitials(String text) {
    if (text.isEmpty) return '';
    final words = text.trim().split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return text[0].toUpperCase();
  }

  // الحصول على لون عشوائي
  static Color getRandomColor() {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    return colors[DateTime.now().millisecond % colors.length];
  }

  // التحقق من الاتصال بالإنترنت
  static Future<bool> checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  // الحصول على معلومات الجهاز
  static String getDeviceInfo() =>
      '${Platform.operatingSystem} ${Platform.operatingSystemVersion}';

  // تنسيق رقم الهاتف للعرض
  static String formatPhoneForDisplay(String phone) {
    final clean = cleanPhoneNumber(phone);
    if (clean.startsWith('967')) {
      return '+967 ${clean.substring(3, 6)} ${clean.substring(6, 9)} ${clean.substring(9)}';
    }
    return formatPhoneNumber(phone);
  }

  // الحصول على وقت اليوم
  static String getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'صباحاً';
    } else if (hour < 17) {
      return 'ظهراً';
    } else {
      return 'مساءً';
    }
  }

  // الحصول على التوكن المحفوظ
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      return null;
    }
  }

  // حفظ التوكن
  static Future<bool> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString('auth_token', token);
    } catch (e) {
      return false;
    }
  }

  // حذف التوكن
  static Future<bool> removeToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove('auth_token');
    } catch (e) {
      return false;
    }
  }

  // التحقق من وجود توكن
  static Future<bool> hasToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey('auth_token');
    } catch (e) {
      return false;
    }
  }

  // تنسيق العملة
  static String formatCurrency(double amount, {String currency = 'ريال'}) =>
      '${amount.toStringAsFixed(2)} $currency';

  // التحقق من صحة رقم الهاتف اليمني
  static bool isValidYemenPhone(String phone) {
    final clean = cleanPhoneNumber(phone);
    final validPrefixes = ['77', '78', '70', '73', '71'];
    return clean.length == 9 &&
        validPrefixes.any((prefix) => clean.startsWith(prefix));
  }

  // تنسيق رقم الهاتف اليمني
  static String formatYemenPhone(String phone) {
    final clean = cleanPhoneNumber(phone);
    final validPrefixes = ['77', '78', '70', '73', '71'];
    if (clean.length == 9 &&
        validPrefixes.any((prefix) => clean.startsWith(prefix))) {
      return '+967 ${clean.substring(0, 3)} ${clean.substring(3, 6)} ${clean.substring(6)}';
    }
    return clean;
  }

  // الحصول على لون الحالة
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  // الحصول على نص الحالة
  static String getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'في الانتظار';
      case 'confirmed':
        return 'مؤكد';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      case 'active':
        return 'نشط';
      case 'inactive':
        return 'غير نشط';
      default:
        return status;
    }
  }

  // توليد نص عشوائي
  static String generateRandomString(int length) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  // تحويل أول حرف إلى كبير
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // تقصير النص
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }

  // إزالة وسوم HTML
  static String removeHtmlTags(String html) =>
      html.replaceAll(RegExp(r'<[^>]*>'), '');

  // التحقق من صحة ملف الصورة
  static bool isValidImageFile(String fileName) {
    final extension = getFileExtension(fileName).toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(extension);
  }

  // تحليل JSON
  static Map<String, dynamic>? parseJson(String jsonString) {
    try {
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  // ترميز JSON
  static String? encodeJson(Map<String, dynamic> data) {
    try {
      return json.encode(data);
    } catch (e) {
      return null;
    }
  }
}

class ThemeNotifier extends ChangeNotifier {
  ThemeNotifier() {
    _loadFromPrefs();
  }
  static const String key = 'isDarkMode';
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, _isDarkMode);
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    notifyListeners();
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, _isDarkMode);
  }

  Future<void> _loadFromPrefs() async {
    var prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(key) ?? false;
    notifyListeners();
  }
}
