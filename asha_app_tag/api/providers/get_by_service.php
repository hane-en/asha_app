<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// التعامل مع طلبات OPTIONS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once '../../config/database.php';
require_once '../../config/cors.php';

try {
    // التحقق من وجود service_id
    if (!isset($_GET['service_id'])) {
        throw new Exception('معرف الخدمة مطلوب');
    }

    $serviceId = intval($_GET['service_id']);

    if ($serviceId <= 0) {
        throw new Exception('معرف الخدمة غير صحيح');
    }

    // التحقق من وجود الخدمة
    $checkServiceSql = "SELECT id, name FROM services WHERE id = ? AND is_active = 1";
    $checkServiceStmt = $pdo->prepare($checkServiceSql);
    $checkServiceStmt->execute([$serviceId]);
    $service = $checkServiceStmt->fetch(PDO::FETCH_ASSOC);

    if (!$service) {
        throw new Exception('الخدمة غير موجودة أو غير متاحة');
    }

    // استعلام لجلب المزودين حسب الخدمة
    $sql = "SELECT DISTINCT
                u.id,
                u.name,
                u.email,
                u.phone,
                u.address,
                COALESCE(u.profile_image, 'default_avatar.jpg') as profile_image,
                COALESCE(u.rating, 0) as rating,
                COALESCE(u.total_reviews, 0) as total_reviews,
                u.is_verified,
                u.created_at,
                u.user_type,
                c.id as category_id,
                c.name as category_name,
                c.description as category_description,
                COUNT(s.id) as services_count,
                COALESCE(AVG(r.rating), 0) as avg_service_rating,
                COALESCE(AVG(s.price), 0) as avg_price,
                COUNT(DISTINCT b.id) as total_bookings,
                COALESCE(MIN(s.price), 0) as min_price,
                COALESCE(MAX(s.price), 0) as max_price,
                COUNT(DISTINCT r.id) as total_reviews_count,
                COALESCE(AVG(r.rating), 0) as avg_review_rating
            FROM users u
            INNER JOIN services s ON u.id = s.provider_id
            INNER JOIN categories c ON s.category_id = c.id
            LEFT JOIN bookings b ON s.id = b.service_id AND b.status != 'cancelled'
            LEFT JOIN reviews r ON s.id = r.service_id
            WHERE u.user_type = 'provider'
            AND s.category_id = (SELECT category_id FROM services WHERE id = ?)
            AND u.is_active = 1
            AND s.is_active = 1
            GROUP BY u.id, u.name, u.email, u.phone, u.address, 
                     u.profile_image, u.rating, u.total_reviews, u.is_verified, 
                     u.created_at, u.user_type, c.id, c.name, c.description
            ORDER BY u.rating DESC, services_count DESC, avg_service_rating DESC, total_bookings DESC";

    $stmt = $pdo->prepare($sql);
    $stmt->execute([$serviceId]);
    $providers = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // تحويل البيانات وتحسينها
    foreach ($providers as &$provider) {
        // تحويل القيم الرقمية
        $provider['id'] = intval($provider['id']);
        $provider['rating'] = floatval($provider['rating']);
        $provider['total_reviews'] = intval($provider['total_reviews']);
        $provider['services_count'] = intval($provider['services_count']);
        $provider['avg_service_rating'] = floatval($provider['avg_service_rating']);
        $provider['avg_price'] = floatval($provider['avg_price']);
        $provider['total_bookings'] = intval($provider['total_bookings']);
        $provider['min_price'] = floatval($provider['min_price']);
        $provider['max_price'] = floatval($provider['max_price']);
        $provider['total_reviews_count'] = intval($provider['total_reviews_count']);
        $provider['avg_review_rating'] = floatval($provider['avg_review_rating']);
        $provider['is_verified'] = boolval($provider['is_verified']);
        $provider['category_id'] = intval($provider['category_id']);

        // إضافة رابط الصورة الكامل
        if ($provider['profile_image'] && $provider['profile_image'] !== 'default_avatar.jpg') {
            $provider['profile_image'] = Config::BASE_URL . '/uploads/profiles/' . $provider['profile_image'];
        } else {
            $provider['profile_image'] = Config::BASE_URL . '/uploads/profiles/default_avatar.jpg';
        }

        // إزالة البيانات الحساسة
        unset($provider['email']);
        unset($provider['phone']);
    }

    // إرجاع النتيجة
    echo json_encode([
        'success' => true,
        'message' => 'تم جلب المزودين بنجاح',
        'data' => $providers,
        'service' => [
            'id' => $service['id'],
            'name' => $service['name']
        ]
    ], JSON_UNESCAPED_UNICODE);

} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage(),
        'data' => []
    ], JSON_UNESCAPED_UNICODE);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'خطأ في قاعدة البيانات',
        'data' => []
    ], JSON_UNESCAPED_UNICODE);
}
?> 