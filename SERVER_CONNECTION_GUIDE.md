# دليل حل مشكلة الاتصال بالخادم

## 🔍 **المشكلة الحالية:**

```
API Error: ClientException: Failed to fetch,
uri=http://localhost/asha_app_backend/auth/login.php
```

جميع الطلبات تفشل في الاتصال بالخادم المحلي.

## 🚨 **الخطوات العاجلة:**

### 1. **تأكد من تشغيل الخادم المحلي:**

**لـ XAMPP:**
1. افتح XAMPP Control Panel
2. اضغط "Start" بجانب Apache
3. اضغط "Start" بجانب MySQL
4. تأكد من أن المنفذ 80 متاح

**لـ WAMP:**
1. افتح WAMP
2. تأكد من أن Apache يعمل (أيقونة خضراء)
3. تأكد من أن MySQL يعمل

**لـ LAMP:**
```bash
sudo systemctl start apache2
sudo systemctl start mysql
sudo systemctl status apache2
```

### 2. **اختبار الاتصال في المتصفح:**

افتح المتصفح واذهب إلى:
```
http://localhost/asha_app_backend/test.php
```

**النتيجة المتوقعة:**
```json
{
  "success": true,
  "message": "Server is running!",
  "timestamp": "2024-01-15 10:30:00",
  "php_version": "8.1.0",
  "database": {
    "status": "connected",
    "message": "Database connection successful"
  }
}
```

### 3. **إذا لم يعمل localhost، جرب:**

```
http://127.0.0.1/asha_app_backend/test.php
```

### 4. **تغيير إعدادات Flutter:**

**في `lib/config/config.dart`:**
```dart
class Config {
  // جرب هذه الإعدادات بالترتيب:
  
  // الخيار 1: localhost
  static const String apiBaseUrl = 'http://localhost/asha_app_backend';
  
  // الخيار 2: 127.0.0.1
  // static const String apiBaseUrl = 'http://127.0.0.1/asha_app_backend';
  
  // الخيار 3: IP المحلي (ابحث عن IP جهازك)
  // static const String apiBaseUrl = 'http://192.168.1.100/asha_app_backend';
  
  // الخيار 4: منفذ مختلف
  // static const String apiBaseUrl = 'http://localhost:8080/asha_app_backend';
}
```

### 5. **اختبار الاتصال في Flutter:**

**أضف هذا الكود في أي صفحة:**
```dart
// في initState أو في دالة منفصلة
Future<void> testServerConnection() async {
  try {
    final result = await ApiService.testConnection();
    print('Connection test result: $result');
    
    if (result['success']) {
      print('✅ Server is working!');
    } else {
      print('❌ Server connection failed: ${result['message']}');
    }
  } catch (e) {
    print('❌ Error testing connection: $e');
  }
}
```

## 🔧 **حلول إضافية:**

### 1. **إذا كان المنفذ 80 محجوز:**
```bash
# في Windows، افتح Command Prompt كمسؤول
netstat -ano | findstr :80
taskkill /PID [PID_NUMBER] /F
```

### 2. **إذا كان Apache لا يعمل:**
```bash
# في XAMPP، اذهب إلى:
# C:\xampp\apache\logs\error.log
# اقرأ آخر الأخطاء
```

### 3. **إذا كان هناك مشكلة في CORS:**
الملف `asha_app_backend/config.php` يحتوي على إعدادات CORS صحيحة.

### 4. **إذا كان هناك مشكلة في قاعدة البيانات:**
```bash
# تأكد من تشغيل MySQL
# تأكد من وجود قاعدة البيانات asha_app
# تأكد من إعدادات الاتصال في config.php
```

## 📝 **خطوات التشخيص:**

### 1. **اختبار الخادم:**
```bash
# في المتصفح
http://localhost/asha_app_backend/test.php
```

### 2. **اختبار قاعدة البيانات:**
```bash
# في المتصفح
http://localhost/phpmyadmin
```

### 3. **اختبار Flutter:**
```dart
// في Flutter
final result = await ApiService.testConnection();
print(result);
```

### 4. **فحص السجلات:**
```bash
# XAMPP logs
C:\xampp\apache\logs\error.log
C:\xampp\mysql\data\mysql_error.log
```

## 🎯 **النتيجة المتوقعة:**

بعد تطبيق الحلول:
```
✅ Server is running!
✅ Database connected
✅ Flutter can connect
✅ Login works
✅ All API calls work
```

## 🚨 **إذا لم تعمل الحلول:**

1. **أعد تشغيل الخادم المحلي**
2. **أعد تشغيل Flutter**
3. **جرب IP مختلف**
4. **تحقق من جدار الحماية**
5. **تحقق من إعدادات الشبكة**

---

**بعد تطبيق هذه الخطوات، سيعمل الاتصال بالخادم بشكل صحيح!** 🎉 