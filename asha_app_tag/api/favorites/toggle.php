<?php
/**
 * API endpoint لإضافة/إزالة المفضلة
 * POST /api/favorites/toggle.php
 */

require_once '../../config.php';
require_once '../../database.php';
require_once '../../middleware.php';

// التحقق من طريقة الطلب
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    errorResponse('طريقة الطلب غير مدعومة', 405);
}

// التحقق من المصادقة
$user = $middleware->requireAuth();

// الحصول على البيانات
$input = json_decode(file_get_contents('php://input'), true);

if (!$input) {
    errorResponse('بيانات غير صحيحة');
}

// التحقق من وجود البيانات المطلوبة
if (!isset($input['service_id']) || empty($input['service_id'])) {
    errorResponse('معرف الخدمة مطلوب');
}

$serviceId = (int)$input['service_id'];

try {
    $database = new Database();
    $database->connect();

    // التحقق من وجود الخدمة
    $service = $database->selectOne(
        "SELECT id, title FROM services WHERE id = :id AND is_active = 1",
        ['id' => $serviceId]
    );

    if (!$service) {
        errorResponse('الخدمة غير موجودة', 404);
    }

    // التحقق من وجود المفضلة
    $existingFavorite = $database->selectOne(
        "SELECT id FROM favorites WHERE user_id = :user_id AND service_id = :service_id",
        ['user_id' => $user['id'], 'service_id' => $serviceId]
    );

    $isAdded = false;
    $message = '';

    if ($existingFavorite) {
        // إزالة من المفضلة
        $deleted = $database->delete(
            'favorites',
            'user_id = :user_id AND service_id = :service_id',
            ['user_id' => $user['id'], 'service_id' => $serviceId]
        );

        if ($deleted) {
            // تحديث عداد المفضلة للخدمة
            $database->query(
                "UPDATE services SET favorite_count = favorite_count - 1 WHERE id = :id",
                ['id' => $serviceId]
            );
            
            $isAdded = false;
            $message = 'تم إزالة الخدمة من المفضلة';
        } else {
            errorResponse('فشل في إزالة الخدمة من المفضلة');
        }
    } else {
        // إضافة إلى المفضلة
        $favoriteData = [
            'user_id' => $user['id'],
            'service_id' => $serviceId
        ];

        $favoriteId = $database->insert('favorites', $favoriteData);

        if ($favoriteId) {
            // تحديث عداد المفضلة للخدمة
            $database->query(
                "UPDATE services SET favorite_count = favorite_count + 1 WHERE id = :id",
                ['id' => $serviceId]
            );
            
            $isAdded = true;
            $message = 'تم إضافة الخدمة إلى المفضلة';
        } else {
            errorResponse('فشل في إضافة الخدمة إلى المفضلة');
        }
    }

    // تسجيل النشاط
    $action = $isAdded ? 'add_favorite' : 'remove_favorite';
    $middleware->logActivity($user['id'], $action, "Service ID: {$serviceId}");

    $response = [
        'is_favorite' => $isAdded,
        'service_id' => $serviceId,
        'service_title' => $service['title']
    ];

    successResponse($response, $message);

} catch (Exception $e) {
    logError("Toggle favorite error: " . $e->getMessage());
    errorResponse('حدث خطأ أثناء تحديث المفضلة', 500);
}

?>

