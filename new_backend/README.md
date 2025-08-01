# Asha App Backend
# خلفية تطبيق عشا

## 📋 نظرة عامة

هذا هو الخادم الخلفي (Backend) لتطبيق عشا، مبني بلغة PHP مع قاعدة بيانات MySQL.

## 🏗️ هيكل المشروع

```
new_backend/
├── config.php                 # إعدادات قاعدة البيانات والتطبيق
├── database_schema.sql        # مخطط قاعدة البيانات
├── test_database.php          # اختبار قاعدة البيانات
├── api/                       # نقاط النهاية API
│   ├── auth/                  # المصادقة
│   │   ├── login.php
│   │   ├── register.php
│   │   ├── verify.php
│   │   ├── forgot_password.php
│   │   └── reset_password.php
│   ├── services/              # الخدمات
│   │   ├── get_all.php
│   │   ├── get_by_id.php
│   │   ├── add_service.php
│   │   └── update_service.php
│   ├── categories/            # الفئات
│   │   ├── get_all.php
│   │   └── get_services_by_category.php
│   ├── admin/                 # الإدارة
│   ├── provider/              # مزودي الخدمات
│   ├── user/                  # المستخدمين
│   ├── bookings/              # الحجوزات
│   ├── reviews/               # التقييمات
│   ├── ads/                   # الإعلانات
│   ├── notifications/         # الإشعارات
│   ├── messages/              # الرسائل
│   ├── payments/              # المدفوعات
│   └── uploads/               # رفع الملفات
├── uploads/                   # الملفات المرفوعة
│   ├── images/
│   ├── profiles/
│   ├── services/
│   └── ads/
├── logs/                      # سجلات النظام
└── docs/                      # الوثائق
```

## 🚀 التثبيت والإعداد

### المتطلبات الأساسية:
- PHP 7.4 أو أحدث
- MySQL 5.7 أو أحدث
- Apache/Nginx
- Composer (اختياري)

### خطوات التثبيت:

#### 1. نسخ الملفات إلى خادم الويب:
```bash
# في XAMPP
cp -r new_backend/ C:/xampp/htdocs/asha_app_h/

# في Linux
sudo cp -r new_backend/ /var/www/html/asha_app_h/
```

#### 2. إعداد قاعدة البيانات:
```bash
# إنشاء قاعدة البيانات
mysql -u root -p
CREATE DATABASE asha_app_db;
CREATE USER 'asha_app'@'localhost' IDENTIFIED BY 'app_password';
GRANT ALL PRIVILEGES ON asha_app_db.* TO 'asha_app'@'localhost';
FLUSH PRIVILEGES;
EXIT;

# استيراد مخطط قاعدة البيانات
mysql -u asha_app -p asha_app_db < database_schema.sql
```

#### 3. تعديل إعدادات الاتصال:
تحرير ملف `config.php` وتحديث:
- معلومات قاعدة البيانات
- إعدادات التطبيق
- مفاتيح الأمان

#### 4. اختبار التثبيت:
```
http://localhost/asha_app_h/test_database.php
```

## 🔧 الإعدادات

### ملف config.php:
```php
// إعدادات قاعدة البيانات
define('DB_HOST', 'localhost');
define('DB_NAME', 'asha_app_db');
define('DB_USER', 'asha_app');
define('DB_PASS', 'app_password');

// إعدادات التطبيق
define('APP_NAME', 'Asha App');
define('APP_URL', 'http://localhost/asha_app_h');
define('UPLOAD_PATH', __DIR__ . '/uploads/');

// إعدادات الأمان
define('JWT_SECRET', 'your-secret-key-here');
define('JWT_EXPIRY', 86400); // 24 ساعة
```

## 📡 نقاط النهاية API

### المصادقة:
- `POST /api/auth/login.php` - تسجيل الدخول
- `POST /api/auth/register.php` - إنشاء حساب
- `POST /api/auth/verify.php` - التحقق من الكود

### الخدمات:
- `GET /api/services/get_all.php` - جلب جميع الخدمات
- `GET /api/services/get_by_id.php` - جلب خدمة محددة
- `POST /api/services/add_service.php` - إضافة خدمة جديدة

### الفئات:
- `GET /api/categories/get_all.php` - جلب جميع الفئات

## 🔒 الأمان

### CORS:
يتم إعداد CORS تلقائياً لجميع الطلبات.

### التحقق من المدخلات:
جميع المدخلات يتم تنظيفها وتصفيتها.

### تشفير كلمات المرور:
يتم تشفير كلمات المرور باستخدام `password_hash()`.

### JWT Tokens:
يتم إنشاء وإدارة tokens للمصادقة.

## 📊 قاعدة البيانات

### الجداول الرئيسية:
- `users` - المستخدمين
- `categories` - فئات الخدمات
- `services` - الخدمات
- `bookings` - الحجوزات
- `reviews` - التقييمات
- `favorites` - المفضلة
- `ads` - الإعلانات

### العلاقات:
- كل خدمة تنتمي لفئة
- كل خدمة تنتمي لمزود خدمة
- كل حجز ينتمي لمستخدم وخدمة
- كل تقييم ينتمي لمستخدم وخدمة

## 🐛 استكشاف الأخطاء

### سجلات الأخطاء:
```
logs/error_log.txt
```

### اختبار الاتصال:
```
http://localhost/asha_app_h/test_database.php
```

### الأخطاء الشائعة:
1. **خطأ في الاتصال بقاعدة البيانات**: تحقق من إعدادات `config.php`
2. **خطأ في الصلاحيات**: تأكد من صلاحيات المجلدات
3. **خطأ في CORS**: تحقق من إعدادات الخادم

## 📝 التطوير

### إضافة نقطة نهاية جديدة:
1. إنشاء ملف PHP في المجلد المناسب
2. استخدام `require_once '../../config.php'`
3. إعداد CORS والتحقق من المدخلات
4. إرجاع JSON response

### مثال:
```php
<?php
require_once '../../config.php';

header('Content-Type: application/json; charset=utf-8');
setupCORS();

// منطق الكود هنا

echo json_encode(['success' => true, 'data' => $data]);
?>
```

## 📞 الدعم

للمساعدة والدعم:
- راجع ملف `test_database.php` للتحقق من التثبيت
- تحقق من سجلات الأخطاء في `logs/`
- تأكد من إعدادات الخادم وقاعدة البيانات

---

**ملاحظة:** تأكد من تحديث إعدادات الأمان قبل النشر في الإنتاج. 