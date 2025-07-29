# حل سريع لمشكلة "خطأ غير معروف"

## 🚨 **المشكلة:**
```
API Error: ClientException: Failed to fetch
{success: false, message: خطأ غير معروف}
```

## ✅ **الحل السريع:**

### 1. **تأكد من تشغيل XAMPP:**
- افتح XAMPP Control Panel
- اضغط "Start" بجانب Apache
- اضغط "Start" بجانب MySQL
- تأكد من أن الأيقونات خضراء

### 2. **اختبار الخادم في المتصفح:**
```
http://localhost/asha_app_backend/test.php
```

### 3. **إذا لم يعمل، جرب:**
```
http://127.0.0.1/asha_app_backend/test.php
```

### 4. **تغيير إعدادات Flutter:**

**في `lib/config/config.dart`:**
```dart
class Config {
  // جرب هذا أولاً:
  static const String apiBaseUrl = 'http://127.0.0.1/asha_app_backend';
  
  // إذا لم يعمل، جرب:
  // static const String apiBaseUrl = 'http://localhost/asha_app_backend';
}
```

### 5. **إعادة تشغيل Flutter:**
```bash
flutter clean
flutter pub get
flutter run
```

## 🎯 **النتيجة المتوقعة:**
بعد التطبيق سيعمل تسجيل الدخول بدون أخطاء! 