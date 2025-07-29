# 🔧 دليل توحيد الأنواع في مشروع آشا

## 🎯 **المشكلة الأصلية:**

كانت هناك أخطاء في تحويل الأنواع بين String و int في عدة أماكن:

```
TypeError: "1": type 'String' is not a subtype of type 'int'
Error getting active ads: TypeError: "1": type 'String' is not a subtype of type 'int'
خطأ في تحميل الفئات: ClientException: Failed to fetch
```

## ✅ **الحلول المطبقة:**

### **1. إصلاح نموذج الإعلانات (`lib/models/ad_model.dart`):**

```dart
factory AdModel.fromJson(Map<String, dynamic> json) => AdModel(
  id: int.tryParse(json['id'].toString()) ?? 0,
  title: json['title'] ?? '',
  description: json['description'] ?? '',
  image: json['image'] ?? '',
  link: json['link'],
  isActive: json['is_active'] == true || json['is_active'] == 1,
  priority: int.tryParse(json['priority'].toString()) ?? 0,
  // ... باقي الحقول
  providerId: json['provider_id'] != null 
      ? int.tryParse(json['provider_id'].toString())
      : null,
);
```

### **2. إصلاح نموذج الخدمة (`lib/models/service_model.dart`):**

```dart
factory Service.fromJson(Map<String, dynamic> json) => Service(
  id: int.tryParse(json['id'].toString()) ?? 0,
  providerId: int.tryParse(json['provider_id'].toString()) ?? 0,
  categoryId: int.tryParse(json['category_id'].toString()) ?? 0,
  title: json['title'] ?? '',
  description: json['description'] ?? '',
  price: (json['price'] as num?)?.toDouble() ?? 0.0,
  duration: int.tryParse(json['duration'].toString()) ?? 0,
  isActive: json['is_active'] == true || json['is_active'] == 1,
  isVerified: json['is_verified'] == true || json['is_verified'] == 1,
  isFeatured: json['is_featured'] == true || json['is_featured'] == 1,
  rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
  totalRatings: int.tryParse(json['total_ratings'].toString()) ?? 0,
  // ... باقي الحقول
);
```

### **3. إصلاح نموذج الحجز (`lib/models/booking_model.dart`):**

```dart
factory BookingModel.fromJson(Map<String, dynamic> json) => BookingModel(
  id: int.tryParse(json['id'].toString()) ?? 0,
  userId: int.tryParse(json['user_id'].toString()) ?? 0,
  serviceId: int.tryParse(json['service_id'].toString()) ?? 0,
  userName: json['user_name'] ?? '',
  serviceName: json['service_name'] ?? '',
  providerName: json['provider_name'] ?? '',
  totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
  // ... باقي الحقول
);
```

### **4. إصلاح نموذج المستخدم (`lib/models/user_model.dart`):**

```dart
factory User.fromJson(Map<String, dynamic> json) => User(
  id: int.tryParse(json['id'].toString()) ?? 0,
  name: json['name'] ?? '',
  email: json['email'] ?? '',
  phone: json['phone'] ?? '',
  userType: json['user_type'] ?? 'user',
  isVerified: json['is_verified'] == true || json['is_verified'] == 1,
  isActive: json['is_active'] == true || json['is_active'] == 1,
  rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
  reviewCount: int.tryParse(json['review_count'].toString()) ?? 0,
  // ... باقي الحقول
);
```

### **5. إصلاح API الإعلانات (`asha_app_backend/api/ads/get_active_ads.php`):**

```php
// معالجة البيانات
foreach ($ads as &$ad) {
    // تحويل الأرقام
    $ad['id'] = (int)$ad['id'];
    $ad['provider_id'] = $ad['provider_id'] ? (int)$ad['provider_id'] : null;
    $ad['priority'] = (int)$ad['priority'];
    
    // تحويل القيم المنطقية
    $ad['is_active'] = (bool)$ad['is_active'];
    
    // تحويل التواريخ
    if ($ad['start_date']) {
        $ad['start_date'] = date('Y-m-d H:i:s', strtotime($ad['start_date']));
    }
    // ... باقي التحويلات
}
```

### **6. إصلاح API الفئات (`asha_app_backend/api/services/get_categories.php`):**

```php
// تحويل البيانات إلى التنسيق المطلوب
$formattedCategories = [];
foreach ($categories as $category) {
    $formattedCategories[] = [
        'id' => (int)$category['id'],
        'title' => $category['title'],
        'name' => $category['title'], // للتوافق مع الكود القديم
        'description' => $category['description'],
        'image' => $category['image'],
        'is_active' => (bool)$category['is_active'],
        'created_at' => $category['created_at']
    ];
}
```

## 🔧 **القواعد العامة لتوحيد الأنواع:**

### **1. تحويل الأرقام الصحيحة:**
```dart
// بدلاً من
id: json['id'] as int,

// استخدم
id: int.tryParse(json['id'].toString()) ?? 0,
```

### **2. تحويل الأرقام العشرية:**
```dart
// بدلاً من
price: (json['price'] as num).toDouble(),

// استخدم
price: (json['price'] as num?)?.toDouble() ?? 0.0,
```

### **3. تحويل القيم المنطقية:**
```dart
// بدلاً من
isActive: json['is_active'] as bool,

// استخدم
isActive: json['is_active'] == true || json['is_active'] == 1,
```

### **4. تحويل القوائم:**
```dart
// بدلاً من
images: (json['images'] as List<dynamic>).map((e) => e as String).toList(),

// استخدم
images: (json['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
```

### **5. تحويل القيم الاختيارية:**
```dart
// بدلاً من
providerId: json['provider_id'] as int?,

// استخدم
providerId: json['provider_id'] != null 
    ? int.tryParse(json['provider_id'].toString())
    : null,
```

## 📱 **في Flutter (Frontend):**

### **1. استخدام `int.tryParse()`:**
```dart
// آمن للتحويل من String إلى int
int userId = int.tryParse(json['user_id'].toString()) ?? 0;
```

### **2. استخدام `double.tryParse()`:**
```dart
// آمن للتحويل من String إلى double
double price = double.tryParse(json['price'].toString()) ?? 0.0;
```

### **3. استخدام `num?.toDouble()`:**
```dart
// آمن للتحويل من num إلى double
double rating = (json['rating'] as num?)?.toDouble() ?? 0.0;
```

## 🖥️ **في PHP (Backend):**

### **1. تحويل الأرقام الصحيحة:**
```php
$id = (int)$data['id'];
$userId = $data['user_id'] ? (int)$data['user_id'] : null;
```

### **2. تحويل الأرقام العشرية:**
```php
$price = (float)$data['price'];
$rating = $data['rating'] ? (float)$data['rating'] : 0.0;
```

### **3. تحويل القيم المنطقية:**
```php
$isActive = (bool)$data['is_active'];
$isVerified = $data['is_verified'] == 1;
```

### **4. تحويل التواريخ:**
```php
$createdAt = date('Y-m-d H:i:s', strtotime($data['created_at']));
```

## 🧪 **اختبار التحويلات:**

### **1. اختبار في Flutter:**
```dart
// اختبار تحويل String إلى int
print('String "123" to int: ${int.tryParse("123")}'); // 123
print('String "abc" to int: ${int.tryParse("abc")}'); // null

// اختبار تحويل num إلى double
print('num 5 to double: ${(5 as num).toDouble()}'); // 5.0
print('num null to double: ${(null as num?)?.toDouble()}'); // null
```

### **2. اختبار في PHP:**
```php
// اختبار تحويل String إلى int
echo (int)"123"; // 123
echo (int)"abc"; // 0

// اختبار تحويل String إلى float
echo (float)"123.45"; // 123.45
echo (float)"abc"; // 0
```

## ✅ **النتائج المتوقعة:**

### **✅ بعد التطبيق:**
- ✅ لا توجد أخطاء `TypeError`
- ✅ تحويل آمن للأنواع
- ✅ توافق بين Frontend و Backend
- ✅ معالجة القيم الفارغة
- ✅ قيم افتراضية آمنة

### **❌ قبل التطبيق:**
- ❌ أخطاء `TypeError` عند تحويل String إلى int
- ❌ أخطاء عند تحويل القيم الفارغة
- ❌ عدم توافق بين Frontend و Backend

## 📋 **الملفات المحدثة:**

1. `lib/models/ad_model.dart` - إصلاح تحويل الأنواع
2. `lib/models/service_model.dart` - إصلاح تحويل الأنواع
3. `lib/models/booking_model.dart` - إصلاح تحويل الأنواع
4. `lib/models/user_model.dart` - إصلاح تحويل الأنواع
5. `asha_app_backend/api/ads/get_active_ads.php` - إصلاح تحويل الأنواع
6. `asha_app_backend/api/services/get_categories.php` - إصلاح تحويل الأنواع

## 🎯 **التوصيات المستقبلية:**

1. **استخدام TypeScript في Frontend** (إذا كان ممكناً)
2. **إضافة validation للبيانات** في Backend
3. **توحيد تنسيق البيانات** بين جميع APIs
4. **إضافة unit tests** للتحويلات
5. **توثيق أنواع البيانات** لكل API

---

**🎉 تم توحيد جميع الأنواع بنجاح!** 