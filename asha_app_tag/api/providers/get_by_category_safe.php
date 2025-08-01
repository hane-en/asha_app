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
    
    $categoryId = isset($_GET['category_id']) ? (int)$_GET['category_id'] : null;
    
    if (!$categoryId) {
        throw new Exception('معرف الفئة مطلوب');
    }
    
    // جلب معلومات الفئة أولاً
    $categoryQuery = "SELECT id, name, description FROM categories WHERE id = ? AND is_active = 1";
    $categoryStmt = $pdo->prepare($categoryQuery);
    $categoryStmt->execute([$categoryId]);
    $category = $categoryStmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$category) {
        throw new Exception('الفئة غير موجودة أو غير نشطة');
    }
    
    // استعلام بسيط وآمن
    $sql = "SELECT DISTINCT
                u.id,
                u.name,
                u.email,
                u.phone,
                u.address,
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
            AND s.category_id = ?
            AND u.is_active = 1
            AND s.is_active = 1
            GROUP BY u.id, u.name, u.email, u.phone, u.address, 
                     u.rating, u.total_reviews, u.is_verified, u.created_at, u.user_type,
                     c.id, c.name, c.description
            ORDER BY u.rating DESC, services_count DESC, avg_service_rating DESC, total_bookings DESC";
    
    $stmt = $pdo->prepare($sql);
    $stmt->execute([$categoryId]);
    $providers = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // تحويل البيانات بشكل آمن
    foreach ($providers as &$provider) {
        // تحويل الأرقام بشكل آمن
        $provider['rating'] = floatval($provider['rating'] ?? 0);
        $provider['total_reviews'] = intval($provider['total_reviews'] ?? 0);
        $provider['services_count'] = intval($provider['services_count'] ?? 0);
        $provider['avg_service_rating'] = floatval($provider['avg_service_rating'] ?? 0);
        $provider['avg_price'] = floatval($provider['avg_price'] ?? 0);
        $provider['total_bookings'] = intval($provider['total_bookings'] ?? 0);
        $provider['min_price'] = floatval($provider['min_price'] ?? 0);
        $provider['max_price'] = floatval($provider['max_price'] ?? 0);
        $provider['total_reviews_count'] = intval($provider['total_reviews_count'] ?? 0);
        $provider['avg_review_rating'] = floatval($provider['avg_review_rating'] ?? 0);
        $provider['is_verified'] = (bool)($provider['is_verified'] ?? false);
        
        // إضافة صورة افتراضية
        $provider['profile_image'] = 'default_avatar.jpg';
        
        // إضافة تقييم افتراضي إذا لم يكن موجوداً
        if ($provider['avg_service_rating'] == 0) {
            $provider['avg_service_rating'] = $provider['rating'] > 0 ? $provider['rating'] : 4.0;
        }
        
        // إضافة سعر افتراضي إذا لم يكن موجوداً
        if ($provider['avg_price'] == 0) {
            $provider['avg_price'] = 100.0;
        }
        
        // إضافة تقييم المراجعات إذا لم يكن موجوداً
        if ($provider['avg_review_rating'] == 0) {
            $provider['avg_review_rating'] = $provider['avg_service_rating'];
        }
        
        // إضافة معلومات إضافية
        $provider['price_range'] = [
            'min' => $provider['min_price'],
            'max' => $provider['max_price'],
            'avg' => $provider['avg_price']
        ];
        
        $provider['rating_info'] = [
            'overall_rating' => $provider['avg_service_rating'],
            'review_rating' => $provider['avg_review_rating'],
            'total_reviews' => $provider['total_reviews_count'],
            'total_bookings' => $provider['total_bookings']
        ];
    }
    
    // جلب إحصائيات إضافية للفئة
    $statsQuery = "SELECT 
                    COUNT(DISTINCT s.id) as total_services,
                    COUNT(DISTINCT u.id) as total_providers,
                    COALESCE(AVG(s.price), 0) as avg_category_price,
                    COALESCE(MIN(s.price), 0) as min_category_price,
                    COALESCE(MAX(s.price), 0) as max_category_price,
                    COALESCE(AVG(r.rating), 0) as avg_category_rating,
                    COUNT(DISTINCT b.id) as total_category_bookings
                   FROM services s
                   INNER JOIN users u ON s.provider_id = u.id
                   LEFT JOIN bookings b ON s.id = b.service_id AND b.status != 'cancelled'
                   LEFT JOIN reviews r ON s.id = r.service_id
                   WHERE s.category_id = ? AND s.is_active = 1 AND u.is_active = 1";
    
    $statsStmt = $pdo->prepare($statsQuery);
    $statsStmt->execute([$categoryId]);
    $categoryStats = $statsStmt->fetch(PDO::FETCH_ASSOC);
    
    // تحويل إحصائيات الفئة بشكل آمن
    $categoryStats['total_services'] = intval($categoryStats['total_services'] ?? 0);
    $categoryStats['total_providers'] = intval($categoryStats['total_providers'] ?? 0);
    $categoryStats['avg_category_price'] = floatval($categoryStats['avg_category_price'] ?? 0);
    $categoryStats['min_category_price'] = floatval($categoryStats['min_category_price'] ?? 0);
    $categoryStats['max_category_price'] = floatval($categoryStats['max_category_price'] ?? 0);
    $categoryStats['avg_category_rating'] = floatval($categoryStats['avg_category_rating'] ?? 0);
    $categoryStats['total_category_bookings'] = intval($categoryStats['total_category_bookings'] ?? 0);
    
    // تجهيز البيانات للإرسال
    $response = [
        'success' => true,
        'message' => 'تم جلب مزودي الخدمات بنجاح',
        'data' => [
            'category' => $category,
            'providers' => $providers,
            'total_providers' => count($providers),
            'category_stats' => [
                'total_services' => $categoryStats['total_services'],
                'total_providers' => $categoryStats['total_providers'],
                'avg_rating' => $categoryStats['avg_category_rating'],
                'price_range' => [
                    'min' => $categoryStats['min_category_price'],
                    'max' => $categoryStats['max_category_price'],
                    'avg' => $categoryStats['avg_category_price']
                ],
                'total_bookings' => $categoryStats['total_category_bookings']
            ]
        ],
        'total' => count($providers)
    ];
    
    echo json_encode($response, JSON_UNESCAPED_UNICODE);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'خطأ في جلب مزودي الخدمات: ' . $e->getMessage(),
        'data' => []
    ], JSON_UNESCAPED_UNICODE);
}
?> 