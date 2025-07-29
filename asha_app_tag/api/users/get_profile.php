<?php
/**
 * API endpoint لجلب ملف المستخدم الشخصي
 * GET /api/users/get_profile.php?user_id=1
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
$user_id = isset($_GET['user_id']) ? (int)$_GET['user_id'] : null;

if (!$user_id) {
    errorResponse('معرف المستخدم مطلوب');
}

try {
    $database = new Database();
    $database->connect();

    // جلب بيانات المستخدم
    $query = "
        SELECT 
            u.*,
            COUNT(DISTINCT s.id) as services_count,
            COUNT(DISTINCT b.id) as bookings_count,
            COUNT(DISTINCT r.id) as reviews_count,
            COUNT(DISTINCT f.id) as favorites_count,
            AVG(r.rating) as avg_rating
        FROM users u
        LEFT JOIN services s ON u.id = s.provider_id AND s.is_active = 1
        LEFT JOIN bookings b ON u.id = b.user_id
        LEFT JOIN reviews r ON u.id = r.user_id
        LEFT JOIN favorites f ON u.id = f.user_id
        WHERE u.id = ? AND u.is_active = 1
        GROUP BY u.id
    ";

    $user = $database->selectOne($query, [$user_id]);

    if (!$user) {
        errorResponse('المستخدم غير موجود', 404);
    }

    // جلب الخدمات إذا كان مزود خدمة
    $services = [];
    if ($user['user_type'] === 'provider') {
        $services_query = "
            SELECT 
                s.*,
                c.name as category_name,
                COUNT(r.id) as reviews_count,
                AVG(r.rating) as avg_rating
            FROM services s
            LEFT JOIN categories c ON s.category_id = c.id
            LEFT JOIN reviews r ON s.id = r.service_id
            WHERE s.provider_id = ? AND s.is_active = 1
            GROUP BY s.id
            ORDER BY s.created_at DESC
        ";
        $services = $database->select($services_query, [$user_id]);
    }

    // جلب الحجوزات الأخيرة
    $recent_bookings_query = "
        SELECT 
            b.*,
            s.title as service_title,
            s.price as service_price,
            u.name as provider_name
        FROM bookings b
        LEFT JOIN services s ON b.service_id = s.id
        LEFT JOIN users u ON s.provider_id = u.id
        WHERE b.user_id = ?
        ORDER BY b.created_at DESC
        LIMIT 5
    ";
    $recent_bookings = $database->select($recent_bookings_query, [$user_id]);

    // جلب التقييمات الأخيرة
    $recent_reviews_query = "
        SELECT 
            r.*,
            s.title as service_title
        FROM reviews r
        LEFT JOIN services s ON r.service_id = s.id
        WHERE r.user_id = ?
        ORDER BY r.created_at DESC
        LIMIT 5
    ";
    $recent_reviews = $database->select($recent_reviews_query, [$user_id]);

    // معالجة البيانات
    $user['services_count'] = (int)$user['services_count'];
    $user['bookings_count'] = (int)$user['bookings_count'];
    $user['reviews_count'] = (int)$user['reviews_count'];
    $user['favorites_count'] = (int)$user['favorites_count'];
    $user['avg_rating'] = round($user['avg_rating'], 1);
    $user['profile_image'] = $user['profile_image'] ?: 'default_avatar.jpg';

    foreach ($services as &$service) {
        $service['reviews_count'] = (int)$service['reviews_count'];
        $service['avg_rating'] = round($service['avg_rating'], 1);
        $service['price'] = (float)$service['price'];
    }

    foreach ($recent_bookings as &$booking) {
        $booking['price'] = (float)$booking['price'];
        $booking['total_amount'] = (float)$booking['total_amount'];
    }

    foreach ($recent_reviews as &$review) {
        $review['rating'] = (int)$review['rating'];
    }

    $response_data = [
        'user' => $user,
        'services' => $services,
        'recent_bookings' => $recent_bookings,
        'recent_reviews' => $recent_reviews
    ];

    successResponse($response_data, 'تم جلب الملف الشخصي بنجاح');

} catch (Exception $e) {
    errorResponse('خطأ في جلب الملف الشخصي: ' . $e->getMessage());
}
?> 