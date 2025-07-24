# Asha Services - Backend API

## نظرة عامة
هذا هو الـ backend للتطبيق Asha Services، مبني بـ PHP مع قاعدة بيانات MySQL.

## المتطلبات
- PHP 7.4 أو أحدث
- MySQL 5.7 أو أحدث
- Apache/Nginx web server
- Composer (اختياري)

## التثبيت

### 1. إعداد قاعدة البيانات
```bash
# قم بتشغيل ملف التثبيت
php install.php
```

### 2. إعداد الإعدادات
قم بتعديل ملف `config/database.php` حسب إعدادات قاعدة البيانات لديك:
```php
define('DB_HOST', 'localhost');
define('DB_NAME', 'asha');
define('DB_USER', 'root');
define('DB_PASS', '');
```

### 3. إعداد JWT Secret
قم بتعديل `JWT_SECRET` في ملف `config/config.php`:
```php
define('JWT_SECRET', 'your-secret-key-here-change-in-production');
```

## هيكل المشروع

```
backend_php/
├── config/
│   ├── database.php      # إعدادات قاعدة البيانات
│   └── config.php        # إعدادات التطبيق
├── api/
│   ├── auth/             # APIs للمصادقة
│   ├── services/         # APIs للخدمات
│   ├── bookings/         # APIs للحجوزات
│   ├── provider/         # APIs لمزودي الخدمات
│   ├── admin/            # APIs للمديرين
│   ├── user/             # APIs للمستخدمين
│   ├── reviews/          # APIs للتقييمات
│   ├── notifications/    # APIs للإشعارات
│   └── messages/         # APIs للرسائل
├── database/
│   └── create_database.sql  # ملف إنشاء قاعدة البيانات
├── uploads/              # مجلد رفع الملفات
├── install.php           # ملف التثبيت
└── README.md
```

## APIs المتاحة

### المصادقة (Authentication)
- `POST /api/auth/register.php` - تسجيل مستخدم جديد
- `POST /api/auth/login.php` - تسجيل دخول المستخدم
- `POST /api/auth/provider_login.php` - تسجيل دخول مزود الخدمة
- `POST /api/auth/admin_login.php` - تسجيل دخول المدير
- `POST /api/auth/forgot_password.php` - نسيان كلمة المرور
- `POST /api/auth/reset_password.php` - إعادة تعيين كلمة المرور

### الخدمات (Services)
- `GET /api/services/get_categories.php` - جلب الفئات
- `GET /api/services/get_services.php` - جلب الخدمات
- `GET /api/services/get_service_details.php` - تفاصيل الخدمة

### الحجوزات (Bookings)
- `POST /api/bookings/create_booking.php` - إنشاء حجز جديد
- `GET /api/bookings/get_user_bookings.php` - حجوزات المستخدم

### مزودي الخدمات (Providers)
- `POST /api/provider/add_service.php` - إضافة خدمة جديدة

### المديرين (Admins)
- `GET /api/admin/get_dashboard_stats.php` - إحصائيات لوحة التحكم
- `GET/PUT /api/admin/manage_provider_requests.php` - إدارة طلبات الانضمام

### المستخدمين (Users)
- `POST /api/user/join_provider.php` - طلب الانضمام كمزود خدمة
- `POST /api/user/add_to_favorites.php` - إضافة للمفضلة
- `GET /api/user/get_favorites.php` - جلب المفضلة
- `DELETE /api/user/remove_from_favorites.php` - حذف من المفضلة

### التقييمات (Reviews)
- `POST /api/reviews/add_review.php` - إضافة تقييم

### الإشعارات (Notifications)
- `GET /api/notifications/get_notifications.php` - جلب الإشعارات
- `PUT /api/notifications/mark_as_read.php` - تحديد كمقروء

### الرسائل (Messages)
- `POST /api/messages/send_message.php` - إرسال رسالة
- `GET /api/messages/get_messages.php` - جلب الرسائل

## قاعدة البيانات

### الجداول الرئيسية
- `users` - المستخدمين
- `categories` - الفئات
- `services` - الخدمات
- `bookings` - الحجوزات
- `reviews` - التقييمات
- `favorites` - المفضلة
- `provider_requests` - طلبات الانضمام
- `notifications` - الإشعارات
- `messages` - الرسائل
- `ads` - الإعلانات

## الأمان

### JWT Authentication
جميع APIs (باستثناء تسجيل الدخول والتسجيل) تتطلب JWT token في header:
```
Authorization: Bearer <token>
```

### CORS
تم إعداد CORS للسماح بالطلبات من أي مصدر. في الإنتاج، قم بتقييد المصادر المسموحة.

### Validation
جميع المدخلات يتم التحقق من صحتها وتنظيفها قبل المعالجة.

## الاستخدام

### مثال لطلب API
```javascript
// تسجيل الدخول
const response = await fetch('/backend_php/api/auth/login.php', {
    method: 'POST',
    headers: {
        'Content-Type': 'application/json',
    },
    body: JSON.stringify({
        email: 'user@example.com',
        password: 'password'
    })
});

const data = await response.json();
const token = data.token;

// استخدام API محمي
const protectedResponse = await fetch('/backend_php/api/services/get_services.php', {
    headers: {
        'Authorization': `Bearer ${token}`
    }
});
```

## بيانات تسجيل الدخول الافتراضية

### المدير
- البريد الإلكتروني: `admin@asha.com`
- كلمة المرور: `password`

**تحذير:** قم بتغيير كلمة مرور المدير بعد التثبيت!

## استكشاف الأخطاء

### مشاكل شائعة
1. **خطأ في الاتصال بقاعدة البيانات**
   - تحقق من إعدادات قاعدة البيانات
   - تأكد من تشغيل MySQL

2. **خطأ في JWT**
   - تحقق من JWT_SECRET في config.php
   - تأكد من صحة الـ token

3. **خطأ في CORS**
   - تحقق من إعدادات CORS في config.php

### السجلات (Logs)
الأخطاء يتم تسجيلها في PHP error log. تحقق من:
- Apache error log
- PHP error log
- Custom error handling في الكود

## المساهمة
1. Fork المشروع
2. إنشاء branch جديد
3. Commit التغييرات
4. Push إلى branch
5. إنشاء Pull Request

## الترخيص
هذا المشروع مرخص تحت MIT License. 