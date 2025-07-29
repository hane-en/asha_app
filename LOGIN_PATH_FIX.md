# إصلاح مسار تسجيل الدخول

## 🔍 **المشكلة:**
```
API Request: POST http://127.0.0.1/asha_app_backend/auth/login.php
API Error: ClientException: Failed to fetch
```

الطلب يذهب إلى `auth/login.php` بدلاً من `api/auth/login.php`

## ✅ **السبب:**
في `ApiService` كانت الدوال تستدعي المسارات الخاطئة:
- `auth/login.php` بدلاً من `api/auth/login.php`
- `auth/register.php` بدلاً من `api/auth/register.php`
- وهكذا...

## 🔧 **الحل المطبق:**

### 1. **إصلاح دالة تسجيل الدخول:**
```dart
// في lib/services/api_service.dart
static Future<Map<String, dynamic>> login({
  required String email,
  required String password,
  String? userType,
}) async {
  try {
    final data = await _makeRequest(
      'api/auth/login.php', // تم إصلاح المسار
      body: json.encode({
        'email': email,
        'password': password,
        if (userType != null) 'user_type': userType,
      }),
      isPost: true,
    );
    return data;
  } catch (e) {
    print('Error logging in: $e');
    return {'success': false, 'message': e.toString()};
  }
}
```

### 2. **إصلاح باقي دوال المصادقة:**
```dart
// Register
'api/auth/register.php'

// Verify
'api/auth/verify.php'

// Forgot Password
'api/auth/forgot_password.php'

// Reset Password
'api/auth/reset_password.php'
```

## 🎯 **النتيجة المتوقعة:**

بعد التطبيق:
```
✅ API Request: POST http://127.0.0.1/asha_app_backend/api/auth/login.php
✅ Login successful
✅ User navigates to home page
```

## 📝 **خطوات الاختبار:**

**1. إعادة تشغيل Flutter:**
```bash
flutter clean
flutter pub get
flutter run
```

**2. اختبار تسجيل الدخول:**
- افتح التطبيق
- أدخل البيانات: `salma12@gmail.com` / `Salmaaaaa1`
- اضغط تسجيل الدخول

**3. التحقق من النتيجة:**
- يجب أن ينتقل إلى الصفحة الرئيسية
- يجب أن تظهر رسالة نجاح
- يجب ألا تظهر أخطاء في Console

---

**الآن جرب تسجيل الدخول في Flutter وأخبرني بالنتيجة!** 🎉

**المسار الصحيح الآن هو:**
```
http://127.0.0.1/asha_app_backend/api/auth/login.php
``` 