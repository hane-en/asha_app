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
    
    $userId = isset($_GET['user_id']) ? (int)$_GET['user_id'] : null;
    
    if (!$userId) {
        http_response_code(400);
        echo json_encode([
            'success' => false, 
            'message' => 'معرف المستخدم مطلوب',
            'timestamp' => date('Y-m-d H:i:s')
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }
    
    $sql = "SELECT 
                f.id,
                f.user_id,
                f.service_id,
                f.created_at,
                s.title as service_name,
                s.description as service_description,
                s.price as service_price,
                s.images as service_images,
                provider.name as provider_name,
                provider.phone as provider_phone,
                c.name as category_name
            FROM favorites f
            INNER JOIN services s ON f.service_id = s.id
            INNER JOIN users provider ON s.provider_id = provider.id
            INNER JOIN categories c ON s.category_id = c.id
            WHERE f.user_id = ? AND s.is_active = 1
            ORDER BY f.created_at DESC";
    
    $stmt = $pdo->prepare($sql);
    $stmt->execute([$userId]);
    $favorites = $stmt->fetchAll();
    
    // إضافة معلومات إضافية لكل مفضلة
    foreach ($favorites as &$favorite) {
        // تحويل الأرقام إلى int
        $favorite['id'] = (int)$favorite['id'];
        $favorite['user_id'] = (int)$favorite['user_id'];
        $favorite['service_id'] = (int)$favorite['service_id'];
        $favorite['service_price'] = (float)$favorite['service_price'];
        
        // جلب عدد التقييمات
        $reviewStmt = $pdo->prepare("SELECT COUNT(*) as count, AVG(rating) as avg_rating FROM reviews WHERE service_id = ?");
        $reviewStmt->execute([$favorite['service_id']]);
        $reviewData = $reviewStmt->fetch();
        
        $favorite['reviews_count'] = (int)$reviewData['count'];
        $favorite['average_rating'] = $reviewData['avg_rating'] ? (float)round($reviewData['avg_rating'], 1) : 0.0;
        
        // تحويل الصور من JSON
        if ($favorite['service_images']) {
            $favorite['service_images'] = json_decode($favorite['service_images'], true) ?: [];
        } else {
            $favorite['service_images'] = [];
        }
    }
    
    echo json_encode([
        'success' => true,
        'data' => $favorites,
        'count' => count($favorites),
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