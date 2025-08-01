# تعليمات تثبيت Asha App Backend
# Asha App Backend Setup Instructions

## 📋 المتطلبات الأساسية

### البرامج المطلوبة:
- **PHP 7.4** أو أحدث
- **MySQL 5.7** أو أحدث / **MariaDB 10.2** أو أحدث
- **Apache** أو **Nginx**
- **Composer** (اختياري)

### إضافات PHP المطلوبة:
- `ext-pdo`
- `ext-pdo_mysql`
- `ext-json`
- `ext-curl`
- `ext-mbstring`
- `ext-openssl`

## 🚀 خطوات التثبيت

### الخطوة 1: نسخ الملفات

#### في Windows (XAMPP):
```bash
# نسخ مجلد new_backend إلى htdocs
xcopy /E /I new_backend C:\xampp\htdocs\asha_app_h\
```

#### في Linux:
```bash
# نسخ مجلد new_backend إلى /var/www/html/
sudo cp -r new_backend /var/www/html/asha_app_h/
sudo chown -R www-data:www-data /var/www/html/asha_app_h/
sudo chmod -R 755 /var/www/html/asha_app_h/
```

### الخطوة 2: إعداد قاعدة البيانات

#### إنشاء قاعدة البيانات:
```sql
-- تسجيل الدخول إلى MySQL
mysql -u root -p

-- إنشاء قاعدة البيانات
CREATE DATABASE asha_app_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- إنشاء مستخدم للقاعدة
CREATE USER 'asha_app'@'localhost' IDENTIFIED BY 'app_password';

-- منح الصلاحيات
GRANT ALL PRIVILEGES ON asha_app_db.* TO 'asha_app'@'localhost';
FLUSH PRIVILEGES;

-- الخروج
EXIT;
```

#### استيراد مخطط قاعدة البيانات:
```bash
# في Windows
mysql -u asha_app -p asha_app_db < C:\xampp\htdocs\asha_app_h\database_schema.sql

# في Linux
mysql -u asha_app -p asha_app_db < /var/www/html/asha_app_h/database_schema.sql
```

### الخطوة 3: تعديل الإعدادات

#### نسخ ملف الإعدادات:
```bash
# نسخ ملف الإعدادات البيئية
cp env.example .env
```

#### تعديل ملف `config.php`:
```php
// تحديث إعدادات قاعدة البيانات
define('DB_HOST', 'localhost');
define('DB_NAME', 'asha_app_db');
define('DB_USER', 'asha_app');
define('DB_PASS', 'app_password');

// تحديث إعدادات التطبيق
define('APP_URL', 'http://localhost/asha_app_h');
define('JWT_SECRET', 'your-super-secret-jwt-key-here');
```

### الخطوة 4: إعداد الصلاحيات

#### في Linux:
```bash
# إعداد صلاحيات المجلدات
sudo chmod -R 755 /var/www/html/asha_app_h/
sudo chmod -R 777 /var/www/html/asha_app_h/uploads/
sudo chmod -R 777 /var/www/html/asha_app_h/logs/
```

#### في Windows:
```bash
# إعداد صلاحيات المجلدات (في PowerShell كمسؤول)
icacls "C:\xampp\htdocs\asha_app_h\uploads" /grant "Everyone:(OI)(CI)F"
icacls "C:\xampp\htdocs\asha_app_h\logs" /grant "Everyone:(OI)(CI)F"
```

### الخطوة 5: تثبيت التبعيات (اختياري)

#### تثبيت Composer:
```bash
# تحميل Composer
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
```

#### تثبيت التبعيات:
```bash
cd /var/www/html/asha_app_h/
composer install
```

## 🔧 اختبار التثبيت

### اختبار الاتصال بقاعدة البيانات:
```
http://localhost/asha_app_h/test_database.php
```

### اختبار API:
```bash
# اختبار تسجيل الدخول
curl -X POST http://localhost/asha_app_h/api/auth/login.php \
  -H "Content-Type: application/json" \
  -d '{"identifier":"admin@asha-app.com","password":"password","user_type":"admin"}'

# اختبار جلب الخدمات
curl -X GET http://localhost/asha_app_h/api/services/get_all.php

# اختبار جلب الفئات
curl -X GET http://localhost/asha_app_h/api/categories/get_all.php
```

## 🐛 استكشاف الأخطاء

### الأخطاء الشائعة:

#### 1. خطأ في الاتصال بقاعدة البيانات:
```bash
# التحقق من تشغيل MySQL
sudo systemctl status mysql

# التحقق من إعدادات الاتصال
mysql -u asha_app -p asha_app_db -e "SELECT 1;"
```

#### 2. خطأ في الصلاحيات:
```bash
# إعادة تعيين الصلاحيات
sudo chown -R www-data:www-data /var/www/html/asha_app_h/
sudo chmod -R 755 /var/www/html/asha_app_h/
```

#### 3. خطأ في CORS:
```bash
# التحقق من إعدادات Apache
sudo a2enmod headers
sudo systemctl restart apache2
```

#### 4. خطأ في PHP:
```bash
# التحقق من إصدار PHP
php -v

# التحقق من الإضافات المطلوبة
php -m | grep -E "(pdo|json|curl|mbstring|openssl)"
```

### سجلات الأخطاء:
```bash
# سجلات Apache
sudo tail -f /var/log/apache2/error.log

# سجلات PHP
sudo tail -f /var/log/php_errors.log

# سجلات التطبيق
tail -f /var/www/html/asha_app_h/logs/error.log
```

## 🔒 إعدادات الأمان

### تحديث كلمات المرور:
```sql
-- تحديث كلمة مرور المستخدم الإداري
UPDATE users SET password = '$2y$10$...' WHERE email = 'admin@asha-app.com';
```

### تحديث مفاتيح الأمان:
```php
// في ملف config.php
define('JWT_SECRET', 'your-new-super-secret-key');
define('ENCRYPTION_KEY', 'your-new-32-character-key');
```

### إعداد HTTPS:
```apache
# في ملف .htaccess
RewriteEngine On
RewriteCond %{HTTPS} off
RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
```

## 📊 مراقبة الأداء

### إعدادات PHP:
```ini
; في php.ini
memory_limit = 256M
max_execution_time = 300
upload_max_filesize = 10M
post_max_size = 10M
```

### إعدادات MySQL:
```sql
-- تحسين أداء قاعدة البيانات
SET GLOBAL innodb_buffer_pool_size = 256M;
SET GLOBAL query_cache_size = 64M;
```

## 📞 الدعم

### للمساعدة:
1. راجع ملف `test_database.php`
2. تحقق من سجلات الأخطاء
3. تأكد من إعدادات الخادم
4. اختبر جميع نقاط النهاية API

### معلومات الاتصال:
- **البريد الإلكتروني**: support@asha-app.com
- **الموقع**: https://asha-app.com
- **التوثيق**: https://docs.asha-app.com

---

**ملاحظة مهمة:** تأكد من تحديث جميع كلمات المرور ومفاتيح الأمان قبل النشر في الإنتاج. 