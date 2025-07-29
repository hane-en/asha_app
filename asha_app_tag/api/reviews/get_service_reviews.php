<?php
/**
 * API endpoint لجلب تقييمات خدمة معينة
 * GET /api/reviews/get_service_reviews.php?service_id=1
 */

require_once '../../config.php';
require_once '../../database.php';

// إعداد CORS
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
header('Content-Type: application/json; charset=utf-8');

// معالجة preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// التحقق من طريقة الطلب
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    errorResponse('طريقة الطلب غير مدعومة', 405);
}

// الحصول على المعاملات
$service_id = isset($_GET['service_id']) ? (int)$_GET['service_id'] : null;
$page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
$limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 10;

if (!$service_id) {
    errorResponse('معرف الخدمة مطلوب');
}

try {
    $database = new Database();
    $database->connect();

    // التحقق من وجود الخدمة
    $service = $database->selectOne("SELECT id, title FROM services WHERE id = ? AND is_active = 1", [$service_id]);
    if (!$service) {
        errorResponse('الخدمة غير موجودة', 404);
    }

    // حساب الإزاحة
    $offset = ($page - 1) * $limit;

    // جلب التقييمات
    $query = "
        SELECT 
            r.*,
            u.name as user_name,
            u.profile_image as user_image
        FROM reviews r
        LEFT JOIN users u ON r.user_id = u.id
        WHERE r.service_id = ?
        ORDER BY r.created_at DESC
        LIMIT ? OFFSET ?
    ";

    $reviews = $database->select($query, [$service_id, $limit, $offset]) ?: [];

    // جلب إحصائيات التقييم
    $stats_query = "
        SELECT 
            COUNT(*) as total_reviews,
            AVG(rating) as avg_rating,
            COUNT(CASE WHEN rating = 5 THEN 1 END) as five_star,
            COUNT(CASE WHEN rating = 4 THEN 1 END) as four_star,
            COUNT(CASE WHEN rating = 3 THEN 1 END) as three_star,
            COUNT(CASE WHEN rating = 2 THEN 1 END) as two_star,
            COUNT(CASE WHEN rating = 1 THEN 1 END) as one_star
        FROM reviews 
        WHERE service_id = ?
    ";

    $stats = $database->selectOne($stats_query, [$service_id]) ?: [
        'total_reviews' => 0,
        'avg_rating' => 0,
        'five_star' => 0,
        'four_star' => 0,
        'three_star' => 0,
        'two_star' => 0,
        'one_star' => 0
    ];

    // معالجة البيانات
    foreach ($reviews as &$review) {
        $review['rating'] = (int)$review['rating'];
        $review['user_image'] = $review['user_image'] ?: 'default_avatar.jpg';
        $review['created_at'] = date('Y-m-d H:i:s', strtotime($review['created_at']));
    }

    // حساب النسب المئوية
    if ($stats['total_reviews'] > 0) {
        $stats['five_star_percent'] = round(($stats['five_star'] / $stats['total_reviews']) * 100, 1);
        $stats['four_star_percent'] = round(($stats['four_star'] / $stats['total_reviews']) * 100, 1);
        $stats['three_star_percent'] = round(($stats['three_star'] / $stats['total_reviews']) * 100, 1);
        $stats['two_star_percent'] = round(($stats['two_star'] / $stats['total_reviews']) * 100, 1);
        $stats['one_star_percent'] = round(($stats['one_star'] / $stats['total_reviews']) * 100, 1);
    } else {
        $stats['five_star_percent'] = $stats['four_star_percent'] = $stats['three_star_percent'] = 
        $stats['two_star_percent'] = $stats['one_star_percent'] = 0;
    }

    $stats['avg_rating'] = round($stats['avg_rating'], 1);

    $response_data = [
        'service' => [
            'id' => $service['id'],
            'title' => $service['title']
        ],
        'reviews' => $reviews,
        'stats' => $stats,
        'pagination' => [
            'page' => $page,
            'limit' => $limit,
            'total_reviews' => $stats['total_reviews']
        ]
    ];

    successResponse($response_data, 'تم جلب التقييمات بنجاح');

} catch (Exception $e) {
    errorResponse('خطأ في جلب التقييمات: ' . $e->getMessage());
}
?> 