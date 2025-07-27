# توثيق API الشامل لتطبيق Asha App

## مقدمة

يوفر هذا المستند توثيقاً شاملاً لجميع endpoints الخاصة بـ API تطبيق Asha App. تم تصميم هذا API ليكون متوافقاً مع معايير REST ويدعم جميع وظائف التطبيق من المصادقة إلى إدارة الخدمات والحجوزات.

## معلومات عامة

- **URL الأساسي**: `https://your-domain.com/`
- **إصدار API**: v1
- **تنسيق البيانات**: JSON
- **ترميز الأحرف**: UTF-8
- **طريقة المصادقة**: Bearer Token (JWT)

## رؤوس HTTP المطلوبة

### للطلبات التي تحتاج مصادقة:
```
Authorization: Bearer {jwt_token}
Content-Type: application/json
```

### للطلبات العادية:
```
Content-Type: application/json
```

## تنسيق الاستجابات

### استجابة النجاح:
```json
{
  "success": true,
  "message": "رسالة النجاح",
  "data": {
    // البيانات المطلوبة
  },
  "timestamp": "2024-01-01 12:00:00"
}
```

### استجابة الخطأ:
```json
{
  "success": false,
  "message": "رسالة الخطأ",
  "timestamp": "2024-01-01 12:00:00"
}
```

## رموز الحالة HTTP

| الرمز | المعنى | الوصف |
|-------|--------|--------|
| 200 | OK | نجح الطلب |
| 201 | Created | تم إنشاء المورد بنجاح |
| 400 | Bad Request | طلب غير صحيح |
| 401 | Unauthorized | غير مصرح |
| 403 | Forbidden | ممنوع |
| 404 | Not Found | غير موجود |
| 405 | Method Not Allowed | طريقة غير مدعومة |
| 500 | Internal Server Error | خطأ في الخادم |




# 1. endpoints المصادقة (Authentication)

## 1.1 تسجيل مستخدم جديد

### المعلومات الأساسية
- **URL**: `/api/auth/register.php`
- **الطريقة**: `POST`
- **المصادقة**: غير مطلوبة
- **الوصف**: إنشاء حساب مستخدم جديد في النظام

### البيانات المطلوبة (Request Body)
```json
{
  "name": "string (مطلوب)",
  "email": "string (مطلوب)",
  "phone": "string (مطلوب)",
  "password": "string (مطلوب، 6 أحرف على الأقل)",
  "user_type": "string (اختياري، افتراضي: user)",
  "bio": "string (اختياري)",
  "website": "string (اختياري)",
  "address": "string (اختياري)",
  "city": "string (اختياري)",
  "latitude": "number (اختياري)",
  "longitude": "number (اختياري)",
  "user_category": "string (اختياري)",
  "is_yemeni_account": "boolean (اختياري، افتراضي: false)"
}
```

### مثال على الطلب
```bash
curl -X POST https://your-domain.com/api/auth/register.php \
  -H "Content-Type: application/json" \
  -d '{
    "name": "أحمد محمد علي",
    "email": "ahmed@example.com",
    "phone": "+967777777777",
    "password": "password123",
    "city": "صنعاء",
    "is_yemeni_account": true
  }'
```

### استجابة النجاح (201)
```json
{
  "success": true,
  "message": "تم إنشاء الحساب بنجاح",
  "data": {
    "user_id": 123,
    "message": "تم إنشاء الحساب بنجاح. يرجى التحقق من بريدك الإلكتروني"
  },
  "timestamp": "2024-01-01 12:00:00"
}
```

### أخطاء محتملة
- **400**: البيانات المطلوبة مفقودة أو غير صحيحة
- **400**: البريد الإلكتروني أو رقم الهاتف مستخدم مسبقاً
- **500**: خطأ في الخادم

---

## 1.2 تسجيل الدخول

### المعلومات الأساسية
- **URL**: `/api/auth/login.php`
- **الطريقة**: `POST`
- **المصادقة**: غير مطلوبة
- **الوصف**: تسجيل دخول المستخدم والحصول على رمز الوصول

### البيانات المطلوبة (Request Body)
```json
{
  "email": "string (مطلوب)",
  "password": "string (مطلوب)",
  "user_type": "string (اختياري، للتحقق من نوع المستخدم)"
}
```

### مثال على الطلب
```bash
curl -X POST https://your-domain.com/api/auth/login.php \
  -H "Content-Type: application/json" \
  -d '{
    "email": "ahmed@example.com",
    "password": "password123"
  }'
```

### استجابة النجاح (200)
```json
{
  "success": true,
  "message": "تم تسجيل الدخول بنجاح",
  "data": {
    "user": {
      "id": 123,
      "name": "أحمد محمد علي",
      "email": "ahmed@example.com",
      "phone": "+967777777777",
      "user_type": "user",
      "profile_image": "uploads/profiles/123.jpg",
      "is_verified": true,
      "is_active": true,
      "rating": 4.5,
      "review_count": 10,
      "bio": "مستخدم نشط في التطبيق",
      "website": "https://example.com",
      "address": "شارع الزبيري، صنعاء",
      "city": "صنعاء",
      "latitude": 15.3694,
      "longitude": 44.1910,
      "is_yemeni_account": true,
      "created_at": "2024-01-01 10:00:00",
      "updated_at": "2024-01-01 12:00:00"
    },
    "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
  },
  "timestamp": "2024-01-01 12:00:00"
}
```

### أخطاء محتملة
- **400**: البريد الإلكتروني أو كلمة المرور مفقودة
- **401**: بيانات الدخول غير صحيحة
- **401**: الحساب غير مفعل
- **500**: خطأ في الخادم

---

## 1.3 التحقق من الحساب

### المعلومات الأساسية
- **URL**: `/api/auth/verify.php`
- **الطريقة**: `POST`
- **المصادقة**: غير مطلوبة
- **الوصف**: تفعيل الحساب باستخدام كود التحقق المرسل عبر البريد الإلكتروني

### البيانات المطلوبة (Request Body)
```json
{
  "email": "string (مطلوب)",
  "code": "string (مطلوب، كود التحقق المكون من 6 أرقام)"
}
```

### مثال على الطلب
```bash
curl -X POST https://your-domain.com/api/auth/verify.php \
  -H "Content-Type: application/json" \
  -d '{
    "email": "ahmed@example.com",
    "code": "123456"
  }'
```

### استجابة النجاح (200)
```json
{
  "success": true,
  "message": "تم تفعيل الحساب بنجاح",
  "data": {
    "message": "تم تفعيل الحساب بنجاح"
  },
  "timestamp": "2024-01-01 12:00:00"
}
```

### أخطاء محتملة
- **400**: البريد الإلكتروني أو كود التحقق مفقود
- **400**: كود التحقق غير صحيح
- **404**: المستخدم غير موجود
- **500**: خطأ في الخادم

---

## 1.4 نسيان كلمة المرور

### المعلومات الأساسية
- **URL**: `/api/auth/forgot_password.php`
- **الطريقة**: `POST`
- **المصادقة**: غير مطلوبة
- **الوصف**: إرسال كود إعادة تعيين كلمة المرور عبر البريد الإلكتروني

### البيانات المطلوبة (Request Body)
```json
{
  "email": "string (مطلوب)"
}
```

### مثال على الطلب
```bash
curl -X POST https://your-domain.com/api/auth/forgot_password.php \
  -H "Content-Type: application/json" \
  -d '{
    "email": "ahmed@example.com"
  }'
```

### استجابة النجاح (200)
```json
{
  "success": true,
  "message": "تم إرسال كود إعادة تعيين كلمة المرور",
  "data": {
    "message": "تم إرسال كود إعادة تعيين كلمة المرور"
  },
  "timestamp": "2024-01-01 12:00:00"
}
```

### أخطاء محتملة
- **400**: البريد الإلكتروني مفقود
- **404**: البريد الإلكتروني غير مسجل
- **500**: خطأ في الخادم

---

## 1.5 إعادة تعيين كلمة المرور

### المعلومات الأساسية
- **URL**: `/api/auth/reset_password.php`
- **الطريقة**: `POST`
- **المصادقة**: غير مطلوبة
- **الوصف**: تغيير كلمة المرور باستخدام كود إعادة التعيين

### البيانات المطلوبة (Request Body)
```json
{
  "email": "string (مطلوب)",
  "code": "string (مطلوب، كود إعادة التعيين)",
  "new_password": "string (مطلوب، 6 أحرف على الأقل)"
}
```

### مثال على الطلب
```bash
curl -X POST https://your-domain.com/api/auth/reset_password.php \
  -H "Content-Type: application/json" \
  -d '{
    "email": "ahmed@example.com",
    "code": "123456",
    "new_password": "newpassword123"
  }'
```

### استجابة النجاح (200)
```json
{
  "success": true,
  "message": "تم تغيير كلمة المرور بنجاح",
  "data": {
    "message": "تم تغيير كلمة المرور بنجاح"
  },
  "timestamp": "2024-01-01 12:00:00"
}
```

### أخطاء محتملة
- **400**: البيانات المطلوبة مفقودة
- **400**: كود إعادة التعيين غير صحيح
- **400**: كلمة المرور قصيرة جداً
- **500**: خطأ في الخادم


# 2. endpoints الخدمات (Services)

## 2.1 جلب جميع الخدمات

### المعلومات الأساسية
- **URL**: `/api/services/get_all.php`
- **الطريقة**: `GET`
- **المصادقة**: غير مطلوبة
- **الوصف**: جلب قائمة بجميع الخدمات المتاحة مع دعم الفلترة والبحث والترقيم

### المعاملات الاختيارية (Query Parameters)
```
page: number (رقم الصفحة، افتراضي: 1)
limit: number (عدد العناصر في الصفحة، افتراضي: 20)
category_id: number (فلترة حسب الفئة)
city: string (فلترة حسب المدينة)
search: string (البحث في العنوان والوصف والعلامات)
min_price: number (الحد الأدنى للسعر)
max_price: number (الحد الأقصى للسعر)
is_featured: boolean (الخدمات المميزة فقط)
sort_by: string (ترتيب حسب: created_at, price, rating, افتراضي: created_at)
sort_order: string (اتجاه الترتيب: ASC, DESC, افتراضي: DESC)
```

### مثال على الطلب
```bash
curl -X GET "https://your-domain.com/api/services/get_all.php?page=1&limit=10&category_id=1&city=صنعاء&search=تصوير&min_price=100&max_price=1000&sort_by=rating&sort_order=DESC"
```

### استجابة النجاح (200)
```json
{
  "success": true,
  "message": "تم جلب الخدمات بنجاح",
  "data": {
    "services": [
      {
        "id": 1,
        "provider_id": 123,
        "category_id": 1,
        "title": "خدمة التصوير الفوتوغرافي للأعراس",
        "description": "خدمة تصوير احترافية للأعراس والمناسبات الخاصة",
        "price": 500.00,
        "original_price": 600.00,
        "duration": 480,
        "images": [
          "uploads/services/1/image1.jpg",
          "uploads/services/1/image2.jpg"
        ],
        "is_active": true,
        "is_verified": true,
        "is_featured": true,
        "rating": 4.8,
        "total_ratings": 25,
        "booking_count": 50,
        "favorite_count": 15,
        "specifications": {
          "camera_type": "DSLR",
          "experience_years": 5,
          "team_size": 2
        },
        "tags": ["تصوير", "أعراس", "مناسبات"],
        "location": "شارع الزبيري، صنعاء",
        "latitude": 15.3694,
        "longitude": 44.1910,
        "address": "شارع الزبيري، حي السبعين",
        "city": "صنعاء",
        "max_guests": 200,
        "cancellation_policy": "يمكن الإلغاء قبل 48 ساعة",
        "deposit_required": true,
        "deposit_amount": 100.00,
        "payment_terms": {
          "advance_payment": 50,
          "payment_methods": ["cash", "bank_transfer"]
        },
        "availability": {
          "monday": true,
          "tuesday": true,
          "wednesday": true,
          "thursday": true,
          "friday": true,
          "saturday": true,
          "sunday": false
        },
        "created_at": "2024-01-01 10:00:00",
        "updated_at": "2024-01-01 12:00:00",
        "category_name": "التصوير",
        "provider_name": "أحمد المصور",
        "provider_rating": 4.9,
        "provider_image": "uploads/profiles/123.jpg",
        "favorites_count": 15,
        "avg_rating": 4.8,
        "reviews_count": 25
      }
    ],
    "pagination": {
      "current_page": 1,
      "total_pages": 5,
      "total_items": 100,
      "items_per_page": 20
    }
  },
  "timestamp": "2024-01-01 12:00:00"
}
```

### أخطاء محتملة
- **500**: خطأ في الخادم

---

## 2.2 جلب خدمة بالمعرف

### المعلومات الأساسية
- **URL**: `/api/services/get_by_id.php`
- **الطريقة**: `GET`
- **المصادقة**: غير مطلوبة
- **الوصف**: جلب تفاصيل خدمة محددة مع العروض والتقييمات والخدمات المشابهة

### المعاملات المطلوبة (Query Parameters)
```
id: number (معرف الخدمة)
```

### مثال على الطلب
```bash
curl -X GET "https://your-domain.com/api/services/get_by_id.php?id=1"
```

### استجابة النجاح (200)
```json
{
  "success": true,
  "message": "تم جلب تفاصيل الخدمة بنجاح",
  "data": {
    "service": {
      "id": 1,
      "provider_id": 123,
      "category_id": 1,
      "title": "خدمة التصوير الفوتوغرافي للأعراس",
      "description": "خدمة تصوير احترافية للأعراس والمناسبات الخاصة مع فريق محترف وأحدث المعدات",
      "price": 500.00,
      "original_price": 600.00,
      "duration": 480,
      "images": [
        "uploads/services/1/image1.jpg",
        "uploads/services/1/image2.jpg",
        "uploads/services/1/image3.jpg"
      ],
      "is_active": true,
      "is_verified": true,
      "is_featured": true,
      "rating": 4.8,
      "total_ratings": 25,
      "booking_count": 50,
      "favorite_count": 15,
      "specifications": {
        "camera_type": "Canon EOS R5",
        "experience_years": 5,
        "team_size": 2,
        "editing_included": true,
        "delivery_time": "7-10 أيام"
      },
      "tags": ["تصوير", "أعراس", "مناسبات", "احترافي"],
      "location": "شارع الزبيري، صنعاء",
      "latitude": 15.3694,
      "longitude": 44.1910,
      "address": "شارع الزبيري، حي السبعين، بجانب مول السبعين",
      "city": "صنعاء",
      "max_guests": 200,
      "cancellation_policy": "يمكن الإلغاء قبل 48 ساعة مع استرداد كامل للمبلغ",
      "deposit_required": true,
      "deposit_amount": 100.00,
      "payment_terms": {
        "advance_payment": 50,
        "payment_methods": ["cash", "bank_transfer", "mobile_money"],
        "payment_schedule": "50% مقدم، 50% عند التسليم"
      },
      "availability": {
        "monday": true,
        "tuesday": true,
        "wednesday": true,
        "thursday": true,
        "friday": true,
        "saturday": true,
        "sunday": false
      },
      "created_at": "2024-01-01 10:00:00",
      "updated_at": "2024-01-01 12:00:00",
      "category_name": "التصوير",
      "category_description": "خدمات التصوير الفوتوغرافي والفيديو",
      "provider_name": "أحمد المصور",
      "provider_email": "ahmed@photographer.com",
      "provider_phone": "+967777777777",
      "provider_rating": 4.9,
      "provider_review_count": 45,
      "provider_image": "uploads/profiles/123.jpg",
      "provider_bio": "مصور محترف متخصص في تصوير الأعراس والمناسبات",
      "provider_website": "https://ahmedphotographer.com",
      "provider_address": "شارع الزبيري، صنعاء",
      "provider_city": "صنعاء",
      "favorites_count": 15,
      "avg_rating": 4.8,
      "reviews_count": 25
    },
    "offers": [
      {
        "id": 1,
        "service_id": 1,
        "title": "عرض خاص للأعراس الصيفية",
        "description": "خصم 20% على جميع باقات التصوير",
        "discount_percentage": 20.00,
        "discount_amount": null,
        "start_date": "2024-06-01",
        "end_date": "2024-08-31",
        "is_active": true,
        "created_at": "2024-05-15 10:00:00"
      }
    ],
    "reviews": [
      {
        "id": 1,
        "user_id": 456,
        "service_id": 1,
        "booking_id": 789,
        "rating": 5,
        "comment": "خدمة ممتازة والصور كانت رائعة",
        "created_at": "2024-01-15 14:30:00",
        "user_name": "فاطمة أحمد",
        "user_image": "uploads/profiles/456.jpg"
      }
    ],
    "similar_services": [
      {
        "id": 2,
        "title": "تصوير الخطوبة والملكة",
        "price": 300.00,
        "images": ["uploads/services/2/image1.jpg"],
        "rating": 4.5,
        "city": "صنعاء",
        "provider_name": "سارة المصورة"
      }
    ]
  },
  "timestamp": "2024-01-01 12:00:00"
}
```

### أخطاء محتملة
- **400**: معرف الخدمة مفقود
- **404**: الخدمة غير موجودة
- **500**: خطأ في الخادم


# 3. endpoints الحجوزات (Bookings)

## 3.1 إنشاء حجز جديد

### المعلومات الأساسية
- **URL**: `/api/bookings/create.php`
- **الطريقة**: `POST`
- **المصادقة**: مطلوبة (Bearer Token)
- **الوصف**: إنشاء حجز جديد لخدمة معينة

### البيانات المطلوبة (Request Body)
```json
{
  "service_id": "number (مطلوب)",
  "booking_date": "string (مطلوب، تنسيق: YYYY-MM-DD)",
  "booking_time": "string (مطلوب، تنسيق: HH:MM)",
  "notes": "string (اختياري)"
}
```

### مثال على الطلب
```bash
curl -X POST https://your-domain.com/api/bookings/create.php \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..." \
  -d '{
    "service_id": 1,
    "booking_date": "2024-02-15",
    "booking_time": "14:00",
    "notes": "حفل زفاف في قاعة الياسمين"
  }'
```

### استجابة النجاح (201)
```json
{
  "success": true,
  "message": "تم إنشاء الحجز بنجاح",
  "data": {
    "id": 789,
    "user_id": 456,
    "service_id": 1,
    "provider_id": 123,
    "booking_date": "2024-02-15",
    "booking_time": "14:00:00",
    "status": "pending",
    "total_price": 500.00,
    "payment_status": "pending",
    "payment_method": null,
    "notes": "حفل زفاف في قاعة الياسمين",
    "created_at": "2024-01-01 12:00:00",
    "updated_at": "2024-01-01 12:00:00",
    "service_title": "خدمة التصوير الفوتوغرافي للأعراس",
    "service_images": [
      "uploads/services/1/image1.jpg"
    ],
    "provider_name": "أحمد المصور",
    "provider_phone": "+967777777777"
  },
  "timestamp": "2024-01-01 12:00:00"
}
```

### أخطاء محتملة
- **400**: البيانات المطلوبة مفقودة أو غير صحيحة
- **400**: الموعد في الماضي
- **400**: الموعد محجوز مسبقاً
- **400**: لا يمكن حجز خدمتك الخاصة
- **401**: رمز المصادقة مطلوب
- **404**: الخدمة غير موجودة
- **500**: خطأ في الخادم

---

## 3.2 جلب حجوزات المستخدم

### المعلومات الأساسية
- **URL**: `/api/bookings/get_user_bookings.php`
- **الطريقة**: `GET`
- **المصادقة**: مطلوبة (Bearer Token)
- **الوصف**: جلب جميع حجوزات المستخدم الحالي

### المعاملات الاختيارية (Query Parameters)
```
page: number (رقم الصفحة، افتراضي: 1)
limit: number (عدد العناصر في الصفحة، افتراضي: 20)
status: string (فلترة حسب الحالة: pending, confirmed, completed, cancelled)
```

### مثال على الطلب
```bash
curl -X GET "https://your-domain.com/api/bookings/get_user_bookings.php?page=1&status=confirmed" \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
```

### استجابة النجاح (200)
```json
{
  "success": true,
  "message": "تم جلب الحجوزات بنجاح",
  "data": {
    "bookings": [
      {
        "id": 789,
        "user_id": 456,
        "service_id": 1,
        "provider_id": 123,
        "booking_date": "2024-02-15",
        "booking_time": "14:00:00",
        "status": "confirmed",
        "total_price": 500.00,
        "payment_status": "paid",
        "payment_method": "bank_transfer",
        "notes": "حفل زفاف في قاعة الياسمين",
        "created_at": "2024-01-01 12:00:00",
        "updated_at": "2024-01-02 10:00:00",
        "service_title": "خدمة التصوير الفوتوغرافي للأعراس",
        "service_images": [
          "uploads/services/1/image1.jpg",
          "uploads/services/1/image2.jpg"
        ],
        "service_price": 500.00,
        "service_location": "شارع الزبيري، صنعاء",
        "provider_name": "أحمد المصور",
        "provider_phone": "+967777777777",
        "provider_image": "uploads/profiles/123.jpg",
        "category_name": "التصوير",
        "is_past": false,
        "can_cancel": false,
        "can_review": false
      }
    ],
    "pagination": {
      "current_page": 1,
      "total_pages": 3,
      "total_items": 15,
      "items_per_page": 20
    }
  },
  "timestamp": "2024-01-01 12:00:00"
}
```

### أخطاء محتملة
- **401**: رمز المصادقة مطلوب
- **500**: خطأ في الخادم

---

# 4. endpoints المفضلة (Favorites)

## 4.1 إضافة/إزالة من المفضلة

### المعلومات الأساسية
- **URL**: `/api/favorites/toggle.php`
- **الطريقة**: `POST`
- **المصادقة**: مطلوبة (Bearer Token)
- **الوصف**: إضافة خدمة إلى المفضلة أو إزالتها منها

### البيانات المطلوبة (Request Body)
```json
{
  "service_id": "number (مطلوب)"
}
```

### مثال على الطلب
```bash
curl -X POST https://your-domain.com/api/favorites/toggle.php \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..." \
  -d '{
    "service_id": 1
  }'
```

### استجابة النجاح (200)
```json
{
  "success": true,
  "message": "تم إضافة الخدمة إلى المفضلة",
  "data": {
    "is_favorite": true,
    "service_id": 1,
    "service_title": "خدمة التصوير الفوتوغرافي للأعراس"
  },
  "timestamp": "2024-01-01 12:00:00"
}
```

### أخطاء محتملة
- **400**: معرف الخدمة مطلوب
- **401**: رمز المصادقة مطلوب
- **404**: الخدمة غير موجودة
- **500**: خطأ في الخادم

---

## 4.2 جلب مفضلات المستخدم

### المعلومات الأساسية
- **URL**: `/api/favorites/get_user_favorites.php`
- **الطريقة**: `GET`
- **المصادقة**: مطلوبة (Bearer Token)
- **الوصف**: جلب جميع الخدمات المفضلة للمستخدم الحالي

### المعاملات الاختيارية (Query Parameters)
```
page: number (رقم الصفحة، افتراضي: 1)
limit: number (عدد العناصر في الصفحة، افتراضي: 20)
```

### مثال على الطلب
```bash
curl -X GET "https://your-domain.com/api/favorites/get_user_favorites.php?page=1" \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
```

### استجابة النجاح (200)
```json
{
  "success": true,
  "message": "تم جلب المفضلات بنجاح",
  "data": {
    "favorites": [
      {
        "favorite_id": 10,
        "favorited_at": "2024-01-01 12:00:00",
        "id": 1,
        "provider_id": 123,
        "category_id": 1,
        "title": "خدمة التصوير الفوتوغرافي للأعراس",
        "description": "خدمة تصوير احترافية للأعراس والمناسبات الخاصة",
        "price": 500.00,
        "original_price": 600.00,
        "duration": 480,
        "images": [
          "uploads/services/1/image1.jpg",
          "uploads/services/1/image2.jpg"
        ],
        "is_active": true,
        "is_verified": true,
        "is_featured": true,
        "rating": 4.8,
        "total_ratings": 25,
        "booking_count": 50,
        "favorite_count": 15,
        "specifications": {
          "camera_type": "Canon EOS R5",
          "experience_years": 5,
          "team_size": 2
        },
        "tags": ["تصوير", "أعراس", "مناسبات"],
        "location": "شارع الزبيري، صنعاء",
        "latitude": 15.3694,
        "longitude": 44.1910,
        "address": "شارع الزبيري، حي السبعين",
        "city": "صنعاء",
        "max_guests": 200,
        "cancellation_policy": "يمكن الإلغاء قبل 48 ساعة",
        "deposit_required": true,
        "deposit_amount": 100.00,
        "payment_terms": {
          "advance_payment": 50,
          "payment_methods": ["cash", "bank_transfer"]
        },
        "availability": {
          "monday": true,
          "tuesday": true,
          "wednesday": true,
          "thursday": true,
          "friday": true,
          "saturday": true,
          "sunday": false
        },
        "created_at": "2024-01-01 10:00:00",
        "updated_at": "2024-01-01 12:00:00",
        "category_name": "التصوير",
        "provider_name": "أحمد المصور",
        "provider_rating": 4.9,
        "provider_image": "uploads/profiles/123.jpg",
        "avg_rating": 4.8,
        "reviews_count": 25,
        "is_favorite": true
      }
    ],
    "pagination": {
      "current_page": 1,
      "total_pages": 2,
      "total_items": 8,
      "items_per_page": 20
    }
  },
  "timestamp": "2024-01-01 12:00:00"
}
```

### أخطاء محتملة
- **401**: رمز المصادقة مطلوب
- **500**: خطأ في الخادم

