# دليل تشغيل Backend في XAMPP

## 🚀 الخطوات السريعة

### 1. تثبيت XAMPP
- حمل XAMPP من: https://www.apachefriends.org/
- ثبت XAMPP مع الإعدادات الافتراضية

### 2. تشغيل XAMPP
- افتح XAMPP Control Panel
- اضغط **Start** على **Apache**
- اضغط **Start** على **MySQL**
- تأكد أن كليهما أخضر ✅

### 3. نقل الملفات
```bash
# انسخ مجلد backend_php إلى:
C:\xampp\htdocs\backend_php
```

### 4. إنشاء قاعدة البيانات
- افتح: http://localhost/phpmyadmin
- اضغط **New**
- اكتب: `asha`
- اختر: `utf8mb4_unicode_ci`
- اضغط **Create**

### 5. استيراد الجداول
- اختر قاعدة البيانات `asha`
- اضغط **Import**
- اختر ملف: `database/create_database.sql`
- اضغط **Go**

### 6. اختبار الاتصال
- اذهب إلى: http://localhost/backend_php/test_api.php
- يجب أن ترى رسالة نجاح ✅

### 7. اختبار API الفئات
- اذهب إلى: http://localhost/backend_php/api/services/get_categories.php
- يجب أن ترى قائمة الفئات في JSON ✅

## 🔧 إعدادات Flutter

### تعديل ملف config.dart
```dart
// في lib/config/config.dart
static const String apiBaseUrl = 'http://localhost/backend_php/api';
```

### إذا كنت تستخدم جهاز حقيقي
```dart
// غيّر localhost إلى IP جهازك
static const String apiBaseUrl = 'http://192.168.1.100/backend_php/api';
```

## 📱 اختبار التطبيق

### 1. شغل Flutter
```bash
flutter run
```

### 2. اختبر الوظائف
- تسجيل دخول
- تصفح الخدمات
- إضافة للمفضلة
- إنشاء حجز

## 🚨 حل المشاكل

### مشكلة: Apache لا يعمل
- تأكد من عدم استخدام المنفذ 80
- جرب تغيير المنفذ في httpd.conf

### مشكلة: MySQL لا يعمل
- تأكد من عدم استخدام المنفذ 3306
- تحقق من سجلات الأخطاء

### مشكلة: خطأ 404
- تأكد من نقل الملفات للمجلد الصحيح
- تحقق من ملف .htaccess

### مشكلة: خطأ في الاتصال
- تأكد من تشغيل Apache و MySQL
- تحقق من إعدادات database.php

## 📊 بيانات تسجيل الدخول

### المدير الافتراضي
- البريد: `admin@asha.com`
- كلمة المرور: `password`

## 🔗 روابط مفيدة

- XAMPP: http://localhost
- phpMyAdmin: http://localhost/phpmyadmin
- اختبار API: http://localhost/backend_php/test_api.php
- الفئات: http://localhost/backend_php/api/services/get_categories.php

## ✅ قائمة التحقق

- [ ] XAMPP مثبت ومشغل
- [ ] Apache يعمل (أخضر)
- [ ] MySQL يعمل (أخضر)
- [ ] ملفات backend_php منقولة
- [ ] قاعدة البيانات asha منشأة
- [ ] الجداول مستوردة
- [ ] API يعمل (اختبار)
- [ ] Flutter متصل بالـ backend
- [ ] التطبيق يعمل بدون أخطاء

## 🎯 النتيجة النهائية

بعد اتباع هذه الخطوات، سيكون لديك:
- ✅ Backend يعمل على XAMPP
- ✅ قاعدة بيانات كاملة
- ✅ APIs جاهزة للاستخدام
- ✅ Flutter متصل بالـ backend
- ✅ تطبيق يعمل بشكل كامل 