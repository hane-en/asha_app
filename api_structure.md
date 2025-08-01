# هيكل ملفات PHP المطلوبة
# Required PHP Files Structure

## 📁 هيكل المجلدات

```
asha_app_h/
├── config.php
├── database_schema.sql
├── test_database.php
├── api/
│   ├── auth/
│   │   ├── login.php
│   │   ├── register.php
│   │   ├── verify.php
│   │   ├── forgot_password.php
│   │   └── reset_password.php
│   ├── services/
│   │   ├── get_all.php
│   │   ├── get_by_id.php
│   │   ├── get_by_category.php
│   │   ├── search.php
│   │   ├── add_service.php
│   │   ├── update_service.php
│   │   └── delete_service.php
│   ├── admin/
│   │   ├── get_all_users.php
│   │   ├── manage_users.php
│   │   ├── get_provider_requests.php
│   │   ├── dashboard_stats.php
│   │   ├── manage_services.php
│   │   ├── manage_ads.php
│   │   └── manage_bookings.php
│   ├── provider/
│   │   ├── add_service.php
│   │   ├── get_my_services.php
│   │   ├── update_service.php
│   │   ├── get_my_ads.php
│   │   ├── add_ad.php
│   │   └── get_analytics.php
│   ├── user/
│   │   ├── get_profile.php
│   │   ├── update_profile.php
│   │   ├── get_favorites.php
│   │   └── toggle_favorite.php
│   ├── bookings/
│   │   ├── create.php
│   │   ├── get_user_bookings.php
│   │   ├── update_status.php
│   │   └── cancel.php
│   ├── reviews/
│   │   ├── add_review.php
│   │   ├── get_service_reviews.php
│   │   └── update_review.php
│   ├── ads/
│   │   ├── get_active_ads.php
│   │   ├── get_public_ads.php
│   │   └── add_ad.php
│   ├── categories/
│   │   ├── get_all.php
│   │   ├── get_services_by_category.php
│   │   └── add_category.php
│   ├── notifications/
│   │   ├── get_notifications.php
│   │   ├── mark_as_read.php
│   │   └── send_notification.php
│   ├── messages/
│   │   ├── send_message.php
│   │   ├── get_messages.php
│   │   └── mark_as_read.php
│   ├── payments/
│   │   ├── process_payment.php
│   │   ├── get_payment_status.php
│   │   └── refund.php
│   └── uploads/
│       ├── upload_image.php
│       ├── upload_file.php
│       └── delete_file.php
├── uploads/
│   ├── images/
│   ├── profiles/
│   ├── services/
│   └── ads/
├── logs/
│   ├── error_log.txt
│   └── access_log.txt
└── docs/
    ├── API_DOCUMENTATION.md
    └── SETUP_GUIDE.md
```

## 🔧 خطوات إنشاء ملفات PHP

### الخطوة 1: إنشاء المجلد الرئيسي
```bash
mkdir asha_app_h
cd asha_app_h
```

### الخطوة 2: إنشاء هيكل المجلدات
```bash
mkdir -p api/{auth,services,admin,provider,user,bookings,reviews,ads,categories,notifications,messages,payments,uploads}
mkdir -p uploads/{images,profiles,services,ads}
mkdir logs docs
```

### الخطوة 3: نسخ الملفات الموجودة
```bash
# نسخ ملفات قاعدة البيانات
cp database_schema.sql asha_app_h/
cp config.php asha_app_h/
cp test_database.php asha_app_h/
```

### الخطوة 4: إنشاء ملفات PHP الأساسية

#### مثال: `api/auth/login.php`
```php
<?php
require_once '../../config.php';

header('Content-Type: application/json; charset=utf-8');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit;
}

try {
    $input = json_decode(file_get_contents('php://input'), true);
    
    $identifier = $input['identifier'] ?? '';
    $password = $input['password'] ?? '';
    $userType = $input['user_type'] ?? 'user';
    
    if (empty($identifier) || empty($password)) {
        echo json_encode(['success' => false, 'message' => 'جميع الحقول مطلوبة']);
        exit;
    }
    
    $pdo = getDatabaseConnection();
    
    $stmt = $pdo->prepare("SELECT * FROM users WHERE (email = ? OR phone = ?) AND user_type = ? AND is_active = 1");
    $stmt->execute([$identifier, $identifier, $userType]);
    $user = $stmt->fetch();
    
    if ($user && password_verify($password, $user['password'])) {
        echo json_encode([
            'success' => true,
            'message' => 'تم تسجيل الدخول بنجاح',
            'data' => [
                'user' => [
                    'id' => $user['id'],
                    'name' => $user['name'],
                    'email' => $user['email'],
                    'phone' => $user['phone'],
                    'user_type' => $user['user_type'],
                    'is_verified' => $user['is_verified'],
                    'profile_image' => $user['profile_image']
                ]
            ]
        ]);
    } else {
        echo json_encode(['success' => false, 'message' => 'بيانات الدخول غير صحيحة']);
    }
    
} catch (Exception $e) {
    logError('Login error: ' . $e->getMessage());
    echo json_encode(['success' => false, 'message' => 'خطأ في الخادم']);
}
?>
```

## 📋 قائمة الملفات المطلوبة

### ملفات المصادقة:
- [ ] `api/auth/login.php`
- [ ] `api/auth/register.php`
- [ ] `api/auth/verify.php`
- [ ] `api/auth/forgot_password.php`
- [ ] `api/auth/reset_password.php`

### ملفات الخدمات:
- [ ] `api/services/get_all.php`
- [ ] `api/services/get_by_id.php`
- [ ] `api/services/get_by_category.php`
- [ ] `api/services/search.php`
- [ ] `api/services/add_service.php`
- [ ] `api/services/update_service.php`
- [ ] `api/services/delete_service.php`

### ملفات الإدارة:
- [ ] `api/admin/get_all_users.php`
- [ ] `api/admin/manage_users.php`
- [ ] `api/admin/get_provider_requests.php`
- [ ] `api/admin/dashboard_stats.php`

### ملفات مزود الخدمة:
- [ ] `api/provider/add_service.php`
- [ ] `api/provider/get_my_services.php`
- [ ] `api/provider/update_service.php`

## 🚀 كيفية التثبيت

### 1. في خادم XAMPP/WAMP:
```bash
# نسخ المشروع إلى htdocs
cp -r asha_app_h/ C:/xampp/htdocs/
```

### 2. في خادم Linux:
```bash
# نسخ المشروع إلى /var/www/html/
sudo cp -r asha_app_h/ /var/www/html/
```

### 3. الوصول للملفات:
```
http://localhost/asha_app_h/
http://localhost/asha_app_h/api/auth/login.php
```

## 🔍 اختبار الملفات

### اختبار الاتصال:
```bash
curl -X POST http://localhost/asha_app_h/api/auth/login.php \
  -H "Content-Type: application/json" \
  -d '{"identifier":"admin@asha-app.com","password":"password","user_type":"admin"}'
```

### اختبار قاعدة البيانات:
```
http://localhost/asha_app_h/test_database.php
```

## 📝 ملاحظات مهمة

1. **تأكد من تشغيل خادم Apache و MySQL**
2. **قم بتشغيل ملف قاعدة البيانات أولاً**
3. **تأكد من إعدادات CORS**
4. **اختبر جميع الملفات قبل استخدام التطبيق**

---

**ملاحظة:** ملفات PHP موجودة في خادم منفصل وليس في مشروع Flutter هذا. 