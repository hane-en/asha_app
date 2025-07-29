<?php
/**
 * API endpoint مبسط لإضافة/إزالة المفضلة (بدون مصادقة)
 * POST /api/favorites/toggle_simple.php
 */

require_once '../../config.php';
require_once '../../database.php';

// إيقاف عرض الأخطاء
error_reporting(0);
ini_set('display_errors', 0);

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
if (!isset($input['service_id']) || empty($input['service_id'])) {
    errorResponse('معرف الخدمة مطلوب');
}

if (!isset($input['user_id']) || empty($input['user_id'])) {
    errorResponse('معرف المستخدم مطلوب');
}

$serviceId = (int)$input['service_id'];
$userId = (int)$input['user_id'];

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

    // التحقق من وجود المستخدم
    $user = $database->selectOne(
        "SELECT id, name FROM users WHERE id = :id",
        ['id' => $userId]
    );

    if (!$user) {
        errorResponse('المستخدم غير موجود', 404);
    }

    // التحقق من وجود المفضلة
    $existingFavorite = $database->selectOne(
        "SELECT id FROM favorites WHERE user_id = :user_id AND service_id = :service_id",
        ['user_id' => $userId, 'service_id' => $serviceId]
    );

    $isAdded = false;
    $message = '';

    if ($existingFavorite) {
        // إزالة من المفضلة
        $deleted = $database->delete(
            'favorites',
            'user_id = :user_id AND service_id = :service_id',
            ['user_id' => $userId, 'service_id' => $serviceId]
        );

        if ($deleted) {
            $isAdded = false;
            $message = 'تم إزالة الخدمة من المفضلة';
        } else {
            errorResponse('فشل في إزالة الخدمة من المفضلة');
        }
    } else {
        // إضافة إلى المفضلة
        $favoriteData = [
            'user_id' => $userId,
            'service_id' => $serviceId
        ];

        $favoriteId = $database->insert('favorites', $favoriteData);

        if ($favoriteId) {
            $isAdded = true;
            $message = 'تم إضافة الخدمة إلى المفضلة';
        } else {
            errorResponse('فشل في إضافة الخدمة إلى المفضلة');
        }
    }

    $response = [
        'success' => true,
        'is_favorite' => $isAdded,
        'service_id' => $serviceId,
        'service_title' => $service['title'],
        'user_id' => $userId,
        'user_name' => $user['name'],
        'message' => $message
    ];

    // إرسال الاستجابة
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($response, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    exit;

} catch (Exception $e) {
    logError("Toggle favorite error: " . $e->getMessage());
    errorResponse('حدث خطأ أثناء تحديث المفضلة', 500);
}

?> 