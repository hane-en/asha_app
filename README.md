# دليل تحديث تطبيق عشا - Asha App

## 📋 ملخص التحديثات

تم إعادة هيكلة المشروع وتنظيمه بالكامل مع إنشاء ملفات PHP جديدة وربطها مع Flutter. إليك ملخص التحديثات:

### ✅ ما تم إنجازه:

1. **حذف الملفات القديمة غير الضرورية:**
   - `test_services.php`
   - `test_categories.php` 
   - `test_login.php`
   - `test.php`

2. **إنشاء ملفات PHP جديدة:**
   - `api/services/get_all.php` - جلب جميع الخدمات
   - `api/services/get_by_id.php` - جلب خدمة محددة
   - `api/categories/get_all.php` - جلب جميع الفئات
   - `api/providers/get_by_category.php` - جلب مزودي الخدمات حسب الفئة
   - `api/providers/get_services.php` - جلب خدمات مزود معين
   - `api/bookings/create.php` - إنشاء حجز جديد
   - `api/reviews/create.php` - إضافة تقييم جديد
   - `api/favorites/toggle.php` - إضافة/إزالة من المفضلة
   - `api/favorites/get_all.php` - جلب مفضلات المستخدم
   - `api/ads/get_active_ads.php` - جلب الإعلانات النشطة
   - `api/auth/login.php` - تسجيل الدخول
   - `api/auth/register.php` - إنشاء حساب جديد

3. **إنشاء صفحات Flutter جديدة:**
   - `service_details_screen.dart` - صفحة تفاصيل الخدمة مع التقييمات والحجز
   - `providers_by_category_screen.dart` - صفحة مزودي الخدمات حسب الفئة
   - `provider_services_screen.dart` - صفحة خدمات المزود
   - `booking_screen.dart` - صفحة الحجز
   - `login_screen.dart` - صفحة تسجيل الدخول
   - `register_screen.dart` - صفحة التسجيل

4. **تحديث ملف API Service:**
   - ربط جميع الخدمات مع API الجديدة
   - إضافة دوال للتعامل مع الحجوزات والتقييمات والمفضلة

## 🔄 استبدال الملفات الموجودة مسبقاً

### الملفات التي تم استبدالها:

1. **صفحات المصادقة:**
   - `lib/screens/auth/login_screen.dart` ✅ (تم تحديثه)
   - `lib/screens/auth/register_screen.dart` ✅ (تم تحديثه)
   - `lib/screens/auth/login_user_page.dart` ❌ (يجب حذفه)
   - `lib/screens/auth/signup_page.dart` ❌ (يجب حذفه)

2. **صفحات الحجز:**
   - `lib/screens/user/booking_screen.dart` ✅ (تم تحديثه)
   - `lib/screens/user/booking_page.dart` ❌ (يجب حذفه)

## 📁 الفرق بين مجلدات API

### 1. مجلد `api/providers/` (للمستخدمين):
- **الغرض:** واجهة للمستخدمين لتصفح مزودي الخدمات
- **الملفات:**
  - `get_by_category.php` - جلب مزودي الخدمات حسب الفئة
  - `get_services.php` - جلب خدمات مزود معين
- **الاستخدام:** للمستخدمين العاديين لتصفح الخدمات

### 2. مجلد `api/provider/` (للمزودين):
- **الغرض:** واجهة للمزودين لإدارة خدماتهم
- **الملفات:**
  - `get_my_services_with_categories.php` - جلب خدمات المزود مع تفاصيل الفئات
- **الاستخدام:** للمزودين لإدارة خدماتهم الشخصية

## 🗂️ هيكل المجلدات المحدث

```
asha_app_tag/
├── api/
│   ├── providers/          # للمستخدمين - تصفح المزودين
│   │   ├── get_by_category.php
│   │   └── get_services.php
│   ├── provider/           # للمزودين - إدارة الخدمات
│   │   └── get_my_services_with_categories.php
│   ├── services/           # إدارة الخدمات
│   ├── categories/         # إدارة الفئات
│   ├── bookings/           # إدارة الحجوزات
│   ├── reviews/            # إدارة التقييمات
│   ├── favorites/          # إدارة المفضلة
│   ├── ads/               # إدارة الإعلانات
│   └── auth/              # المصادقة
└── lib/
    ├── screens/
    │   ├── auth/           # صفحات المصادقة
    │   │   ├── login_screen.dart ✅
    │   │   └── register_screen.dart ✅
    │   └── user/           # صفحات المستخدم
    │       ├── booking_screen.dart ✅
    │       ├── service_details_screen.dart ✅
    │       ├── providers_by_category_screen.dart ✅
    │       └── provider_services_screen.dart ✅
    └── services/
        └── api_service.dart ✅
```

## 📋 الخطوات المطلوبة للتنفيذ:

### 1. حذف الملفات القديمة:

```bash
# حذف صفحات المصادقة القديمة
rm lib/screens/auth/login_user_page.dart
rm lib/screens/auth/signup_page.dart

# حذف صفحة الحجز القديمة
rm lib/screens/user/booking_page.dart
```

### 2. إضافة Routes الجديدة:

```dart
// في lib/routes/app_routes.dart
class AppRoutes {
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String serviceDetails = '/service-details';
  static const String providersByCategory = '/providers-by-category';
  static const String providerServices = '/provider-services';
  static const String booking = '/booking';
}
```

### 3. تحديث Navigation:

```dart
// في main.dart أو app.dart
MaterialApp(
  routes: {
    '/login': (context) => LoginScreen(),
    '/register': (context) => RegisterScreen(),
    '/service-details': (context) => ServiceDetailsScreen(),
    '/providers-by-category': (context) => ProvidersByCategoryScreen(),
    '/provider-services': (context) => ProviderServicesScreen(),
    '/booking': (context) => BookingScreen(),
  },
)
```

### 4. اختبار الوظائف:

#### أ. اختبار الإعلانات:
1. انتقل إلى الصفحة الرئيسية
2. انقر على إعلان
3. يجب أن ينتقل إلى الخدمة أو الفئة المحددة

#### ب. اختبار الفئات:
1. انقر على فئة (مثل التصوير)
2. يجب أن تظهر صفحة مزودي الخدمات في هذه الفئة
3. انقر على مزود خدمة
4. يجب أن تظهر صفحة خدمات المزود

#### ج. اختبار الخدمات:
1. انقر على خدمة
2. يجب أن تظهر صفحة تفاصيل الخدمة مع:
   - معلومات الخدمة والمزود
   - زر إضافة إلى المفضلة
   - زر حجز الخدمة
   - التقييمات والتعليقات
   - إمكانية إضافة تقييم (إذا كان المستخدم قد حجز وأكمل)

#### د. اختبار الحجز:
1. انقر على "حجز الخدمة"
2. إذا لم يكن المستخدم مسجل دخول:
   - سيتم توجيهه إلى صفحة تسجيل الدخول
   - أو صفحة إنشاء حساب جديد
3. بعد تسجيل الدخول:
   - سيتم توجيهه مباشرة إلى صفحة الحجز
4. في صفحة الحجز:
   - اختر التاريخ والوقت
   - أضف ملاحظات (اختياري)
   - انقر على "تأكيد الحجز"

#### ه. اختبار التقييمات:
1. يجب أن يكون المستخدم قد حجز الخدمة وأكمل الحجز
2. في صفحة تفاصيل الخدمة:
   - اختر تقييم (1-5 نجوم)
   - اكتب تعليق (اختياري)
   - انقر على "إرسال التقييم"

## 🔧 استكشاف الأخطاء:

### إذا لم تعمل API:
1. تأكد من إعدادات قاعدة البيانات
2. تحقق من صلاحيات الملفات
3. تأكد من تفعيل mod_rewrite في Apache

### إذا لم تعمل Flutter:
1. تأكد من تحديث dependencies
2. تحقق من إعدادات Config
3. تأكد من صحة URLs

### إذا لم تظهر البيانات:
1. تحقق من وجود بيانات في قاعدة البيانات
2. تأكد من أن is_active = 1 للعناصر
3. تحقق من صحة العلاقات بين الجداول

## 📞 الدعم:

إذا واجهت أي مشاكل:
1. تحقق من ملفات الـ logs
2. تأكد من إعدادات الخادم
3. تحقق من صحة البيانات في قاعدة البيانات

---

**ملاحظة:** هذا الدليل يغطي الأساسيات. قد تحتاج لتخصيص بعض الأجزاء حسب احتياجاتك الخاصة.