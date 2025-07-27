<?php
/**
 * API endpoint للتسجيل
 * POST /api/auth/register.php
 */

require_once '../../config.php';
require_once '../../auth.php';

// التحقق من طريقة الطلب
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    errorResponse('طريقة الطلب غير مدعومة', 405);
}

// الحصول على البيانات
$input = json_decode(file_get_contents('php://input'), true);

if (!$input) {
    errorResponse('بيانات غير صحيحة');
}

// التحقق من وجود البيانات المطلوبة
$requiredFields = ['name', 'email', 'phone', 'password'];
foreach ($requiredFields as $field) {
    if (empty($input[$field])) {
        errorResponse("الحقل {$field} مطلوب");
    }
}

// تنظيف البيانات
$data = [
    'name' => sanitizeInput($input['name']),
    'email' => sanitizeInput($input['email']),
    'phone' => sanitizeInput($input['phone']),
    'password' => $input['password'], // سيتم تشفيرها في Auth class
    'user_type' => isset($input['user_type']) ? sanitizeInput($input['user_type']) : 'user',
    'bio' => isset($input['bio']) ? sanitizeInput($input['bio']) : null,
    'website' => isset($input['website']) ? sanitizeInput($input['website']) : null,
    'address' => isset($input['address']) ? sanitizeInput($input['address']) : null,
    'city' => isset($input['city']) ? sanitizeInput($input['city']) : null,
    'latitude' => isset($input['latitude']) ? floatval($input['latitude']) : null,
    'longitude' => isset($input['longitude']) ? floatval($input['longitude']) : null,
    'user_category' => isset($input['user_category']) ? sanitizeInput($input['user_category']) : null,
    'is_yemeni_account' => isset($input['is_yemeni_account']) ? (bool)$input['is_yemeni_account'] : false
];

try {
    $auth = new Auth();
    $result = $auth->register($data);
    
    if ($result) {
        successResponse($result, 'تم إنشاء الحساب بنجاح');
    } else {
        errorResponse('فشل في إنشاء الحساب');
    }
} catch (Exception $e) {
    logError("Registration error: " . $e->getMessage());
    errorResponse('حدث خطأ أثناء إنشاء الحساب', 500);
}

?>

