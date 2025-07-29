# دليل فئات الخدمة - Asha App

## نظرة عامة

تم إضافة نظام فئات الخدمة إلى التطبيق، حيث يمكن لكل خدمة أن تمتلك عدة فئات خدمة مختلفة. كل فئة خدمة تحتوي على تفاصيل محددة مثل السعر والصورة والمواصفات.

## هيكل قاعدة البيانات

### جدول `service_categories`

```sql
CREATE TABLE service_categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    service_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    image VARCHAR(255),
    size VARCHAR(100),
    dimensions VARCHAR(100),
    location VARCHAR(255),
    quantity INT DEFAULT 1,
    duration VARCHAR(100),
    materials TEXT,
    additional_features TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE
);
```

### الحقول المطلوبة
- `service_id`: معرف الخدمة
- `name`: اسم فئة الخدمة
- `price`: السعر

### الحقول الاختيارية
- `description`: وصف فئة الخدمة
- `image`: رابط صورة فئة الخدمة
- `size`: الحجم (صغير، متوسط، كبير)
- `dimensions`: الأبعاد (مثل: 3 غرف، 100 متر مربع)
- `location`: الموقع
- `quantity`: الكمية (افتراضي: 1)
- `duration`: المدة المطلوبة (مثل: 2-3 ساعات)
- `materials`: المواد المستخدمة
- `additional_features`: ميزات إضافية

## API Endpoints

### 1. جلب فئات الخدمة
```
GET /api/services/get_service_categories.php?service_id={service_id}
```

**الاستجابة:**
```json
{
  "success": true,
  "message": "تم جلب فئات الخدمة بنجاح",
  "data": [
    {
      "id": 1,
      "service_id": 1,
      "name": "تنظيف غرف النوم",
      "description": "تنظيف شامل لغرف النوم مع تغيير الملاءات",
      "price": 50.00,
      "image": "bedroom_cleaning.jpg",
      "size": "متوسط",
      "dimensions": "3 غرف",
      "location": "صنعاء",
      "quantity": 1,
      "duration": "2-3 ساعات",
      "materials": "منظفات آمنة، مكنسة كهربائية",
      "additional_features": "تغيير الملاءات، تنظيف النوافذ",
      "is_active": true,
      "created_at": "2024-01-01 10:00:00",
      "updated_at": "2024-01-01 10:00:00"
    }
  ],
  "service_info": {
    "id": 1,
    "title": "تنظيف منزل شامل",
    "description": "تنظيف شامل للمنزل",
    "price": 150.00,
    "images": ["cleaning1.jpg", "cleaning2.jpg"],
    "city": "صنعاء",
    "provider_name": "شركة النظافة المثالية",
    "provider_phone": "777200001",
    "category_name": "تنظيف المنازل"
  },
  "total_categories": 1
}
```

### 2. إضافة فئة خدمة جديدة
```
POST /api/services/add_service_category.php
```

**البيانات المطلوبة:**
```json
{
  "service_id": 1,
  "name": "اسم فئة الخدمة",
  "description": "وصف فئة الخدمة",
  "price": 100.00,
  "image": "image_url.jpg",
  "size": "متوسط",
  "dimensions": "3 غرف",
  "location": "صنعاء",
  "quantity": 1,
  "duration": "2-3 ساعات",
  "materials": "المواد المستخدمة",
  "additional_features": "ميزات إضافية",
  "is_active": true
}
```

## واجهة المستخدم (Flutter)

### 1. نموذج فئة الخدمة
```dart
class ServiceCategory {
  final int id;
  final int serviceId;
  final String name;
  final String description;
  final double price;
  final String image;
  final String? size;
  final String? dimensions;
  final String? location;
  final int quantity;
  final String? duration;
  final String? materials;
  final String? additionalFeatures;
  final bool isActive;
  final String createdAt;
  final String updatedAt;
}
```

### 2. خدمة API
```dart
class ServiceCategoryService {
  // جلب فئات الخدمة
  static Future<ServiceCategoryResponse> getServiceCategories(int serviceId);
  
  // إضافة فئة خدمة جديدة
  static Future<ServiceCategoryResponse> addServiceCategory(Map<String, dynamic> categoryData);
  
  // تحديث فئة خدمة
  static Future<ServiceCategoryResponse> updateServiceCategory(int categoryId, Map<String, dynamic> categoryData);
  
  // حذف فئة خدمة
  static Future<bool> deleteServiceCategory(int categoryId);
}
```

### 3. صفحات الواجهة

#### صفحة تفاصيل الخدمة مع فئات الخدمة
- `lib/screens/user/service_details_page.dart`
- تعرض تفاصيل الخدمة مع قائمة فئات الخدمة
- إمكانية حجز فئة خدمة محددة

#### صفحة إضافة فئة خدمة (للمزودين)
- `lib/screens/provider/add_service_category_page.dart`
- نموذج لإضافة فئة خدمة جديدة
- تحقق من صحة البيانات

#### Widget عرض فئة الخدمة
- `lib/widgets/service_category_card.dart`
- عرض معلومات فئة الخدمة بشكل جميل
- زر الحجز المباشر

## البيانات الافتراضية

تم إضافة 45 فئة خدمة افتراضية موزعة على 15 خدمة مختلفة:

### أمثلة على فئات الخدمة:

1. **خدمة تنظيف المنزل الشامل:**
   - تنظيف غرف النوم (50 ريال)
   - تنظيف المطبخ (60 ريال)
   - تنظيف الحمامات (40 ريال)

2. **خدمة إصلاح الكهرباء:**
   - إصلاح القواطع (80 ريال)
   - إصلاح المآخذ (60 ريال)
   - تركيب إضاءة (100 ريال)

3. **خدمة تركيب المكيف:**
   - مكيف سبليت 1.5 طن (300 ريال)
   - مكيف سبليت 2 طن (400 ريال)
   - مكيف سبليت 3 طن (500 ريال)

## كيفية الاستخدام

### للمستخدمين:
1. تصفح الخدمات المتاحة
2. اختر خدمة معينة
3. عرض فئات الخدمة المتاحة
4. اختيار فئة الخدمة المناسبة
5. حجز الخدمة

### للمزودين:
1. تسجيل الدخول كـ provider
2. إضافة خدمات جديدة
3. إضافة فئات خدمة لكل خدمة
4. إدارة فئات الخدمة (تعديل، حذف)

## اختبار النظام

### ملف الاختبار:
- `asha_app_tag/test_service_categories.php`
- يختبر جميع جوانب النظام
- يتحقق من صحة البيانات والـ API

### خطوات الاختبار:
1. تشغيل ملف الاختبار
2. التحقق من وجود جدول فئات الخدمة
3. اختبار جلب فئات الخدمة
4. اختبار إضافة فئة خدمة جديدة
5. مراجعة الإحصائيات

## الميزات المستقبلية

1. **فلترة فئات الخدمة:**
   - حسب السعر
   - حسب الحجم
   - حسب الموقع

2. **بحث في فئات الخدمة:**
   - البحث بالاسم
   - البحث بالوصف

3. **مقارنة فئات الخدمة:**
   - مقارنة الأسعار
   - مقارنة الميزات

4. **تقييم فئات الخدمة:**
   - تقييم منفصل لكل فئة
   - تعليقات المستخدمين

## استكشاف الأخطاء

### مشاكل شائعة:

1. **فئة الخدمة لا تظهر:**
   - التحقق من `is_active = 1`
   - التحقق من وجود الخدمة المرتبطة

2. **خطأ في API:**
   - التحقق من صحة `service_id`
   - التحقق من اتصال قاعدة البيانات

3. **خطأ في الواجهة:**
   - التحقق من صحة البيانات المرسلة
   - التحقق من اتصال الإنترنت

## الدعم

للمساعدة أو الإبلاغ عن مشاكل:
- مراجعة ملفات السجل
- اختبار الاتصال بقاعدة البيانات
- التحقق من إعدادات الخادم 