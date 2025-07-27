<?php
/**
 * API endpoint لإعادة تعيين كلمة المرور
 * POST /api/auth/reset_password.php
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
if (empty($input['email']) || empty($input['code']) || empty($input['new_password'])) {
    errorResponse('جميع الحقول مطلوبة');
}

// تنظيف البيانات
$email = sanitizeInput($input['email']);
$code = sanitizeInput($input['code']);
$newPassword = $input['new_password'];

// التحقق من قوة كلمة المرور
if (strlen($newPassword) < 6) {
    errorResponse('كلمة المرور يجب أن تكون 6 أحرف على الأقل');
}

try {
    $auth = new Auth();
    $result = $auth->resetPassword($email, $code, $newPassword);
    
    if ($result) {
        successResponse($result, 'تم تغيير كلمة المرور بنجاح');
    } else {
        errorResponse('فشل في تغيير كلمة المرور');
    }
} catch (Exception $e) {
    logError("Reset password error: " . $e->getMessage());
    errorResponse('حدث خطأ أثناء تغيير كلمة المرور', 500);
}

?>

