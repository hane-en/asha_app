<?php
/**
 * API endpoint لنسيان كلمة المرور
 * POST /api/auth/forgot_password.php
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
if (empty($input['email'])) {
    errorResponse('البريد الإلكتروني مطلوب');
}

// تنظيف البيانات
$email = sanitizeInput($input['email']);

try {
    $auth = new Auth();
    $result = $auth->forgotPassword($email);
    
    if ($result) {
        successResponse($result, 'تم إرسال كود إعادة تعيين كلمة المرور');
    } else {
        errorResponse('فشل في إرسال كود إعادة التعيين');
    }
} catch (Exception $e) {
    logError("Forgot password error: " . $e->getMessage());
    errorResponse('حدث خطأ أثناء إرسال كود إعادة التعيين', 500);
}

?>

