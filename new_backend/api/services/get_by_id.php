<?php
require_once '../../config.php';

header('Content-Type: application/json; charset=utf-8');
setupCORS();

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit;
}

try {
    $serviceId = isset($_GET['id']) ? (int)$_GET['id'] : 0;
    
    if ($serviceId <= 0) {
        echo json_encode(['success' => false, 'message' => 'معرف الخدمة مطلوب']);
        exit;
    }
    
    $pdo = getDatabaseConnection();
    
    $query = "SELECT s.*, c.name as category_name, u.name as provider_name,
                     (SELECT AVG(rating) FROM reviews WHERE service_id = s.id) as avg_rating,
                     (SELECT COUNT(*) FROM reviews WHERE service_id = s.id) as review_count,
                     (SELECT COUNT(*) FROM favorites WHERE service_id = s.id) as favorite_count
              FROM services s 
              LEFT JOIN categories c ON s.category_id = c.id
              LEFT JOIN users u ON s.provider_id = u.id
              WHERE s.id = ? AND s.is_active = 1";
    
    $stmt = $pdo->prepare($query);
    $stmt->execute([$serviceId]);
    $service = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$service) {
        echo json_encode(['success' => false, 'message' => 'الخدمة غير موجودة']);
        exit;
    }
    
    // معالجة البيانات
    $service['avg_rating'] = $service['avg_rating'] ? round($service['avg_rating'], 1) : 0;
    $service['price'] = (float)$service['price'];
    $service['is_favorite'] = false; // سيتم تحديثه لاحقاً إذا كان المستخدم مسجل دخول
    
    // جلب التقييمات
    $reviewsQuery = "SELECT r.*, u.name as user_name, u.profile_image
                     FROM reviews r
                     LEFT JOIN users u ON r.user_id = u.id
                     WHERE r.service_id = ? AND r.is_active = 1
                     ORDER BY r.created_at DESC
                     LIMIT 10";
    
    $stmt = $pdo->prepare($reviewsQuery);
    $stmt->execute([$serviceId]);
    $reviews = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'success' => true,
        'message' => 'تم جلب الخدمة بنجاح',
        'data' => [
            'service' => $service,
            'reviews' => $reviews
        ]
    ]);
    
} catch (Exception $e) {
    logError('Get service by ID error: ' . $e->getMessage());
    echo json_encode(['success' => false, 'message' => 'خطأ في الخادم']);
}
?> 