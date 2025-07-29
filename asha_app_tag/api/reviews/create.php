<?php
/**
 * API endpoint لإضافة تقييم جديد
 * POST /api/reviews/create.php
 */

require_once '../../config.php';
require_once '../../database.php';

// إعداد CORS
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
header('Content-Type: application/json; charset=utf-8');

// معالجة preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// التحقق من طريقة الطلب
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    errorResponse('طريقة الطلب غير مدعومة', 405);
}

// قراءة البيانات المرسلة
$input = json_decode(file_get_contents('php://input'), true);

// التحقق من البيانات المطلوبة
if (!isset($input['service_id']) || !isset($input['user_id']) || !isset($input['rating'])) {
    errorResponse('البيانات المطلوبة غير مكتملة');
}

$service_id = (int)$input['service_id'];
$user_id = (int)$input['user_id'];
$rating = (int)$input['rating'];
$comment = isset($input['comment']) ? sanitizeInput($input['comment']) : '';

// التحقق من صحة التقييم
if ($rating < 1 || $rating > 5) {
    errorResponse('التقييم يجب أن يكون بين 1 و 5');
}

try {
    $database = new Database();
    $database->connect();

    // التحقق من وجود الخدمة
    $service = $database->selectOne("SELECT id FROM services WHERE id = ? AND is_active = 1", [$service_id]);
    if (!$service) {
        errorResponse('الخدمة غير موجودة');
    }

    // التحقق من وجود المستخدم
    $user = $database->selectOne("SELECT id FROM users WHERE id = ? AND is_active = 1", [$user_id]);
    if (!$user) {
        errorResponse('المستخدم غير موجود');
    }

    // التحقق من عدم وجود تقييم سابق من نفس المستخدم
    $existing_review = $database->selectOne(
        "SELECT id FROM reviews WHERE service_id = ? AND user_id = ?",
        [$service_id, $user_id]
    );

    if ($existing_review) {
        errorResponse('لقد قمت بتقييم هذه الخدمة مسبقاً');
    }

    // إضافة التقييم
    $review_data = [
        'service_id' => $service_id,
        'user_id' => $user_id,
        'rating' => $rating,
        'comment' => $comment,
        'created_at' => date('Y-m-d H:i:s')
    ];

    $review_id = $database->insert('reviews', $review_data);

    if ($review_id) {
        // تحديث متوسط التقييم للخدمة
        $avg_rating = $database->selectOne(
            "SELECT AVG(rating) as avg_rating FROM reviews WHERE service_id = ?",
            [$service_id]
        );

        if ($avg_rating) {
            $database->update('services', 
                ['avg_rating' => round($avg_rating['avg_rating'], 2)], 
                'id = ?', 
                [$service_id]
            );
        }

        successResponse(['review_id' => $review_id], 'تم إضافة التقييم بنجاح');
    } else {
        errorResponse('فشل في إضافة التقييم');
    }

} catch (Exception $e) {
    errorResponse('خطأ في إضافة التقييم: ' . $e->getMessage());
}
?> 