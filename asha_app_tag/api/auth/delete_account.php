<?php
/**
 * API endpoint لحذف حساب المستخدم
 * POST /api/auth/delete_account.php
 */

require_once '../../config.php';
require_once '../../database.php';

// التحقق من طريقة الطلب
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    errorResponse('طريقة الطلب غير مدعومة', 405);
}

// قراءة البيانات المرسلة
$input = json_decode(file_get_contents('php://input'), true);

if (!$input) {
    errorResponse('بيانات غير صحيحة', 400);
}

$userId = $input['user_id'] ?? null;
$password = $input['password'] ?? null;

// التحقق من البيانات المطلوبة
if (!$userId || !$password) {
    errorResponse('يرجى إدخال معرف المستخدم وكلمة المرور', 400);
}

try {
    $database = new Database();
    $database->connect();

    // التحقق من وجود المستخدم
    $user = $database->selectOne("SELECT * FROM users WHERE id = :id", ['id' => $userId]);
    
    if (!$user) {
        errorResponse('المستخدم غير موجود', 404);
    }

    // التحقق من كلمة المرور
    if (!password_verify($password, $user['password'])) {
        errorResponse('كلمة المرور غير صحيحة', 401);
    }

    // بدء المعاملة
    $database->beginTransaction();

    try {
        // حذف الإعلانات المرتبطة بالمستخدم (إذا كان مزود خدمة)
        $database->delete('ads', 'provider_id = :provider_id', ['provider_id' => $userId]);

        // حذف الخدمات المرتبطة بالمستخدم (إذا كان مزود خدمة)
        $database->delete('services', 'provider_id = :provider_id', ['provider_id' => $userId]);

        // حذف الحجوزات المرتبطة بالمستخدم
        $database->delete('bookings', 'user_id = :user_id', ['user_id' => $userId]);
        $database->delete('bookings', 'provider_id = :provider_id', ['provider_id' => $userId]);

        // حذف التقييمات المرتبطة بالمستخدم
        $database->delete('reviews', 'user_id = :user_id', ['user_id' => $userId]);

        // حذف المفضلة المرتبطة بالمستخدم
        $database->delete('favorites', 'user_id = :user_id', ['user_id' => $userId]);

        // حذف المستخدم نفسه
        $result = $database->delete('users', 'id = :id', ['id' => $userId]);

        if ($result) {
            // تأكيد المعاملة
            $database->commit();
            
            successResponse(null, 'تم حذف الحساب بنجاح');
        } else {
            // التراجع عن المعاملة
            $database->rollback();
            errorResponse('فشل في حذف الحساب', 500);
        }

    } catch (Exception $e) {
        // التراجع عن المعاملة في حالة حدوث خطأ
        $database->rollback();
        throw $e;
    }

} catch (Exception $e) {
    logError("Delete account error: " . $e->getMessage());
    errorResponse('حدث خطأ أثناء حذف الحساب', 500);
}
?> 