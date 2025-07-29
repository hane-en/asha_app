<?php
/**
 * API endpoint لتحديث ملف المستخدم الشخصي
 * PUT /api/users/update_profile.php
 */

require_once '../../config.php';
require_once '../../database.php';

// إعداد CORS
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: PUT, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
header('Content-Type: application/json; charset=utf-8');

// معالجة preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// التحقق من طريقة الطلب
if ($_SERVER['REQUEST_METHOD'] !== 'PUT') {
    errorResponse('طريقة الطلب غير مدعومة', 405);
}

// قراءة البيانات المرسلة
$input = json_decode(file_get_contents('php://input'), true);

// التحقق من البيانات المطلوبة
if (!isset($input['user_id'])) {
    errorResponse('معرف المستخدم مطلوب');
}

$user_id = (int)$input['user_id'];

// البيانات المسموح بتحديثها
$allowed_fields = [
    'name', 'email', 'phone', 'bio', 'address', 'city', 
    'website', 'profile_image', 'cover_image'
];

$update_data = [];

foreach ($allowed_fields as $field) {
    if (isset($input[$field])) {
        $update_data[$field] = sanitizeInput($input[$field]);
    }
}

// التحقق من صحة البريد الإلكتروني إذا تم تحديثه
if (isset($update_data['email'])) {
    if (!validateEmail($update_data['email'])) {
        errorResponse('البريد الإلكتروني غير صحيح');
    }
}

// التحقق من صحة رقم الهاتف إذا تم تحديثه
if (isset($update_data['phone'])) {
    if (!validatePhone($update_data['phone'])) {
        errorResponse('رقم الهاتف غير صحيح');
    }
}

try {
    $database = new Database();
    $database->connect();

    // التحقق من وجود المستخدم
    $user = $database->selectOne("SELECT id, email FROM users WHERE id = ? AND is_active = 1", [$user_id]);
    if (!$user) {
        errorResponse('المستخدم غير موجود', 404);
    }

    // التحقق من عدم تكرار البريد الإلكتروني إذا تم تحديثه
    if (isset($update_data['email']) && $update_data['email'] !== $user['email']) {
        $existing_user = $database->selectOne(
            "SELECT id FROM users WHERE email = ? AND id != ?",
            [$update_data['email'], $user_id]
        );
        if ($existing_user) {
            errorResponse('البريد الإلكتروني مستخدم من قبل');
        }
    }

    // التحقق من عدم تكرار رقم الهاتف إذا تم تحديثه
    if (isset($update_data['phone'])) {
        $existing_user = $database->selectOne(
            "SELECT id FROM users WHERE phone = ? AND id != ?",
            [$update_data['phone'], $user_id]
        );
        if ($existing_user) {
            errorResponse('رقم الهاتف مستخدم من قبل');
        }
    }

    // إضافة وقت التحديث
    $update_data['updated_at'] = date('Y-m-d H:i:s');

    // تحديث البيانات
    $success = $database->update('users', $update_data, 'id = ?', [$user_id]);

    if ($success) {
        // جلب البيانات المحدثة
        $updated_user = $database->selectOne(
            "SELECT id, name, email, phone, bio, address, city, website, profile_image, cover_image, user_type, created_at, updated_at FROM users WHERE id = ?",
            [$user_id]
        );

        successResponse($updated_user, 'تم تحديث الملف الشخصي بنجاح');
    } else {
        errorResponse('فشل في تحديث الملف الشخصي');
    }

} catch (Exception $e) {
    errorResponse('خطأ في تحديث الملف الشخصي: ' . $e->getMessage());
}
?> 