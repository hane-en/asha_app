# حل مشكلة "يرجى تفعيل حسابك"

## 🔍 سبب المشكلة:

المشكلة تحدث لأن الحسابات في قاعدة البيانات غير مفعلة (`is_verified = 0`). عند تسجيل الدخول، النظام يتحقق من حالة تفعيل الحساب ويرفض تسجيل الدخول إذا كان الحساب غير مفعل.

## ✅ الحل:

### الطريقة الأولى: تشغيل ملف PHP (الأسهل)

1. **تأكد من تشغيل الخادم المحلي** (XAMPP/WAMP)
2. **افتح المتصفح** واذهب إلى:
   ```
   http://localhost/asha_app_backend/activate_all_accounts.php
   ```
3. **ستظهر رسالة نجاح** مع قائمة الحسابات المفعلة

### الطريقة الثانية: تشغيل ملف SQL

1. **افتح phpMyAdmin**
2. **اختر قاعدة البيانات** `asha_app`
3. **اذهب إلى تبويب SQL**
4. **انسخ والصق محتوى ملف** `asha_app_backend/activate_accounts.sql`
5. **اضغط Execute**

### الطريقة الثالثة: التحديث المباشر

```sql
-- تفعيل جميع الحسابات الموجودة
UPDATE users SET is_verified = 1 WHERE is_verified = 0;

-- إضافة بيانات تجريبية
INSERT INTO users (name, email, phone, password, user_type, is_verified, is_active) VALUES 
('مدير النظام', 'admin@asha.com', '777777777', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin', 1, 1),
('أحمد المصور', 'ahmed@test.com', '777777778', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'provider', 1, 1),
('فاطمة المزينة', 'fatima@test.com', '777777779', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'provider', 1, 1),
('محمد أحمد', 'mohammed@test.com', '777777780', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user', 1, 1);
```

## 🔑 بيانات تسجيل الدخول بعد التفعيل:

### مدير النظام
- **البريد**: admin@asha.com
- **كلمة المرور**: password

### مزودي الخدمات
- **أحمد المصور**: ahmed@test.com / password
- **فاطمة المزينة**: fatima@test.com / password

### مستخدم عادي
- **محمد أحمد**: mohammed@test.com / password

## 🧪 للاختبار:

1. **شغل التطبيق**:
   ```bash
   flutter run
   ```

2. **جرب تسجيل الدخول** باستخدام أي من البيانات أعلاه

3. **تأكد من عدم ظهور رسالة** "يرجى تفعيل حسابك"

## 📝 ملاحظات مهمة:

- **كلمة المرور لجميع الحسابات**: `password`
- **جميع الحسابات مفعلة الآن** (`is_verified = 1`)
- **جميع الحسابات نشطة** (`is_active = 1`)
- **يمكنك إنشاء حسابات جديدة** وستكون مفعلة تلقائياً

## 🔧 إذا استمرت المشكلة:

1. **تأكد من تشغيل الخادم المحلي**
2. **تأكد من صحة إعدادات قاعدة البيانات**
3. **تحقق من ملف** `asha_app_backend/config.php`
4. **أعد تشغيل الخادم** إذا لزم الأمر

---

**🎉 بعد تطبيق الحل، ستتمكن من تسجيل الدخول بدون مشاكل!** 