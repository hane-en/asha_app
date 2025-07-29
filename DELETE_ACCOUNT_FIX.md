# حل مشكلة حذف الحساب

## 🔍 **المشكلة:**

عند الضغط على "حذف الحساب":
1. ❌ يظهر "يرجى تسجيل الدخول أولاً"
2. ❌ لا يتم فتح صفحة حذف الحساب
3. ❌ لا يوجد ملف `delete_account.php` في الخادم

## 🐛 **الأسباب:**

### 1. **عدم حفظ معرف المستخدم:**
في `AuthService._saveUserData()` لم يتم حفظ `user_id` بشكل منفصل في `SharedPreferences`.

### 2. **عدم وجود ملف حذف الحساب:**
لم يكن موجود ملف `asha_app_backend/api/auth/delete_account.php`.

### 3. **مشكلة في دالة `_getUserId()`:**
الدالة تحاول الحصول على `user_id` من `SharedPreferences` ولكن لم يتم حفظه.

## ✅ **الحل:**

### 1. **إصلاح حفظ بيانات المستخدم:**
```dart
Future<void> _saveUserData(
  Map<String, dynamic> userData,
  String token,
) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('auth_token', token);
  await prefs.setString('user_data', jsonEncode(userData));
  // حفظ معرف المستخدم بشكل منفصل للوصول السريع
  await prefs.setInt('user_id', userData['id']);
  await prefs.setString('user_name', userData['name'] ?? '');
  await prefs.setString('user_type', userData['user_type'] ?? 'user');
}
```

### 2. **إنشاء ملف حذف الحساب:**
تم إنشاء `asha_app_backend/api/auth/delete_account.php` مع الوظائف التالية:

- **التحقق من المستخدم**: التأكد من وجود المستخدم
- **التحقق من كلمة المرور**: التأكد من صحة كلمة المرور
- **حذف البيانات المرتبطة**: حذف الإعلانات، الخدمات، الحجوزات، التقييمات، المفضلة
- **حذف الحساب**: حذف المستخدم من قاعدة البيانات
- **المعاملات**: استخدام المعاملات لضمان سلامة البيانات

### 3. **الكود في الخادم:**
```php
<?php
// التحقق من وجود المستخدم
$user = $database->selectOne("SELECT * FROM users WHERE id = :id", ['id' => $userId]);

// التحقق من كلمة المرور
if (!password_verify($password, $user['password'])) {
    errorResponse('كلمة المرور غير صحيحة', 401);
}

// بدء المعاملة
$database->beginTransaction();

try {
    // حذف الإعلانات المرتبطة
    $database->delete('ads', 'provider_id = :provider_id', ['provider_id' => $userId]);
    
    // حذف الخدمات المرتبطة
    $database->delete('services', 'provider_id = :provider_id', ['provider_id' => $userId]);
    
    // حذف الحجوزات المرتبطة
    $database->delete('bookings', 'user_id = :user_id', ['user_id' => $userId]);
    
    // حذف التقييمات المرتبطة
    $database->delete('reviews', 'user_id = :user_id', ['user_id' => $userId]);
    
    // حذف المفضلة المرتبطة
    $database->delete('favorites', 'user_id = :user_id', ['user_id' => $userId]);
    
    // حذف المستخدم نفسه
    $result = $database->delete('users', 'id = :id', ['id' => $userId]);
    
    if ($result) {
        $database->commit();
        successResponse(null, 'تم حذف الحساب بنجاح');
    } else {
        $database->rollback();
        errorResponse('فشل في حذف الحساب', 500);
    }
} catch (Exception $e) {
    $database->rollback();
    throw $e;
}
?>
```

## 🎯 **النتيجة بعد الإصلاح:**

1. ✅ **حفظ معرف المستخدم**: يتم حفظ `user_id` في `SharedPreferences`
2. ✅ **دالة `_getUserId()`**: تعمل بشكل صحيح
3. ✅ **صفحة حذف الحساب**: تفتح بشكل صحيح
4. ✅ **حذف الحساب**: يعمل في الخادم
5. ✅ **حذف البيانات المرتبطة**: يتم حذف جميع البيانات المرتبطة

## 📝 **خطوات حذف الحساب:**

1. **الضغط على "حذف الحساب"** في القائمة الجانبية
2. **إدخال كلمة المرور** للتأكيد
3. **التحقق من كلمة المرور** في الخادم
4. **حذف البيانات المرتبطة** (إعلانات، خدمات، حجوزات، إلخ)
5. **حذف الحساب** من قاعدة البيانات
6. **حذف البيانات المحلية** وانتقال لصفحة تسجيل الدخول

## 🔧 **الملفات المعدلة:**

1. **`lib/services/auth_service.dart`**: إصلاح حفظ معرف المستخدم
2. **`asha_app_backend/api/auth/delete_account.php`**: إنشاء ملف حذف الحساب

---

**الآن سيعمل حذف الحساب بشكل صحيح!** 🎉 