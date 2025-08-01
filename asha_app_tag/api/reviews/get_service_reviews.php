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
    
    if (!$serviceId) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'معرف الخدمة مطلوب'], JSON_UNESCAPED_UNICODE);
        exit();
    }
    
    // التحقق من وجود الخدمة
    $serviceStmt = $pdo->prepare("SELECT id, title FROM services WHERE id = ? AND is_active = 1");
    $serviceStmt->execute([$serviceId]);
    $service = $serviceStmt->fetch();
    
    if (!$service) {
        http_response_code(404);
        echo json_encode(['success' => false, 'message' => 'الخدمة غير موجودة'], JSON_UNESCAPED_UNICODE);
        exit();
    }
    
    $sql = "SELECT 
                r.id,
                r.user_id,
                r.rating,
                r.comment,
                r.created_at,
                u.name as user_name,
                u.email as user_email
            FROM reviews r
            INNER JOIN users u ON r.user_id = u.id
            WHERE r.service_id = ?
            ORDER BY r.created_at DESC";
    
    $stmt = $pdo->prepare($sql);
    $stmt->execute([$serviceId]);
    $reviews = $stmt->fetchAll();
    
    // إضافة إحصائيات التقييم
    $statsSql = "SELECT 
                    COUNT(*) as total_reviews,
                    AVG(rating) as average_rating,
                    COUNT(CASE WHEN rating = 5 THEN 1 END) as five_star,
                    COUNT(CASE WHEN rating = 4 THEN 1 END) as four_star,
                    COUNT(CASE WHEN rating = 3 THEN 1 END) as three_star,
                    COUNT(CASE WHEN rating = 2 THEN 1 END) as two_star,
                    COUNT(CASE WHEN rating = 1 THEN 1 END) as one_star
                  FROM reviews 
                  WHERE service_id = ?";
    
    $statsStmt = $pdo->prepare($statsSql);
    $statsStmt->execute([$serviceId]);
    $stats = $statsStmt->fetch();
    
    echo json_encode([
        'success' => true,
        'data' => [
            'service' => [
                'id' => $service['id'],
                'title' => $service['title']
            ],
            'reviews' => $reviews,
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
            ]
        ],
        'count' => count($reviews),
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