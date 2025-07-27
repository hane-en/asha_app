<?php
/**
 * API endpoint لتسجيل الدخول
 * POST /api/auth/login.php
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
if (empty($input['email']) || empty($input['password'])) {
    errorResponse('البريد الإلكتروني وكلمة المرور مطلوبان');
}

// تنظيف البيانات
$email = sanitizeInput($input['email']);
$password = $input['password']; // لا نقوم بتنظيف كلمة المرور
$userType = isset($input['user_type']) ? sanitizeInput($input['user_type']) : null;

try {
    $auth = new Auth();
    $result = $auth->login($email, $password, $userType);
    
    if ($result) {
        successResponse($result, 'تم تسجيل الدخول بنجاح');
    } else {
        errorResponse('فشل في تسجيل الدخول');
    }
} catch (Exception $e) {
    logError("Login error: " . $e->getMessage());
    errorResponse('حدث خطأ أثناء تسجيل الدخول', 500);
}

?>

