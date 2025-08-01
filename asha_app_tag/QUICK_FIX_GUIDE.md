# دليل إصلاح سريع لمشكلة الاتصال بالخادم

## المشكلة
```
Error loading categories: Exception: خطأ في تنسيق البيانات من الخادم - تأكد من أن الخادم يعمل بشكل صحيح
```

## الحلول السريعة

### 1. التحقق من تشغيل الخادم المحلي
```bash
# تأكد من تشغيل XAMPP أو WAMP أو أي خادم محلي
# يجب أن يكون Apache و MySQL يعملان
```

### 2. فحص قاعدة البيانات
افتح المتصفح واذهب إلى:
```
http://localhost/asha_app_tag/check_database.php
```

### 3. إنشاء قاعدة البيانات (إذا لم تكن موجودة)
افتح المتصفح واذهب إلى:
```
http://localhost/asha_app_tag/create_database.php
```

### 4. اختبار الاتصال البسيط
افتح المتصفح واذهب إلى:
```
http://localhost/asha_app_tag/simple_test.php
```

### 5. اختبار API الفئات
افتح المتصفح واذهب إلى:
```
http://localhost/asha_app_tag/api/categories/get_all.php
```

## إعدادات مهمة

### 1. تأكد من إعدادات config.php
```php
define('DB_HOST', '127.0.0.1'); // أو 'localhost'
define('DB_NAME', 'asha_app_events');
define('DB_USER', 'root');
define('DB_PASS', ''); // كلمة المرور إذا كانت موجودة
```

### 2. تأكد من تشغيل الخدمات
- Apache (الخادم)
- MySQL (قاعدة البيانات)
- PHP

### 3. فحص المسارات
تأكد من أن ملفات PHP موجودة في:
```
htdocs/asha_app_tag/
```

## خطوات التشخيص

1. **اختبار الخادم**: `simple_test.php`
2. **اختبار قاعدة البيانات**: `check_database.php`
3. **إنشاء قاعدة البيانات**: `create_database.php`
4. **اختبار API**: `api/categories/get_all.php`

## رسائل الخطأ الشائعة

### "خطأ في الاتصال بقاعدة البيانات"
- تأكد من تشغيل MySQL
- تحقق من إعدادات الاتصال في config.php

### "قاعدة البيانات غير موجودة"
- شغل create_database.php لإنشاء قاعدة البيانات

### "الخادم لا يعيد بيانات JSON صحيحة"
- تأكد من تشغيل Apache
- تحقق من مسار الملفات

## حل مشاكل Flutter

إذا كانت المشكلة في Flutter، تأكد من:

1. **إعدادات API في Flutter**:
```dart
static const String baseUrl = 'http://localhost/asha_app_tag';
```

2. **إضافة الأذونات في Android**:
```xml
<uses-permission android:name="android.permission.INTERNET" />
```

3. **إعدادات الشبكة في iOS**:
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## اختبار سريع

افتح المتصفح واختبر هذه الروابط بالترتيب:

1. `http://localhost/asha_app_tag/simple_test.php`
2. `http://localhost/asha_app_tag/check_database.php`
3. `http://localhost/asha_app_tag/api/categories/get_all.php`

إذا عملت جميعها، فالمشكلة في Flutter وليس في الخادم. 