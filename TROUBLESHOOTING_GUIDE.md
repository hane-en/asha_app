# دليل حل مشاكل الاتصال والشبكة

## مشاكل شائعة وحلولها

### 1. خطأ الاتصال بالشبكة (statusCode: 0)

#### الأسباب المحتملة:
- عدم وجود اتصال بالإنترنت
- الخادم المحلي غير متاح
- إعدادات API غير صحيحة
- مشكلة في إعدادات الشبكة

#### الحلول:

##### أ. التحقق من الاتصال بالإنترنت
```bash
# في Windows
ping google.com

# في Linux/Mac
ping -c 4 google.com
```

##### ب. التحقق من الخادم المحلي
1. تأكد من أن XAMPP/WAMP يعمل
2. تحقق من أن Apache و MySQL نشطان
3. افتح المتصفح واذهب إلى: `http://127.0.0.1/asha_app_tag`

##### ج. التحقق من إعدادات API
افتح ملف `lib/config/config.dart` وتأكد من:
```dart
static const String apiBaseUrl = 'http://127.0.0.1/asha_app_tag';
```

### 2. خطأ في الخادم (500 Internal Server Error)

#### الأسباب المحتملة:
- خطأ في كود PHP
- مشكلة في قاعدة البيانات
- إعدادات PHP غير صحيحة

#### الحلول:

##### أ. التحقق من سجلات الخطأ
- افتح ملف `error.log` في مجلد Apache
- ابحث عن الأخطاء المتعلقة بـ PHP

##### ب. التحقق من قاعدة البيانات
```sql
-- تأكد من وجود الجداول
SHOW TABLES;

-- تحقق من اتصال قاعدة البيانات
SELECT 1;
```

##### ج. اختبار API مباشرة
```bash
curl -X GET "http://127.0.0.1/asha_app_tag/api/providers/get_by_category.php?category_id=1"
```

### 3. خطأ في التطبيق (Flutter)

#### الأسباب المحتملة:
- مشكلة في التبعيات
- خطأ في الكود
- مشكلة في إعدادات التطبيق

#### الحلول:

##### أ. تنظيف وإعادة بناء التطبيق
```bash
flutter clean
flutter pub get
flutter run
```

##### ب. التحقق من التبعيات
```bash
flutter doctor
flutter pub deps
```

##### ج. اختبار الاتصال
أضف هذا الكود في `main.dart` للاختبار:
```dart
import 'package:http/http.dart' as http;

Future<void> testConnection() async {
  try {
    final response = await http.get(
      Uri.parse('http://127.0.0.1/asha_app_tag/api/categories/get_all.php'),
    );
    print('Status Code: ${response.statusCode}');
    print('Response: ${response.body}');
  } catch (e) {
    print('Error: $e');
  }
}
```

### 4. مشاكل في قاعدة البيانات

#### الأسباب المحتملة:
- قاعدة البيانات غير موجودة
- الجداول غير موجودة
- مشكلة في الصلاحيات

#### الحلول:

##### أ. إنشاء قاعدة البيانات
```sql
CREATE DATABASE IF NOT EXISTS asha_app;
USE asha_app;
```

##### ب. إنشاء الجداول المطلوبة
```sql
-- جدول الفئات
CREATE TABLE categories (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    icon VARCHAR(100),
    color VARCHAR(7),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- جدول المستخدمين
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    password VARCHAR(255) NOT NULL,
    user_type ENUM('user', 'provider', 'admin') DEFAULT 'user',
    is_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    rating DECIMAL(3,2) DEFAULT 0.00,
    total_reviews INT DEFAULT 0,
    profile_image VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- جدول الخدمات
CREATE TABLE services (
    id INT PRIMARY KEY AUTO_INCREMENT,
    provider_id INT NOT NULL,
    category_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    rating DECIMAL(3,2) DEFAULT 0.00,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (provider_id) REFERENCES users(id),
    FOREIGN KEY (category_id) REFERENCES categories(id)
);
```

### 5. إعدادات الشبكة

#### للاختبار على جهاز حقيقي:

##### أ. تغيير إعدادات API
```dart
// في lib/config/config.dart
static const String apiBaseUrl = 'http://192.168.1.100/asha_app_tag';
// استبدل 192.168.1.100 بـ IP جهازك
```

##### ب. العثور على IP جهازك
```bash
# في Windows
ipconfig

# في Linux/Mac
ifconfig
```

##### ج. إعدادات الأمان
- تأكد من أن جدار الحماية يسمح بالاتصال
- تحقق من إعدادات CORS في PHP

### 6. خطوات التشخيص

#### أ. اختبار الاتصال خطوة بخطوة:
1. اختبار الاتصال بالإنترنت
2. اختبار الخادم المحلي
3. اختبار قاعدة البيانات
4. اختبار API endpoints
5. اختبار التطبيق

#### ب. جمع معلومات التشخيص:
```dart
print('API Base URL: ${Config.apiBaseUrl}');
print('Category ID: $categoryId');
print('Category Name: $categoryName');
print('Timestamp: ${DateTime.now()}');
```

#### ج. سجلات التطبيق:
- استخدم `print()` للتصحيح
- تحقق من سجلات Flutter
- راجع سجلات الخادم

### 7. حلول سريعة

#### إذا كان الخادم لا يعمل:
1. أعد تشغيل XAMPP/WAMP
2. تحقق من منافذ Apache (80) و MySQL (3306)
3. تأكد من عدم وجود تطبيقات أخرى تستخدم نفس المنافذ

#### إذا كان التطبيق لا يتصل:
1. أعد تشغيل التطبيق
2. امسح ذاكرة التخزين المؤقت
3. تحقق من إعدادات الشبكة

#### إذا كانت قاعدة البيانات فارغة:
1. أضف بيانات تجريبية
2. تحقق من وجود الجداول
3. تأكد من الصلاحيات

## معلومات الاتصال

### إعدادات الخادم الافتراضية:
- **Apache Port**: 80
- **MySQL Port**: 3306
- **PHP Version**: 7.4+
- **Database**: MySQL 5.7+

### إعدادات التطبيق الافتراضية:
- **API Base URL**: http://127.0.0.1/asha_app_tag
- **Timeout**: 30 seconds
- **Retry Attempts**: 3

### معلومات الاتصال للتطوير:
- **Local Development**: http://127.0.0.1/asha_app_tag
- **Network Development**: http://192.168.x.x/asha_app_tag
- **Production**: https://your-domain.com/api 