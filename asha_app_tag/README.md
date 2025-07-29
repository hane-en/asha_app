# Asha App Backend API

## نظرة عامة

Asha App Backend هو نظام خلفي شامل مطور بـ PHP لتطبيق خدمات الأعراس والمناسبات. يوفر API متكامل يدعم جميع وظائف التطبيق من المصادقة إلى إدارة الخدمات والحجوزات.

## المميزات الرئيسية

- **نظام مصادقة متكامل**: تسجيل دخول وخروج، تسجيل جديد، التحقق من الحساب
- **إدارة المستخدمين**: دعم ثلاثة أنواع من المستخدمين (عادي، مزود خدمة، مدير)
- **إدارة الخدمات**: إضافة، تعديل، حذف، وعرض الخدمات
- **نظام الحجوزات**: حجز الخدمات وإدارة المواعيد
- **نظام المفضلة**: إضافة وإزالة الخدمات من المفضلة
- **نظام التقييمات**: تقييم الخدمات وكتابة التعليقات
- **نظام الإشعارات**: إرسال الإشعارات للمستخدمين
- **لوحة إدارة**: إدارة شاملة للنظام
- **API RESTful**: واجهة برمجية متوافقة مع معايير REST

## متطلبات النظام

- PHP 7.4 أو أحدث
- MySQL 5.7 أو أحدث
- Apache أو Nginx
- مكتبة cURL
- مكتبة JSON

## التثبيت والإعداد

### 1. رفع الملفات

```bash
# رفع جميع ملفات المشروع إلى مجلد الخادم
cp -r asha_app_backend/ /var/www/html/
```

### 2. إعداد قاعدة البيانات

```sql
-- تشغيل ملف إعداد قاعدة البيانات
mysql -u root -p < database_setup.sql
```

### 3. تكوين الإعدادات

قم بتعديل ملف `config.php` وتحديث الإعدادات التالية:

```php
// إعدادات قاعدة البيانات
define('DB_HOST', 'localhost');
define('DB_NAME', 'asha_app');
define('DB_USER', 'your_username');
define('DB_PASS', 'your_password');

// إعدادات الأمان
define('JWT_SECRET', 'your-secret-key-here');

// إعدادات البريد الإلكتروني
define('SMTP_USERNAME', 'your-email@gmail.com');
define('SMTP_PASSWORD', 'your-password');
```

### 4. إعداد الصلاحيات

```bash
# إعداد صلاحيات مجلد الرفع
chmod 755 uploads/
chmod 755 logs/
```

## بنية المشروع

```
asha_app_backend/
├── api/                    # API endpoints
│   ├── auth/              # المصادقة
│   ├── users/             # المستخدمين
│   ├── services/          # الخدمات
│   ├── bookings/          # الحجوزات
│   ├── categories/        # الفئات
│   ├── favorites/         # المفضلة
│   ├── reviews/           # التقييمات
│   ├── notifications/     # الإشعارات
│   ├── admin/             # الإدارة
│   └── provider/          # مزودي الخدمات
├── models/                # نماذج البيانات
├── classes/               # الفئات المساعدة
├── uploads/               # ملفات الرفع
├── logs/                  # ملفات السجل
├── config.php             # التكوين الرئيسي
├── database.php           # إدارة قاعدة البيانات
├── auth.php               # المصادقة
├── middleware.php         # الوسطاء
├── error_handler.php      # معالجة الأخطاء
├── index.php              # الصفحة الرئيسية
├── test_api.php           # اختبار API
└── README.md              # هذا الملف
```

## استخدام API

### المصادقة

جميع الطلبات التي تتطلب مصادقة يجب أن تحتوي على رأس Authorization:

```
Authorization: Bearer {token}
```

### تنسيق الاستجابة

جميع الاستجابات تأتي بتنسيق JSON:

```json
{
  "success": true,
  "message": "رسالة النجاح",
  "data": {},
  "timestamp": "2024-01-01 12:00:00"
}
```

### أمثلة على الاستخدام

#### تسجيل مستخدم جديد

```bash
curl -X POST http://your-domain.com/api/auth/register.php \
  -H "Content-Type: application/json" \
  -d '{
    "name": "أحمد محمد",
    "email": "ahmed@example.com",
    "phone": "+967777777777",
    "password": "password123"
  }'
```

#### تسجيل الدخول

```bash
curl -X POST http://your-domain.com/api/auth/login.php \
  -H "Content-Type: application/json" \
  -d '{
    "email": "ahmed@example.com",
    "password": "password123"
  }'
```

#### جلب جميع الخدمات

```bash
curl -X GET http://your-domain.com/api/services/get_all.php
```

## الأمان

- تشفير كلمات المرور باستخدام bcrypt
- استخدام JWT للمصادقة
- حماية من هجمات SQL Injection
- تنظيف البيانات المدخلة
- معالجة شاملة للأخطاء
- تسجيل العمليات الحساسة

## الاختبار

لاختبار API، قم بزيارة:
```
http://your-domain.com/test_api.php?run_tests=1
```

## الدعم والمساعدة

للحصول على المساعدة أو الإبلاغ عن مشاكل، يرجى التواصل مع فريق التطوير.

## الترخيص

هذا المشروع مرخص تحت رخصة MIT.

