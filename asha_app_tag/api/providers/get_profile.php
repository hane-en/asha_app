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
    $sql = "SELECT 
                u.id,
                u.name,
                u.email,
                u.phone,
                u.address,
                'default_avatar.jpg' as profile_image,
                u.rating,
                u.total_reviews,
                u.is_verified,
                u.created_at,
                COUNT(s.id) as total_services,
                AVG(s.rating) as avg_service_rating,
                COUNT(DISTINCT b.id) as total_bookings,
                COUNT(DISTINCT CASE WHEN b.status = 'completed' THEN b.id END) as completed_bookings
            FROM users u
            LEFT JOIN services s ON u.id = s.provider_id AND s.is_active = 1
            LEFT JOIN bookings b ON s.id = b.service_id
            WHERE u.id = ? 
            AND u.user_type = 'provider'
            AND u.is_active = 1
            GROUP BY u.id";
    
    $stmt = $pdo->prepare($sql);
    $stmt->execute([$providerId]);
    $provider = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$provider) {
        throw new Exception('المزود غير موجود');
    }
    
    // تحويل البيانات
    $provider['rating'] = (float)$provider['rating'];
    $provider['total_reviews'] = (int)$provider['total_reviews'];
    $provider['total_services'] = (int)$provider['total_services'];
    $provider['avg_service_rating'] = (float)$provider['avg_service_rating'];
    $provider['total_bookings'] = (int)$provider['total_bookings'];
    $provider['completed_bookings'] = (int)$provider['completed_bookings'];
    $provider['is_verified'] = (bool)$provider['is_verified'];
    
    // جلب الخدمات المميزة للمزود
    $featuredServicesSql = "SELECT 
                                id,
                                title as name,
                                description,
                                price,
                                images,
                                city,
                                is_featured,
                                rating,
                                total_reviews,
                                created_at,
                                c.name as category_name
                            FROM services s
                            INNER JOIN categories c ON s.category_id = c.id
                            WHERE s.provider_id = ? 
                            AND s.is_active = 1
                            AND s.is_featured = 1
                            ORDER BY s.rating DESC, s.created_at DESC
                            LIMIT 5";
    
    $featuredStmt = $pdo->prepare($featuredServicesSql);
    $featuredStmt->execute([$providerId]);
    $featuredServices = $featuredStmt->fetchAll(PDO::FETCH_ASSOC);
    
    // تحويل بيانات الخدمات المميزة
    foreach ($featuredServices as &$service) {
        $service['is_featured'] = (bool)$service['is_featured'];
        $service['rating'] = (float)$service['rating'];
        $service['total_reviews'] = (int)$service['total_reviews'];
        
        // تحويل الصور من JSON
        if ($service['images']) {
            $service['images'] = json_decode($service['images'], true);
        } else {
            $service['images'] = [];
        }
    }
    
    // جلب التقييمات الأخيرة
    $reviewsSql = "SELECT 
                        r.id,
                        r.rating,
                        r.comment,
                        r.created_at,
                        u.name as user_name,
                        'default_avatar.jpg' as user_image,
                        s.title as service_title
                    FROM reviews r
                    INNER JOIN users u ON r.user_id = u.id
                    INNER JOIN services s ON r.service_id = s.id
                    WHERE s.provider_id = ?
                    ORDER BY r.created_at DESC
                    LIMIT 10";
    
    $reviewsStmt = $pdo->prepare($reviewsSql);
    $reviewsStmt->execute([$providerId]);
    $reviews = $reviewsStmt->fetchAll(PDO::FETCH_ASSOC);
    
    // تحويل بيانات التقييمات
    foreach ($reviews as &$review) {
        $review['rating'] = (int)$review['rating'];
    }
    
    echo json_encode([
        'success' => true,
        'message' => 'تم جلب معلومات المزود بنجاح',
        'data' => [
            'provider' => $provider,
            'featured_services' => $featuredServices,
            'recent_reviews' => $reviews
        ]
    ], JSON_UNESCAPED_UNICODE);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'خطأ في جلب معلومات المزود: ' . $e->getMessage(),
        'data' => []
    ], JSON_UNESCAPED_UNICODE);
}
?> 