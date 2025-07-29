<?php
/**
 * API endpoint للتحقق من الحساب
 * POST /api/auth/verify.php
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
if (empty($input['email']) || empty($input['code'])) {
    errorResponse('البريد الإلكتروني وكود التحقق مطلوبان');
}

// تنظيف البيانات
$email = sanitizeInput($input['email']);
$code = sanitizeInput($input['code']);

try {
    $auth = new Auth();
    $result = $auth->verifyAccount($email, $code);
    
    if ($result) {
        successResponse($result, 'تم تفعيل الحساب بنجاح');
    } else {
        errorResponse('فشل في تفعيل الحساب');
    }
} catch (Exception $e) {
    logError("Verification error: " . $e->getMessage());
    errorResponse('حدث خطأ أثناء تفعيل الحساب', 500);
}

?>

