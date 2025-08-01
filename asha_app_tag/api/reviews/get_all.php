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
    
    $serviceId = isset($_GET['service_id']) ? (int)$_GET['service_id'] : null;
    $userId = isset($_GET['user_id']) ? (int)$_GET['user_id'] : null;
    $rating = isset($_GET['rating']) ? (int)$_GET['rating'] : null;
    
    $sql = "SELECT 
                r.id,
                r.user_id,
                r.service_id,
                r.rating,
                r.comment,
                r.created_at,
                u.name as user_name,
                u.email as user_email,
                s.title as service_name,
                provider.name as provider_name
            FROM reviews r
            INNER JOIN users u ON r.user_id = u.id
            INNER JOIN services s ON r.service_id = s.id
            INNER JOIN users provider ON s.provider_id = provider.id
            WHERE 1=1";
    
    $params = [];
    
    if ($serviceId) {
        $sql .= " AND r.service_id = ?";
        $params[] = $serviceId;
    }
    
    if ($userId) {
        $sql .= " AND r.user_id = ?";
        $params[] = $userId;
    }
    
    if ($rating) {
        $sql .= " AND r.rating = ?";
        $params[] = $rating;
    }
    
    $sql .= " ORDER BY r.created_at DESC";
    
    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    $reviews = $stmt->fetchAll();
    
    // تحويل أنواع البيانات للتقييمات
    foreach ($reviews as &$review) {
        $review['id'] = (int)$review['id'];
        $review['user_id'] = (int)$review['user_id'];
        $review['service_id'] = (int)$review['service_id'];
        $review['rating'] = (int)$review['rating'];
    }
    
    // إضافة إحصائيات
    $statsSql = "SELECT 
                    COUNT(*) as total_reviews,
                    AVG(rating) as average_rating,
                    COUNT(CASE WHEN rating = 5 THEN 1 END) as five_star,
                    COUNT(CASE WHEN rating = 4 THEN 1 END) as four_star,
                    COUNT(CASE WHEN rating = 3 THEN 1 END) as three_star,
                    COUNT(CASE WHEN rating = 2 THEN 1 END) as two_star,
                    COUNT(CASE WHEN rating = 1 THEN 1 END) as one_star
                  FROM reviews r";
    
    if ($serviceId) {
        $statsSql .= " WHERE r.service_id = ?";
        $statsParams = [$serviceId];
    } else {
        $statsParams = [];
    }
    
    $statsStmt = $pdo->prepare($statsSql);
    $statsStmt->execute($statsParams);
    $stats = $statsStmt->fetch();
    
    echo json_encode([
        'success' => true,
        'data' => $reviews,
        'count' => count($reviews),
        'stats' => [
            'total_reviews' => (int)$stats['total_reviews'],
            'average_rating' => $stats['average_rating'] ? (float)round($stats['average_rating'], 1) : 0.0,
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