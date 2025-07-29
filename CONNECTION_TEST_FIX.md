# حل مشكلة الاتصال بالخادم

## 🔍 **المشكلة:**

```
API Error: ClientException: Failed to fetch,
uri=http://localhost/asha_app_backend/auth/login.php
```

جميع الطلبات تفشل في الاتصال بالخادم المحلي.

## 🐛 **الأسباب:**

### 1. **الخادم المحلي لا يعمل:**
- XAMPP/WAMP/LAMP غير مشغل
- Apache/PHP غير مشغل
- المنفذ 80 محجوز

### 2. **إعدادات URL خاطئة:**
- `http://localhost/asha_app_backend` لا يعمل
- قد يحتاج إلى `http://127.0.0.1/asha_app_backend`

### 3. **مشكلة في CORS:**
- الخادم لا يسمح بالطلبات من Flutter
- إعدادات CORS غير صحيحة

## ✅ **الحلول:**

### 1. **تأكد من تشغيل الخادم المحلي:**

**لـ XAMPP:**
```bash
# تشغيل XAMPP Control Panel
# تشغيل Apache و MySQL
```

**لـ WAMP:**
```bash
# تشغيل WAMP
# التأكد من أن Apache يعمل
```

**لـ LAMP:**
```bash
sudo systemctl start apache2
sudo systemctl start mysql
```

### 2. **اختبار الاتصال:**

**في المتصفح:**
```
http://localhost/asha_app_backend/
http://localhost/asha_app_backend/api/auth/login.php
```

**في Flutter:**
```dart
// إضافة اختبار الاتصال
static Future<bool> testConnection() async {
  try {
    final response = await http.get(
      Uri.parse('${Config.apiBaseUrl}/test.php'),
      headers: {'Content-Type': 'application/json'},
    );
    return response.statusCode == 200;
  } catch (e) {
    print('Connection test failed: $e');
    return false;
  }
}
```

### 3. **إصلاح إعدادات URL:**

**في `lib/config/config.dart`:**
```dart
class Config {
  // جرب هذه الإعدادات:
  
  // الخيار 1: localhost
  static const String apiBaseUrl = 'http://localhost/asha_app_backend';
  
  // الخيار 2: 127.0.0.1
  // static const String apiBaseUrl = 'http://127.0.0.1/asha_app_backend';
  
  // الخيار 3: IP المحلي
  // static const String apiBaseUrl = 'http://192.168.1.100/asha_app_backend';
  
  // الخيار 4: منفذ مختلف
  // static const String apiBaseUrl = 'http://localhost:8080/asha_app_backend';
}
```

### 4. **إضافة ملف اختبار الاتصال:**

**إنشاء `asha_app_backend/test.php`:**
```php
<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE');
header('Access-Control-Allow-Headers: Content-Type');

echo json_encode([
    'success' => true,
    'message' => 'Server is running!',
    'timestamp' => date('Y-m-d H:i:s'),
    'php_version' => PHP_VERSION,
    'server' => $_SERVER['SERVER_SOFTWARE'] ?? 'Unknown'
]);
?>
```

### 5. **إصلاح CORS في الخادم:**

**في `asha_app_backend/config.php`:**
```php
<?php
// إضافة CORS headers
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');

// معالجة preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// باقي الكود...
?>
```

### 6. **إضافة اختبار الاتصال في Flutter:**

**في `lib/services/api_service.dart`:**
```dart
// إضافة دالة اختبار الاتصال
static Future<Map<String, dynamic>> testConnection() async {
  try {
    final data = await _makeRequest('test.php');
    return {
      'success': true,
      'message': 'اتصال ناجح',
      'data': data,
    };
  } catch (e) {
    return {
      'success': false,
      'message': 'فشل في الاتصال: $e',
    };
  }
}
```

## 🔧 **خطوات الإصلاح:**

### 1. **تأكد من تشغيل الخادم:**
```bash
# فتح المتصفح وزيارة:
http://localhost/asha_app_backend/test.php
```

### 2. **اختبار في Flutter:**
```dart
// في أي صفحة، أضف:
final result = await ApiService.testConnection();
print('Connection test: $result');
```

### 3. **تغيير URL إذا لزم الأمر:**
```dart
// في config.dart، جرب:
static const String apiBaseUrl = 'http://127.0.0.1/asha_app_backend';
// أو
static const String apiBaseUrl = 'http://192.168.1.100/asha_app_backend';
```

### 4. **إضافة ملف test.php:**
```php
<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

echo json_encode([
    'success' => true,
    'message' => 'Server is running!',
    'timestamp' => date('Y-m-d H:i:s')
]);
?>
```

## 📝 **التحقق من الإصلاح:**

1. ✅ **تشغيل الخادم المحلي**
2. ✅ **اختبار في المتصفح**
3. ✅ **اختبار في Flutter**
4. ✅ **إصلاح CORS**
5. ✅ **تغيير URL إذا لزم الأمر**

## 🎯 **النتيجة المتوقعة:**

```
API Request: GET http://localhost/asha_app_backend/test.php
API Response: 200 - {"success":true,"message":"Server is running!"}
```

---

**بعد تطبيق هذه الحلول، سيعمل الاتصال بالخادم بشكل صحيح!** 🎉 