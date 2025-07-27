# توثيق API - خدمات المناسبات

## نظرة عامة

هذا التوثيق يغطي جميع نقاط النهاية (Endpoints) المستخدمة في تطبيق خدمات المناسبات.

## معلومات أساسية

- **Base URL**: `http://localhost/backend_php/api`
- **Content-Type**: `application/json`
- **Encoding**: UTF-8

## المصادقة

### تسجيل الدخول
```
POST /login.php
```

**المعاملات:**
- `phone` (string): رقم الهاتف
- `password` (string): كلمة المرور

**الاستجابة:**
```json
{
  "success": true,
  "message": "تم تسجيل الدخول بنجاح",
  "data": {
    "user_id": 1,
    "name": "أحمد محمد",
    "phone": "0501234567",
    "email": "ahmed@example.com",
    "role": "user",
    "token": "jwt_token_here"
  }
}
```

### التسجيل
```
POST /register.php
```

**المعاملات:**
- `name` (string): الاسم الكامل
- `phone` (string): رقم الهاتف
- `email` (string): البريد الإلكتروني
- `password` (string): كلمة المرور
- `role` (string): نوع المستخدم (user/provider)
- `address` (string, optional): العنوان

**الاستجابة:**
```json
{
  "success": true,
  "message": "تم التسجيل بنجاح"
}
```

### تسجيل الخروج
```
POST /logout.php
```

**المعاملات:**
- `user_id` (int): معرف المستخدم

**الاستجابة:**
```json
{
  "success": true,
  "message": "تم تسجيل الخروج بنجاح"
}
```

## الخدمات

### الحصول على الخدمات حسب الفئة
```
GET /services_by_category.php?category={category}
```

**المعاملات:**
- `category` (string): فئة الخدمة

**الاستجابة:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "خدمة التصوير",
      "description": "خدمة تصوير احترافية",
      "category": "تصوير",
      "image": "image.jpg",
      "price": 500.0,
      "provider_id": 1,
      "provider_name": "أحمد المصور",
      "provider_phone": "0501234567",
      "is_available": true,
      "rating": 4.5,
      "review_count": 10,
      "created_at": "2024-01-15T10:00:00Z",
      "updated_at": "2024-01-15T10:00:00Z"
    }
  ]
}
```

### إضافة خدمة جديدة
```
POST /add_service.php
```

**المعاملات:**
- `name` (string): اسم الخدمة
- `description` (string): وصف الخدمة
- `category` (string): فئة الخدمة
- `price` (float): السعر
- `provider_id` (int): معرف مزود الخدمة
- `image` (string): رابط الصورة

**الاستجابة:**
```json
{
  "success": true,
  "message": "تم إضافة الخدمة بنجاح"
}
```

### تحديث خدمة
```
POST /update_service.php
```

**المعاملات:**
- `service_id` (int): معرف الخدمة
- `name` (string): اسم الخدمة
- `description` (string): وصف الخدمة
- `category` (string): فئة الخدمة
- `price` (float): السعر
- `image` (string): رابط الصورة

**الاستجابة:**
```json
{
  "success": true,
  "message": "تم تحديث الخدمة بنجاح"
}
```

### حذف خدمة
```
POST /delete_service.php
```

**المعاملات:**
- `service_id` (int): معرف الخدمة

**الاستجابة:**
```json
{
  "success": true,
  "message": "تم حذف الخدمة بنجاح"
}
```

## الحجوزات

### الحصول على حجوزات المستخدم
```
GET /get_bookings.php?user_id={user_id}
```

**المعاملات:**
- `user_id` (int): معرف المستخدم

**الاستجابة:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "user_id": 1,
      "service_id": 1,
      "user_name": "أحمد محمد",
      "service_name": "خدمة التصوير",
      "provider_name": "أحمد المصور",
      "date": "2024-01-15",
      "time": "14:00",
      "note": "ملاحظة",
      "status": "pending",
      "total_price": 500.0,
      "created_at": "2024-01-15T10:00:00Z",
      "updated_at": "2024-01-15T10:00:00Z"
    }
  ]
}
```

### إضافة حجز جديد
```
POST /add_booking.php
```

**المعاملات:**
- `user_id` (int): معرف المستخدم
- `service_id` (int): معرف الخدمة
- `date` (string): التاريخ (YYYY-MM-DD)
- `time` (string): الوقت (HH:MM)
- `note` (string, optional): ملاحظة

**الاستجابة:**
```json
{
  "success": true,
  "message": "تم الحجز بنجاح"
}
```

### تحديث حالة الحجز
```
POST /update_booking_status.php
```

**المعاملات:**
- `booking_id` (int): معرف الحجز
- `status` (string): الحالة الجديدة (pending/confirmed/completed/cancelled)

**الاستجابة:**
```json
{
  "success": true,
  "message": "تم تحديث حالة الحجز بنجاح"
}
```

### حذف حجز
```
POST /delete_booking.php
```

**المعاملات:**
- `booking_id` (int): معرف الحجز

**الاستجابة:**
```json
{
  "success": true,
  "message": "تم حذف الحجز بنجاح"
}
```

## المفضلة

### إضافة خدمة للمفضلة
```
POST /add_to_favorites.php
```

**المعاملات:**
- `user_id` (int): معرف المستخدم
- `service_id` (int): معرف الخدمة

**الاستجابة:**
```json
{
  "success": true,
  "message": "تم الإضافة للمفضلة بنجاح"
}
```

### إزالة خدمة من المفضلة
```
POST /remove_favorite.php
```

**المعاملات:**
- `user_id` (int): معرف المستخدم
- `service_id` (int): معرف الخدمة

**الاستجابة:**
```json
{
  "success": true,
  "message": "تم الإزالة من المفضلة بنجاح"
}
```

### الحصول على المفضلة
```
GET /get_favorites.php?user_id={user_id}
```

**المعاملات:**
- `user_id` (int): معرف المستخدم

**الاستجابة:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "user_id": 1,
      "service_id": 1,
      "service_name": "خدمة التصوير",
      "service_image": "image.jpg",
      "service_price": 500.0,
      "added_at": "2024-01-15T10:00:00Z"
    }
  ]
}
```

## الإعلانات

### الحصول على الإعلانات
```
GET /get_ads.php
```

**الاستجابة:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "title": "إعلان تجريبي",
      "description": "وصف الإعلان",
      "image": "ad.jpg",
      "link": "https://example.com",
      "is_active": true,
      "priority": 1,
      "start_date": "2024-01-01",
      "end_date": "2024-12-31",
      "created_at": "2024-01-15T10:00:00Z",
      "updated_at": "2024-01-15T10:00:00Z"
    }
  ]
}
```

### إضافة إعلان جديد
```
POST /add_ad.php
```

**المعاملات:**
- `title` (string): عنوان الإعلان
- `description` (string): وصف الإعلان
- `image` (string): رابط الصورة
- `link` (string, optional): رابط الإعلان
- `is_active` (boolean): حالة الإعلان
- `priority` (int): أولوية الإعلان
- `start_date` (string, optional): تاريخ البداية
- `end_date` (string, optional): تاريخ النهاية

**الاستجابة:**
```json
{
  "success": true,
  "message": "تم إضافة الإعلان بنجاح"
}
```

## إدارة المستخدمين (للمدراء)

### الحصول على جميع المستخدمين
```
GET /get_all_users.php
```

**الاستجابة:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "أحمد محمد",
      "phone": "0501234567",
      "email": "ahmed@example.com",
      "role": "user",
      "is_active": true,
      "created_at": "2024-01-15T10:00:00Z"
    }
  ]
}
```

### حظر مستخدم
```
POST /block_user.php
```

**المعاملات:**
- `user_id` (int): معرف المستخدم
- `reason` (string): سبب الحظر

**الاستجابة:**
```json
{
  "success": true,
  "message": "تم حظر المستخدم بنجاح"
}
```

### إلغاء حظر مستخدم
```
POST /unblock_user.php
```

**المعاملات:**
- `user_id` (int): معرف المستخدم

**الاستجابة:**
```json
{
  "success": true,
  "message": "تم إلغاء حظر المستخدم بنجاح"
}
```

## طلبات الانضمام (للمدراء)

### الحصول على طلبات الانضمام
```
GET /get_join_requests.php
```

**الاستجابة:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "أحمد المصور",
      "phone": "0501234567",
      "email": "ahmed@example.com",
      "role": "provider",
      "request_date": "2024-01-15T10:00:00Z",
      "status": "pending"
    }
  ]
}
```

### الموافقة على مزود خدمة
```
POST /approve_provider.php
```

**المعاملات:**
- `id` (int): معرف الطلب

**الاستجابة:**
```json
{
  "success": true,
  "message": "تم الموافقة على مزود الخدمة بنجاح"
}
```

### رفض مزود خدمة
```
POST /reject_provider.php
```

**المعاملات:**
- `id` (int): معرف الطلب
- `reason` (string): سبب الرفض

**الاستجابة:**
```json
{
  "success": true,
  "message": "تم رفض مزود الخدمة بنجاح"
}
```

## رموز الحالة HTTP

- `200`: نجح الطلب
- `400`: خطأ في الطلب
- `401`: غير مصرح
- `403`: محظور
- `404`: غير موجود
- `500`: خطأ في الخادم

## رسائل الخطأ

جميع الاستجابات تحتوي على حقل `message` يوضح سبب الخطأ:

```json
{
  "success": false,
  "message": "رسالة الخطأ هنا"
}
```

## أمثلة على الاستخدام

### مثال على تسجيل الدخول
```bash
curl -X POST http://localhost/backend_php/api/login.php \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "0501234567",
    "password": "password123"
  }'
```

### مثال على إضافة خدمة
```bash
curl -X POST http://localhost/backend_php/api/add_service.php \
  -H "Content-Type: application/json" \
  -d '{
    "name": "خدمة التصوير",
    "description": "خدمة تصوير احترافية",
    "category": "تصوير",
    "price": 500.0,
    "provider_id": 1,
    "image": "image.jpg"
  }'
```

## ملاحظات مهمة

1. جميع التواريخ يجب أن تكون بصيغة ISO 8601
2. جميع الأرقام العشرية يجب أن تكون بصيغة float
3. جميع المعرفات يجب أن تكون أرقام صحيحة
4. يجب إرسال جميع الطلبات بصيغة JSON
5. يجب تضمين معرف المستخدم في جميع الطلبات المطلوبة 