# توثيق شامل لمشروع Asha App - تطبيق خدمات الأعراس والمناسبات

## نظرة عامة على المشروع

**اسم المشروع:** Asha App  
**نوع التطبيق:** تطبيق Flutter للهواتف المحمولة  
**الغرض:** منصة رقمية لربط مزودي خدمات الأعراس والمناسبات مع العملاء  
**اللغة الأساسية:** Dart (Flutter)  
**قاعدة البيانات:** MySQL  

## قاعدة البيانات (Database)

### اسم قاعدة البيانات: `asha_app`

### الجداول والحقول:

#### 1. جدول المستخدمين (users)
```sql
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    user_type ENUM('user', 'provider', 'admin') DEFAULT 'user',
    profile_image VARCHAR(500),
    is_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    verification_code VARCHAR(10),
    last_login_at DATETIME,
    device_token VARCHAR(255),
    preferences JSON,
    rating DECIMAL(3,2) DEFAULT 0.00,
    review_count INT DEFAULT 0,
    bio TEXT,
    website VARCHAR(255),
    social_media JSON,
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    address TEXT,
    city VARCHAR(100),
    user_category VARCHAR(100),
    is_yemeni_account BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

#### 2. جدول الفئات (categories)
```sql
CREATE TABLE categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    image VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### 3. جدول الخدمات (services)
```sql
CREATE TABLE services (
    id INT AUTO_INCREMENT PRIMARY KEY,
    provider_id INT NOT NULL,
    category_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    original_price DECIMAL(10,2),
    duration INT,
    images JSON,
    is_active BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    is_featured BOOLEAN DEFAULT FALSE,
    rating DECIMAL(3,2) DEFAULT 0.00,
    total_ratings INT DEFAULT 0,
    booking_count INT DEFAULT 0,
    favorite_count INT DEFAULT 0,
    specifications JSON,
    tags JSON,
    location VARCHAR(255),
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    address TEXT,
    city VARCHAR(100),
    max_guests INT,
    cancellation_policy TEXT,
    deposit_required BOOLEAN,
    deposit_amount DECIMAL(10,2),
    payment_terms JSON,
    availability JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (provider_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
);
```

#### 4. جدول العروض (offers)
```sql
CREATE TABLE offers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    service_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    discount_percentage DECIMAL(5,2),
    discount_amount DECIMAL(10,2),
    start_date DATE,
    end_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE
);
```

#### 5. جدول الإعلانات (ads)
```sql
CREATE TABLE ads (
    id INT AUTO_INCREMENT PRIMARY KEY,
    provider_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    image VARCHAR(500),
    link VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    priority INT DEFAULT 0,
    start_date DATE,
    end_date DATE,
    views_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (provider_id) REFERENCES users(id) ON DELETE CASCADE
);
```

#### 6. جدول الحجوزات (bookings)
```sql
CREATE TABLE bookings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    service_id INT NOT NULL,
    provider_id INT NOT NULL,
    booking_date DATE NOT NULL,
    booking_time TIME NOT NULL,
    status ENUM('pending', 'confirmed', 'completed', 'cancelled') DEFAULT 'pending',
    total_price DECIMAL(10,2) NOT NULL,
    payment_status ENUM('pending', 'paid', 'refunded') DEFAULT 'pending',
    payment_method VARCHAR(50),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE,
    FOREIGN KEY (provider_id) REFERENCES users(id) ON DELETE CASCADE
);
```

#### 7. جدول التقييمات (reviews)
```sql
CREATE TABLE reviews (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    service_id INT NOT NULL,
    booking_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE,
    FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE
);
```

#### 8. جدول المفضلة (favorites)
```sql
CREATE TABLE favorites (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    service_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE,
    UNIQUE KEY unique_favorite (user_id, service_id)
);
```

#### 9. جدول طلبات الانضمام (provider_requests)
```sql
CREATE TABLE provider_requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    business_name VARCHAR(255) NOT NULL,
    business_description TEXT,
    business_phone VARCHAR(20),
    business_address TEXT,
    business_license VARCHAR(500),
    service_category VARCHAR(100),
    status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
    admin_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

#### 10. جدول الإشعارات (notifications)
```sql
CREATE TABLE notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type ENUM('booking', 'system', 'promotion', 'profile_update') DEFAULT 'system',
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

#### 11. جدول طلبات تحديث الملف الشخصي (profile_update_requests)
```sql
CREATE TABLE profile_update_requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    bio TEXT,
    website VARCHAR(255),
    address TEXT,
    city VARCHAR(100),
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
    admin_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

#### 12. جدول الرسائل (messages)
```sql
CREATE TABLE messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sender_id INT NOT NULL,
    receiver_id INT NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (receiver_id) REFERENCES users(id) ON DELETE CASCADE
);
```

#### 13. جدول تقارير الإحصائيات (provider_stats_reports)
```sql
CREATE TABLE provider_stats_reports (
    id INT AUTO_INCREMENT PRIMARY KEY,
    provider_id INT NOT NULL,
    report_date DATE NOT NULL,
    services_count INT DEFAULT 0,
    bookings_count INT DEFAULT 0,
    ads_count INT DEFAULT 0,
    avg_rating DECIMAL(3,2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (provider_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_report (provider_id, report_date)
);
```

## مجلد Models

### 1. user_model.dart
**الغرض:** نموذج بيانات المستخدم
**الحقول الرئيسية:**
- id, name, email, phone, password
- user_type (user/provider/admin)
- profile_image, is_verified, is_active
- rating, review_count, bio
- location data (latitude, longitude, address, city)
- timestamps (created_at, updated_at)

### 2. service_model.dart
**الغرض:** نموذج بيانات الخدمة
**الحقول الرئيسية:**
- id, provider_id, category_id
- title, description, price, original_price
- images (JSON), is_active, is_verified
- rating, total_ratings, booking_count
- location data, specifications, tags
- timestamps

### 3. booking_model.dart
**الغرض:** نموذج بيانات الحجز
**الحقول الرئيسية:**
- id, user_id, service_id, provider_id
- booking_date, booking_time
- status (pending/confirmed/completed/cancelled)
- total_price, payment_status
- notes, timestamps

### 4. category_model.dart
**الغرض:** نموذج بيانات الفئة
**الحقول الرئيسية:**
- id, name, description
- image, is_active
- created_at

### 5. ad_model.dart
**الغرض:** نموذج بيانات الإعلان
**الحقول الرئيسية:**
- id, provider_id, title, description
- image, link, is_active
- priority, start_date, end_date
- views_count, timestamps

### 6. offer_model.dart
**الغرض:** نموذج بيانات العرض
**الحقول الرئيسية:**
- id, service_id, title, description
- discount_percentage, discount_amount
- start_date, end_date, is_active
- created_at

### 7. review_model.dart
**الغرض:** نموذج بيانات التقييم
**الحقول الرئيسية:**
- id, user_id, service_id, booking_id
- rating (1-5), comment
- created_at

### 8. service_with_offers_model.dart
**الغرض:** نموذج يجمع الخدمة مع عروضها
**الحقول الرئيسية:**
- service data + offers list
- combined pricing information

## مجلد Services

### 1. api_service.dart
**الغرض:** الخدمة الرئيسية للتواصل مع API
**الوظائف الرئيسية:**
- إدارة الطلبات HTTP
- معالجة الاستجابات
- إدارة الأخطاء
- إدارة التوكن

### 2. auth_service.dart
**الغرض:** خدمة المصادقة والتفويض
**الوظائف الرئيسية:**
- تسجيل الدخول/الخروج
- التسجيل
- إعادة تعيين كلمة المرور
- التحقق من الحساب
- إدارة الجلسة

### 3. provider_service.dart
**الغرض:** خدمة مزودي الخدمات
**الوظائف الرئيسية:**
- إدارة الخدمات
- إدارة الإعلانات
- إدارة الحجوزات
- إدارة التقييمات
- الإحصائيات

### 4. admin_service.dart
**الغرض:** خدمة الإدارة
**الوظائف الرئيسية:**
- إدارة المستخدمين
- إدارة الخدمات
- إدارة الإعلانات
- إدارة الطلبات
- التقارير والإحصائيات

### 5. provider_api.dart
**الغرض:** API مخصص لمزودي الخدمات
**الوظائف الرئيسية:**
- إضافة/تعديل الخدمات
- إدارة الإعلانات
- عرض الحجوزات
- إدارة الملف الشخصي

### 6. admin_api.dart
**الغرض:** API مخصص للإدارة
**الوظائف الرئيسية:**
- إدارة جميع المستخدمين
- الموافقة على الطلبات
- إدارة المحتوى
- التقارير

## صفحات المصادقة (Auth Screens)

### 1. login_page.dart
**الغرض:** صفحة تسجيل الدخول للمستخدمين العاديين
**المحتوى:**
- حقل البريد الإلكتروني
- حقل كلمة المرور
- زر تسجيل الدخول
- رابط نسيان كلمة المرور
- رابط التسجيل الجديد
- رابط تسجيل دخول المزودين
- رابط تسجيل دخول الإدارة
**الوظائف:**
- التحقق من صحة البيانات
- إرسال طلب تسجيل الدخول
- حفظ بيانات الجلسة
- التوجيه للصفحة الرئيسية

### 2. signup_page.dart
**الغرض:** صفحة التسجيل للمستخدمين الجدد
**المحتوى:**
- حقل الاسم الكامل
- حقل البريد الإلكتروني
- حقل رقم الهاتف
- حقل كلمة المرور
- حقل تأكيد كلمة المرور
- اختيار نوع الحساب (مستخدم عادي/مزود خدمة)
- شروط الاستخدام
- زر التسجيل
**الوظائف:**
- التحقق من صحة البيانات
- التحقق من عدم تكرار البريد الإلكتروني
- إرسال طلب التسجيل
- التوجيه لصفحة التحقق

### 3. provider_login.dart
**الغرض:** صفحة تسجيل دخول مزودي الخدمات
**المحتوى:**
- حقل البريد الإلكتروني
- حقل كلمة المرور
- زر تسجيل الدخول
- رابط نسيان كلمة المرور
- رابط التسجيل كمزود خدمة
**الوظائف:**
- التحقق من نوع الحساب (provider)
- تسجيل الدخول
- التوجيه لصفحة مزود الخدمة الرئيسية

### 4. provider_register.dart
**الغرض:** صفحة التسجيل كمزود خدمة
**المحتوى:**
- معلومات شخصية (الاسم، البريد، الهاتف)
- معلومات العمل (اسم العمل، وصف، فئة الخدمة)
- رفع رخصة العمل
- كلمة المرور
- شروط مزودي الخدمات
**الوظائف:**
- رفع الملفات
- إرسال طلب الانضمام
- التوجيه لصفحة الانتظار

### 5. login_admin.dart
**الغرض:** صفحة تسجيل دخول الإدارة
**المحتوى:**
- حقل البريد الإلكتروني
- حقل كلمة المرور
- زر تسجيل الدخول
**الوظائف:**
- التحقق من صلاحيات الإدارة
- التوجيه للوحة الإدارة

### 6. forgot_password_page.dart
**الغرض:** صفحة نسيان كلمة المرور
**المحتوى:**
- حقل البريد الإلكتروني
- زر إرسال رابط إعادة التعيين
- رابط العودة لتسجيل الدخول
**الوظائف:**
- إرسال رابط إعادة التعيين
- التحقق من وجود الحساب

### 7. reset_password_page.dart
**الغرض:** صفحة إعادة تعيين كلمة المرور
**المحتوى:**
- حقل كلمة المرور الجديدة
- حقل تأكيد كلمة المرور
- زر حفظ كلمة المرور الجديدة
**الوظائف:**
- التحقق من صحة كلمة المرور
- تحديث كلمة المرور
- التوجيه لتسجيل الدخول

### 8. verify_page.dart
**الغرض:** صفحة التحقق من الحساب
**المحتوى:**
- رسالة تأكيد إرسال رمز التحقق
- حقل إدخال رمز التحقق
- زر إعادة إرسال الرمز
- زر تأكيد التحقق
**الوظائف:**
- إرسال رمز التحقق
- التحقق من الرمز
- تفعيل الحساب

### 9. verify_sms_code_page.dart
**الغرض:** صفحة التحقق عبر SMS
**المحتوى:**
- حقل إدخال رمز SMS
- عداد زمني لإعادة الإرسال
- زر تأكيد الرمز
**الوظائف:**
- إرسال رمز SMS
- التحقق من الرمز
- تفعيل الحساب

### 10. send_verification_code_page.dart
**الغرض:** صفحة إرسال رمز التحقق
**المحتوى:**
- اختيار طريقة التحقق (بريد إلكتروني/SMS)
- زر إرسال الرمز
- معلومات الحساب
**الوظائف:**
- إرسال رمز التحقق بالطريقة المختارة
- التوجيه لصفحة التحقق

## صفحات المستخدم (User Screens)

### 1. user_home_page.dart
**الغرض:** الصفحة الرئيسية للمستخدم العادي
**المحتوى:**
- شريط البحث
- قائمة الفئات الرئيسية
- الإعلانات المميزة
- الخدمات الموصى بها
- الخدمات الأكثر تقييماً
- العروض الحالية
- شريط التنقل السفلي
**الوظائف:**
- عرض الخدمات المميزة
- البحث في الخدمات
- التوجيه لصفحات التفاصيل
- إدارة المفضلة

### 2. home_page.dart
**الغرض:** صفحة البداية البسيطة
**المحتوى:**
- شعار التطبيق
- أزرار تسجيل الدخول والتسجيل
- معلومات التطبيق
**الوظائف:**
- التوجيه لصفحات المصادقة

### 3. search_page.dart
**الغرض:** صفحة البحث المتقدم
**المحتوى:**
- شريط البحث النصي
- فلاتر متقدمة (الفئة، السعر، الموقع، التقييم)
- خريطة تفاعلية
- قائمة نتائج البحث
- خيارات الترتيب
**الوظائف:**
- البحث النصي
- تطبيق الفلاتر
- عرض النتائج على الخريطة
- ترتيب النتائج

### 4. service_details_page.dart
**الغرض:** صفحة تفاصيل الخدمة
**المحتوى:**
- صور الخدمة
- معلومات الخدمة (العنوان، الوصف، السعر)
- معلومات المزود
- التقييمات والتعليقات
- العروض المتاحة
- زر الحجز
- زر إضافة للمفضلة
**الوظائف:**
- عرض تفاصيل الخدمة
- إضافة/إزالة من المفضلة
- التوجيه لصفحة الحجز
- عرض التقييمات

### 5. booking_page.dart
**الغرض:** صفحة حجز الخدمة
**المحتوى:**
- تفاصيل الخدمة المختارة
- اختيار التاريخ والوقت
- إدخال ملاحظات
- عرض السعر النهائي
- اختيار طريقة الدفع
- زر تأكيد الحجز
**الوظائف:**
- اختيار موعد الحجز
- حساب السعر النهائي
- إرسال طلب الحجز
- التوجيه لصفحة تأكيد الحجز

### 6. booking_status_page.dart
**الغرض:** صفحة حالة الحجز
**المحتوى:**
- تفاصيل الحجز
- حالة الحجز الحالية
- تاريخ ووقت الحجز
- معلومات المزود
- خيارات إلغاء الحجز
- إمكانية إضافة تقييم
**الوظائف:**
- عرض حالة الحجز
- إلغاء الحجز
- إضافة تقييم
- التواصل مع المزود

### 7. favorites_page.dart
**الغرض:** صفحة الخدمات المفضلة
**المحتوى:**
- قائمة الخدمات المفضلة
- إمكانية إزالة من المفضلة
- التوجيه لتفاصيل الخدمة
- رسالة عند عدم وجود مفضلات
**الوظائف:**
- عرض الخدمات المفضلة
- إزالة من المفضلة
- التوجيه لتفاصيل الخدمة

### 8. edit_profile_page.dart
**الغرض:** صفحة تعديل الملف الشخصي
**المحتوى:**
- معلومات شخصية (الاسم، البريد، الهاتف)
- صورة الملف الشخصي
- معلومات إضافية (الموقع، الموقع الإلكتروني)
- زر حفظ التغييرات
**الوظائف:**
- تحديث المعلومات الشخصية
- رفع صورة جديدة
- حفظ التغييرات

### 9. settings_page.dart
**الغرض:** صفحة الإعدادات
**المحتوى:**
- إعدادات الإشعارات
- إعدادات الخصوصية
- تغيير كلمة المرور
- حذف الحساب
- تسجيل الخروج
**الوظائف:**
- تغيير إعدادات التطبيق
- إدارة الحساب
- تسجيل الخروج

### 10. notifications_page.dart
**الغرض:** صفحة الإشعارات
**المحتوى:**
- قائمة الإشعارات
- تمييز الإشعارات الجديدة
- إمكانية حذف الإشعارات
- تصفية حسب النوع
**الوظائف:**
- عرض الإشعارات
- تمييز كمقروء
- حذف الإشعارات

### 11. join_provider_page.dart
**الغرض:** صفحة طلب الانضمام كمزود خدمة
**المحتوى:**
- نموذج طلب الانضمام
- معلومات العمل
- رفع المستندات
- شروط الانضمام
**الوظائف:**
- إرسال طلب الانضمام
- رفع المستندات
- التوجيه لصفحة الانتظار

### 12. user_help_page.dart
**الغرض:** صفحة المساعدة للمستخدمين
**المحتوى:**
- الأسئلة الشائعة
- دليل الاستخدام
- معلومات التواصل
- تقرير مشكلة
**الوظائف:**
- عرض المساعدة
- التواصل مع الدعم
- تقرير المشاكل

### 13. change_password_page.dart
**الغرض:** صفحة تغيير كلمة المرور
**المحتوى:**
- كلمة المرور الحالية
- كلمة المرور الجديدة
- تأكيد كلمة المرور الجديدة
- زر حفظ التغييرات
**الوظائف:**
- التحقق من كلمة المرور الحالية
- تحديث كلمة المرور
- إظهار رسالة نجاح

### 14. delete_account_page.dart
**الغرض:** صفحة حذف الحساب
**المحتوى:**
- تحذير من حذف الحساب
- تأكيد كلمة المرور
- زر حذف الحساب
**الوظائف:**
- التحقق من كلمة المرور
- حذف الحساب نهائياً
- التوجيه لصفحة البداية

### 15. comment_page.dart
**الغرض:** صفحة إضافة تعليق
**المحتوى:**
- حقل إدخال التعليق
- تقييم بالنجوم
- زر إرسال التعليق
**الوظائف:**
- إضافة تعليق وتقييم
- إرسال للخادم
- العودة لصفحة التفاصيل

### 16. details_page.dart
**الغرض:** صفحة تفاصيل إضافية
**المحتوى:**
- معلومات مفصلة
- صور إضافية
- معلومات الاتصال
**الوظائف:**
- عرض تفاصيل إضافية
- التواصل مع المزود

### 17. service_list_page.dart
**الغرض:** صفحة قائمة الخدمات
**المحتوى:**
- قائمة الخدمات
- فلاتر بسيطة
- خيارات الترتيب
**الوظائف:**
- عرض قائمة الخدمات
- تطبيق الفلاتر
- التوجيه لتفاصيل الخدمة 