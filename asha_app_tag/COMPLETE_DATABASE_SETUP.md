# دليل إنشاء قاعدة البيانات كاملة 🗄️

## ✅ **الملفات الجديدة:**

### **1. ملف SQL كامل:**
```
asha_app_backend/create_database_complete.sql
```

### **2. ملف PHP للتنفيذ:**
```
asha_app_backend/create_database_complete.php
```

---

## 🚀 **كيفية الاستخدام:**

### **الطريقة الأولى (الأسهل):**
```
http://127.0.0.1/asha_app_backend/create_database_complete.php
```

### **الطريقة الثانية (يدوياً):**
1. افتح phpMyAdmin
2. انسخ محتوى `create_database_complete.sql`
3. الصق في نافذة SQL
4. اضغط تنفيذ

---

## 📊 **ما يتم إنشاؤه:**

### **🗄️ قاعدة البيانات:**
- اسم: `asha_app`
- الترميز: `utf8mb4_unicode_ci`

### **📋 الجداول (10 جداول):**

1. **`users`** - المستخدمين (مدير، مستخدمين عاديين، مزودي خدمات)
2. **`categories`** - فئات الخدمات
3. **`services`** - الخدمات المقدمة
4. **`ads`** - الإعلانات
5. **`offers`** - العروض والخصومات
6. **`bookings`** - الحجوزات
7. **`reviews`** - التقييمات
8. **`favorites`** - المفضلات
9. **`comments`** - التعليقات
10. **`notifications`** - الإشعارات

### **🔗 العلاقات (Foreign Keys):**
- جميع العلاقات محترمة
- CASCADE DELETE للتنظيف التلقائي
- فهارس لتحسين الأداء

---

## 📈 **البيانات الافتراضية:**

### **👥 المستخدمين (21 مستخدم):**
- 1 مدير: `admin@asha.com`
- 10 مستخدمين عاديين
- 10 مزودي خدمات

### **🏷️ الفئات (10 فئات):**
- تنظيف المنازل
- الكهرباء
- السباكة
- التصميم الداخلي
- الحدادة
- النجارة
- التكييف
- الحدائق
- الأمن والحماية
- النقل والشحن

### **🛠️ الخدمات (15 خدمة):**
- تنظيف منزل شامل
- إصلاح كهربائي
- تركيب مكيف
- إصلاح سباكة
- تصميم داخلي
- أعمال حدادة
- أعمال نجارة
- صيانة تكييف
- تصميم حدائق
- أنظمة أمن
- شحن أثاث
- تنظيف سجاد
- إصلاح قواطع كهرباء
- تركيب سخان مياه

### **📢 الإعلانات والعروض:**
- 8 إعلانات نشطة
- 10 عروض خاصة

### **📅 الحجوزات والتقييمات:**
- 10 حجوزات مختلفة الحالات
- 10 تقييمات متنوعة
- 10 مفضلات
- 10 تعليقات
- 10 إشعارات

---

## 🔐 **بيانات تسجيل الدخول:**

### **المدير:**
- البريد: `admin@asha.com`
- كلمة المرور: `password`

### **المستخدمين العاديين:**
- `ahmed@example.com` | `password`
- `fatima@example.com` | `password`
- `mohammed@example.com` | `password`
- `sara@example.com` | `password`
- `ali@example.com` | `password`
- `noor@example.com` | `password`
- `layla@example.com` | `password`
- `khalid@example.com` | `password`
- `rana@example.com` | `password`
- `omar@example.com` | `password`

### **مزودي الخدمات:**
- `cleaning@example.com` | `password`
- `electric@example.com` | `password`
- `plumbing@example.com` | `password`
- `design@example.com` | `password`
- `blacksmith@example.com` | `password`
- `carpentry@example.com` | `password`
- `ac@example.com` | `password`
- `gardening@example.com` | `password`
- `security@example.com` | `password`
- `transport@example.com` | `password`

---

## ⚡ **مميزات الملف الجديد:**

### **✅ الأمان:**
- فهارس لتحسين الأداء
- Foreign Key Constraints
- CASCADE DELETE
- UNIQUE constraints

### **✅ الأداء:**
- فهارس على الأعمدة المهمة
- تحسين الاستعلامات
- إعدادات UTF8MB4

### **✅ المرونة:**
- يمكن تشغيله عدة مرات
- يتجاهل الأخطاء المتوقعة
- رسائل تفصيلية

---

## 🔧 **إذا واجهت مشكلة:**

### **1. تأكد من إعدادات MySQL:**
```sql
-- في phpMyAdmin
SET GLOBAL sql_mode = '';
SET SESSION sql_mode = '';
```

### **2. تأكد من صلاحيات المستخدم:**
```sql
GRANT ALL PRIVILEGES ON asha_app.* TO 'your_user'@'localhost';
FLUSH PRIVILEGES;
```

### **3. تحقق من ملف config.php:**
```php
define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', '');
define('DB_NAME', 'asha_app');
```

---

## ✅ **بعد إنشاء قاعدة البيانات:**

1. **اختبر تسجيل الدخول** باستخدام البيانات أعلاه
2. **تحقق من الصفحة الرئيسية** - يجب أن تظهر الفئات والإعلانات
3. **اختبر صفحة الخدمات** - يجب أن تظهر جميع الخدمات
4. **اختبر حساب المزود** - يجب أن تظهر الخدمات والحجوزات
5. **اختبر حساب المدير** - يجب أن تظهر لوحة التحكم

---

## 🎯 **الملفات المتاحة:**

### **لإنشاء قاعدة البيانات كاملة:**
- `create_database_complete.php` - إنشاء كامل
- `create_database_complete.sql` - ملف SQL

### **لإدخال بيانات في قاعدة موجودة:**
- `clear_and_insert_data.php` - مسح وإدخال
- `insert_data_step_by_step.php` - إدخال فقط

---

## 📋 **تفاصيل الجداول:**

### **جدول المستخدمين (users):**
- `id` - المعرف الفريد
- `name` - الاسم
- `email` - البريد الإلكتروني (فريد)
- `phone` - رقم الهاتف
- `password` - كلمة المرور (مشفرة)
- `user_type` - نوع المستخدم (user/provider/admin)
- `bio` - السيرة الذاتية
- `address` - العنوان
- `city` - المدينة
- `is_verified` - هل الحساب مفعل
- `is_active` - هل الحساب نشط

### **جدول الفئات (categories):**
- `id` - المعرف الفريد
- `name` - اسم الفئة
- `description` - وصف الفئة
- `image` - صورة الفئة
- `is_active` - هل الفئة نشطة

### **جدول الخدمات (services):**
- `id` - المعرف الفريد
- `provider_id` - معرف المزود (مرتبط بـ users)
- `category_id` - معرف الفئة (مرتبط بـ categories)
- `title` - عنوان الخدمة
- `description` - وصف الخدمة
- `price` - السعر
- `images` - الصور (JSON)
- `city` - المدينة
- `is_active` - هل الخدمة نشطة
- `is_verified` - هل الخدمة موثقة

### **جدول الحجوزات (bookings):**
- `id` - المعرف الفريد
- `user_id` - معرف المستخدم (مرتبط بـ users)
- `service_id` - معرف الخدمة (مرتبط بـ services)
- `provider_id` - معرف المزود (مرتبط بـ users)
- `booking_date` - تاريخ الحجز
- `booking_time` - وقت الحجز
- `status` - حالة الحجز (pending/confirmed/completed/cancelled)
- `total_price` - السعر الإجمالي
- `payment_status` - حالة الدفع (pending/paid/refunded)
- `payment_method` - طريقة الدفع
- `notes` - ملاحظات

### **جدول التقييمات (reviews):**
- `id` - المعرف الفريد
- `user_id` - معرف المستخدم
- `service_id` - معرف الخدمة
- `provider_id` - معرف المزود
- `rating` - التقييم (1-5)
- `comment` - التعليق

### **جدول المفضلات (favorites):**
- `id` - المعرف الفريد
- `user_id` - معرف المستخدم
- `service_id` - معرف الخدمة
- فهرس فريد على (user_id, service_id)

### **جدول التعليقات (comments):**
- `id` - المعرف الفريد
- `user_id` - معرف المستخدم
- `service_id` - معرف الخدمة
- `comment` - التعليق

### **جدول الإشعارات (notifications):**
- `id` - المعرف الفريد
- `user_id` - معرف المستخدم
- `title` - عنوان الإشعار
- `message` - رسالة الإشعار
- `type` - نوع الإشعار (booking/service/review/promotion/reminder)
- `is_read` - هل تم القراءة

### **جدول الإعلانات (ads):**
- `id` - المعرف الفريد
- `provider_id` - معرف المزود
- `title` - عنوان الإعلان
- `description` - وصف الإعلان
- `image` - صورة الإعلان
- `is_active` - هل الإعلان نشط
- `start_date` - تاريخ البداية
- `end_date` - تاريخ النهاية

### **جدول العروض (offers):**
- `id` - المعرف الفريد
- `service_id` - معرف الخدمة
- `title` - عنوان العرض
- `description` - وصف العرض
- `discount_percentage` - نسبة الخصم
- `start_date` - تاريخ البداية
- `end_date` - تاريخ النهاية
- `is_active` - هل العرض نشط

---

## 🎉 **الآن لديك قاعدة بيانات كاملة وجاهزة للاختبار!** 