<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// التعامل مع طلبات OPTIONS
if (isset($_SERVER['REQUEST_METHOD']) && $_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once '../config/database.php';

try {
    $db = new Database();
    $pdo = $db->getConnection();
    
    if (!$pdo) {
        throw new Exception('فشل في الاتصال بقاعدة البيانات');
    }
    
    $providerId = isset($_GET['provider_id']) ? (int)$_GET['provider_id'] : null;
    
    if (!$providerId) {
        throw new Exception('معرف المزود مطلوب');
    }
    
    // جلب معلومات المزود
    $providerQuery = "SELECT 
                        id, name, email, phone, address, COALESCE(profile_image, 'default_avatar.jpg') as profile_image, 
                        rating, total_reviews, is_verified, created_at, bio
                      FROM users 
                      WHERE id = ? AND user_type = 'provider' AND is_active = 1";
    
    $providerStmt = $pdo->prepare($providerQuery);
    $providerStmt->execute([$providerId]);
    $provider = $providerStmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$provider) {
        throw new Exception('المزود غير موجود أو غير نشط');
    }
    
    // جلب خدمات المزود مع معلومات مفصلة
    $servicesQuery = "SELECT 
                        s.id, s.title, s.description, s.price, s.images, 
                        s.is_active, s.created_at, s.updated_at,
                        c.id as category_id, c.name as category_name, c.description as category_description,
                        COUNT(DISTINCT r.id) as reviews_count,
                        AVG(r.rating) as avg_review_rating,
                        COUNT(DISTINCT b.id) as bookings_count,
                        COUNT(DISTINCT CASE WHEN b.status = 'completed' THEN b.id END) as completed_bookings
                      FROM services s
                      LEFT JOIN categories c ON s.category_id = c.id
                      LEFT JOIN reviews r ON s.id = r.service_id
                      LEFT JOIN bookings b ON s.id = b.service_id
                      WHERE s.provider_id = ? AND s.is_active = 1
                      GROUP BY s.id, s.title, s.description, s.price, s.images, 
                               s.is_active, s.created_at, s.updated_at,
                               c.id, c.name, c.description
                      ORDER BY s.created_at DESC";
    
    $servicesStmt = $pdo->prepare($servicesQuery);
    $servicesStmt->execute([$providerId]);
    $services = $servicesStmt->fetchAll(PDO::FETCH_ASSOC);
    
    // تحويل البيانات وتحسينها
    foreach ($services as &$service) {
        $service['price'] = floatval($service['price'] ?? 0);
        $service['reviews_count'] = intval($service['reviews_count'] ?? 0);
        $service['avg_review_rating'] = floatval($service['avg_review_rating'] ?? 0);
        $service['bookings_count'] = intval($service['bookings_count'] ?? 0);
        $service['completed_bookings'] = intval($service['completed_bookings'] ?? 0);
        $service['is_active'] = (bool)($service['is_active'] ?? true);
        
        // إضافة تقييم افتراضي إذا لم يكن موجوداً
        if ($service['avg_review_rating'] == 0) {
            $service['avg_review_rating'] = 4.0; // تقييم افتراضي
        }
        
        // إضافة معلومات إضافية
        $service['rating_info'] = [
            'overall_rating' => $service['avg_review_rating'],
            'reviews_count' => $service['reviews_count'],
            'bookings_count' => $service['bookings_count'],
            'completion_rate' => $service['bookings_count'] > 0 
                ? round(($service['completed_bookings'] / $service['bookings_count']) * 100, 1)
                : 0
        ];
    }
    
    // جلب إحصائيات المزود
    $statsQuery = "SELECT 
                    COUNT(DISTINCT s.id) as total_services,
                    AVG(s.price) as avg_service_price,
                    MIN(s.price) as min_service_price,
                    MAX(s.price) as max_service_price,
                    COUNT(DISTINCT b.id) as total_bookings,
                    COUNT(DISTINCT CASE WHEN b.status = 'completed' THEN b.id END) as completed_bookings,
                    AVG(r.rating) as overall_rating,
                    COUNT(DISTINCT r.id) as total_reviews
                   FROM users u
                   LEFT JOIN services s ON u.id = s.provider_id AND s.is_active = 1
                   LEFT JOIN bookings b ON s.id = b.service_id
                   LEFT JOIN reviews r ON s.id = r.service_id
                   WHERE u.id = ? AND u.user_type = 'provider'";
    
    $statsStmt = $pdo->prepare($statsQuery);
    $statsStmt->execute([$providerId]);
    $stats = $statsStmt->fetch(PDO::FETCH_ASSOC);
    
    // تحويل الإحصائيات
    $stats['total_services'] = intval($stats['total_services'] ?? 0);
    $stats['avg_service_price'] = floatval($stats['avg_service_price'] ?? 0);
    $stats['min_service_price'] = floatval($stats['min_service_price'] ?? 0);
    $stats['max_service_price'] = floatval($stats['max_service_price'] ?? 0);
    $stats['total_bookings'] = intval($stats['total_bookings'] ?? 0);
    $stats['completed_bookings'] = intval($stats['completed_bookings'] ?? 0);
    $stats['overall_rating'] = floatval($stats['overall_rating'] ?? 0);
    $stats['total_reviews'] = intval($stats['total_reviews'] ?? 0);
    
    // إضافة قيم افتراضية
    if ($stats['overall_rating'] == 0) {
        $stats['overall_rating'] = $provider['rating'] > 0 ? $provider['rating'] : 4.0;
    }
    
    if ($stats['avg_service_price'] == 0) {
        $stats['avg_service_price'] = 100.0;
    }
    
    // التأكد من وجود جميع الخصائص المطلوبة
    $stats['overall_rating'] = $stats['overall_rating'] ?? 4.0;
    $stats['total_services'] = $stats['total_services'] ?? 0;
    $stats['total_bookings'] = $stats['total_bookings'] ?? 0;
    $stats['avg_service_price'] = $stats['avg_service_price'] ?? 100.0;
    
    // إضافة معلومات إضافية للإحصائيات
    $stats['price_range'] = [
        'min' => $stats['min_service_price'],
        'max' => $stats['max_service_price'],
        'avg' => $stats['avg_service_price']
    ];
    
    $stats['booking_stats'] = [
        'total' => $stats['total_bookings'],
        'completed' => $stats['completed_bookings'],
        'completion_rate' => $stats['total_bookings'] > 0 
            ? round(($stats['completed_bookings'] / $stats['total_bookings']) * 100, 1)
            : 0
    ];
    
    // تجهيز البيانات للإرسال
    $response = [
        'success' => true,
        'message' => 'تم جلب خدمات المزود بنجاح',
        'data' => [
            'provider' => $provider,
            'services' => $services,
            'statistics' => $stats,
            'total_services' => count($services)
        ],
        'total' => count($services)
    ];
    
    echo json_encode($response, JSON_UNESCAPED_UNICODE);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'خطأ في جلب خدمات المزود: ' . $e->getMessage(),
        'data' => []
    ], JSON_UNESCAPED_UNICODE);
}
?> 