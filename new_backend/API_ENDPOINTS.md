# نقاط النهاية API - Asha App Backend
# API Endpoints - Asha App Backend

## 📡 نظرة عامة

هذا الملف يوثق جميع نقاط النهاية API المتاحة في الخادم الخلفي لتطبيق عشا.

## 🔐 المصادقة (Authentication)

### تسجيل الدخول
- **المسار**: `POST /api/auth/login.php`
- **الوصف**: تسجيل دخول المستخدم
- **المعاملات**:
  ```json
  {
    "identifier": "user@example.com",
    "password": "password123",
    "user_type": "user"
  }
  ```
- **الاستجابة**:
  ```json
  {
    "success": true,
    "message": "تم تسجيل الدخول بنجاح",
    "data": {
      "user": {
        "id": 1,
        "name": "اسم المستخدم",
        "email": "user@example.com",
        "phone": "+966500000000",
        "user_type": "user",
        "is_verified": 1,
        "profile_image": "profile.jpg"
      },
      "token": "jwt_token_here"
    }
  }
  ```

### إنشاء حساب
- **المسار**: `POST /api/auth/register.php`
- **الوصف**: إنشاء حساب مستخدم جديد
- **المعاملات**:
  ```json
  {
    "name": "اسم المستخدم",
    "email": "user@example.com",
    "phone": "+966500000000",
    "password": "password123",
    "user_type": "user"
  }
  ```
- **الاستجابة**:
  ```json
  {
    "success": true,
    "message": "تم إنشاء الحساب بنجاح. يرجى التحقق من رقم الهاتف",
    "data": {
      "user_id": 1,
      "verification_code": "123456"
    }
  }
  ```

### التحقق من الكود
- **المسار**: `POST /api/auth/verify.php`
- **الوصف**: التحقق من رمز التحقق
- **المعاملات**:
  ```json
  {
    "user_id": 1,
    "verification_code": "123456"
  }
  ```
- **الاستجابة**:
  ```json
  {
    "success": true,
    "message": "تم التحقق من الحساب بنجاح",
    "data": {
      "user": {
        "id": 1,
        "name": "اسم المستخدم",
        "email": "user@example.com",
        "user_type": "user",
        "is_verified": 1
      },
      "token": "jwt_token_here"
    }
  }
  ```

## 🛠️ الخدمات (Services)

### جلب جميع الخدمات
- **المسار**: `GET /api/services/get_all.php`
- **الوصف**: جلب جميع الخدمات المتاحة
- **المعاملات** (اختيارية):
  - `category_id`: معرف الفئة
  - `search`: نص البحث
  - `page`: رقم الصفحة (افتراضي: 1)
  - `limit`: عدد العناصر في الصفحة (افتراضي: 20)
- **مثال**: `GET /api/services/get_all.php?category_id=1&search=تنظيف&page=1&limit=10`
- **الاستجابة**:
  ```json
  {
    "success": true,
    "message": "تم جلب الخدمات بنجاح",
    "data": {
      "services": [
        {
          "id": 1,
          "title": "خدمة التنظيف",
          "description": "تنظيف شامل للمنازل",
          "price": 150.00,
          "category_name": "التنظيف",
          "provider_name": "شركة التنظيف",
          "avg_rating": 4.5,
          "review_count": 10,
          "favorite_count": 5
        }
      ],
      "pagination": {
        "current_page": 1,
        "per_page": 20,
        "total": 100,
        "total_pages": 5
      }
    }
  }
  ```

### جلب خدمة محددة
- **المسار**: `GET /api/services/get_by_id.php`
- **الوصف**: جلب تفاصيل خدمة محددة
- **المعاملات**:
  - `id`: معرف الخدمة
- **مثال**: `GET /api/services/get_by_id.php?id=1`
- **الاستجابة**:
  ```json
  {
    "success": true,
    "message": "تم جلب الخدمة بنجاح",
    "data": {
      "service": {
        "id": 1,
        "title": "خدمة التنظيف",
        "description": "تنظيف شامل للمنازل",
        "price": 150.00,
        "category_name": "التنظيف",
        "provider_name": "شركة التنظيف",
        "avg_rating": 4.5,
        "review_count": 10,
        "favorite_count": 5
      },
      "reviews": [
        {
          "id": 1,
          "rating": 5,
          "comment": "خدمة ممتازة",
          "user_name": "أحمد محمد",
          "created_at": "2024-01-01 10:00:00"
        }
      ]
    }
  }
  ```

### إضافة خدمة جديدة
- **المسار**: `POST /api/services/add_service.php`
- **الوصف**: إضافة خدمة جديدة (للمزودين فقط)
- **المعاملات**:
  ```json
  {
    "title": "خدمة التنظيف",
    "description": "تنظيف شامل للمنازل",
    "price": 150.00,
    "category_id": 1,
    "provider_id": 2,
    "location": "الرياض",
    "contact_phone": "+966500000000",
    "contact_email": "service@example.com",
    "images": ["image1.jpg", "image2.jpg"]
  }
  ```
- **الاستجابة**:
  ```json
  {
    "success": true,
    "message": "تم إضافة الخدمة بنجاح",
    "data": {
      "service": {
        "id": 1,
        "title": "خدمة التنظيف",
        "description": "تنظيف شامل للمنازل",
        "price": 150.00,
        "category_name": "التنظيف",
        "provider_name": "شركة التنظيف"
      }
    }
  }
  ```

### تحديث الخدمة
- **المسار**: `PUT /api/services/update_service.php`
- **الوصف**: تحديث بيانات الخدمة
- **المعاملات**:
  ```json
  {
    "id": 1,
    "title": "خدمة التنظيف المحدثة",
    "description": "تنظيف شامل للمنازل مع تعقيم",
    "price": 200.00,
    "category_id": 1,
    "location": "الرياض",
    "contact_phone": "+966500000000",
    "contact_email": "service@example.com",
    "is_active": 1
  }
  ```
- **الاستجابة**:
  ```json
  {
    "success": true,
    "message": "تم تحديث الخدمة بنجاح",
    "data": {
      "service": {
        "id": 1,
        "title": "خدمة التنظيف المحدثة",
        "description": "تنظيف شامل للمنازل مع تعقيم",
        "price": 200.00,
        "category_name": "التنظيف",
        "provider_name": "شركة التنظيف"
      }
    }
  }
  ```

## 📂 الفئات (Categories)

### جلب جميع الفئات
- **المسار**: `GET /api/categories/get_all.php`
- **الوصف**: جلب جميع فئات الخدمات
- **الاستجابة**:
  ```json
  {
    "success": true,
    "message": "تم جلب الفئات بنجاح",
    "data": {
      "categories": [
        {
          "id": 1,
          "name": "التنظيف",
          "description": "خدمات التنظيف",
          "icon": "cleaning.png",
          "services_count": 25
        }
      ]
    }
  }
  ```

## 🔧 الأخطاء الشائعة

### خطأ في الطريقة
```json
{
  "success": false,
  "message": "Method not allowed"
}
```

### خطأ في المدخلات
```json
{
  "success": false,
  "message": "جميع الحقول مطلوبة"
}
```

### خطأ في الخادم
```json
{
  "success": false,
  "message": "خطأ في الخادم"
}
```

## 🔒 الأمان

### Headers المطلوبة
```
Content-Type: application/json
Authorization: Bearer <jwt_token> (للمعاملات المحمية)
```

### CORS
يتم إعداد CORS تلقائياً لجميع الطلبات.

## 📊 أمثلة الاستخدام

### مثال تسجيل الدخول
```bash
curl -X POST http://localhost/asha_app_h/api/auth/login.php \
  -H "Content-Type: application/json" \
  -d '{
    "identifier": "admin@asha-app.com",
    "password": "password",
    "user_type": "admin"
  }'
```

### مثال جلب الخدمات
```bash
curl -X GET "http://localhost/asha_app_h/api/services/get_all.php?category_id=1&page=1&limit=10"
```

### مثال إضافة خدمة
```bash
curl -X POST http://localhost/asha_app_h/api/services/add_service.php \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{
    "title": "خدمة التنظيف",
    "description": "تنظيف شامل للمنازل",
    "price": 150.00,
    "category_id": 1,
    "provider_id": 2,
    "location": "الرياض"
  }'
```

---

**ملاحظة**: جميع الاستجابات تكون بصيغة JSON مع ترميز UTF-8. 