<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
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
    
    $limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 10;
    $offset = isset($_GET['offset']) ? (int)$_GET['offset'] : 0;
    
    // التحقق من الحد الأقصى
    if ($limit > 50) {
        $limit = 50;
    }
    
    $sql = "SELECT 
                r.id,
                r.user_id,
                r.service_id,
                r.rating,
                r.comment,
                r.created_at,
                u.name as user_name,
                s.title as service_name,
                provider.name as provider_name,
                c.name as category_name
            FROM reviews r
            INNER JOIN users u ON r.user_id = u.id
            INNER JOIN services s ON r.service_id = s.id
            INNER JOIN users provider ON s.provider_id = provider.id
            INNER JOIN categories c ON s.category_id = c.id
            WHERE s.is_active = 1
            ORDER BY r.created_at DESC
            LIMIT ? OFFSET ?";
    
    $stmt = $pdo->prepare($sql);
    $stmt->execute([$limit, $offset]);
    $reviews = $stmt->fetchAll();
    
    // إضافة معلومات إضافية لكل تقييم
    foreach ($reviews as &$review) {
        // جلب عدد التقييمات للخدمة
        $serviceReviewStmt = $pdo->prepare("SELECT COUNT(*) as count, AVG(rating) as avg_rating FROM reviews WHERE service_id = ?");
        $serviceReviewStmt->execute([$review['service_id']]);
        $serviceReviewData = $serviceReviewStmt->fetch();
        
        $review['service_reviews_count'] = (int)$serviceReviewData['count'];
        $review['service_average_rating'] = $serviceReviewData['avg_rating'] ? round($serviceReviewData['avg_rating'], 1) : 0;
    }
    
    // جلب إحصائيات عامة
    $statsSql = "SELECT 
                    COUNT(*) as total_reviews,
                    AVG(rating) as average_rating,
                    COUNT(CASE WHEN rating = 5 THEN 1 END) as five_star,
                    COUNT(CASE WHEN rating = 4 THEN 1 END) as four_star,
                    COUNT(CASE WHEN rating = 3 THEN 1 END) as three_star,
                    COUNT(CASE WHEN rating = 2 THEN 1 END) as two_star,
                    COUNT(CASE WHEN rating = 1 THEN 1 END) as one_star
                  FROM reviews r
                  INNER JOIN services s ON r.service_id = s.id
                  WHERE s.is_active = 1";
    
    $statsStmt = $pdo->prepare($statsSql);
    $statsStmt->execute();
    $stats = $statsStmt->fetch();
    
    echo json_encode([
        'success' => true,
        'data' => $reviews,
        'count' => count($reviews),
        'pagination' => [
            'limit' => $limit,
            'offset' => $offset,
            'has_more' => count($reviews) === $limit
        ],
        'stats' => [
            'total_reviews' => (int)$stats['total_reviews'],
            'average_rating' => $stats['average_rating'] ? round($stats['average_rating'], 1) : 0,
            'rating_distribution' => [
                'five_star' => (int)$stats['five_star'],
                'four_star' => (int)$stats['four_star'],
                'three_star' => (int)$stats['three_star'],
                'two_star' => (int)$stats['two_star'],
                'one_star' => (int)$stats['one_star']
            ]
        ],
        'timestamp' => date('Y-m-d H:i:s')
    ], JSON_UNESCAPED_UNICODE);
    
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'خطأ في قاعدة البيانات: ' . $e->getMessage(),
        'timestamp' => date('Y-m-d H:i:s')
    ], JSON_UNESCAPED_UNICODE);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'خطأ في الخادم: ' . $e->getMessage(),
        'timestamp' => date('Y-m-d H:i:s')
    ], JSON_UNESCAPED_UNICODE);
}
?> 