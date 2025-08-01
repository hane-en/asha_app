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
    
    $limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 10;
    $categoryId = isset($_GET['category_id']) ? (int)$_GET['category_id'] : null;
    
    $sql = "SELECT 
                s.id,
                s.title as name,
                s.description,
                s.price,
                s.images,
                s.city,
                s.is_featured,
                s.rating,
                s.total_reviews,
                s.created_at,
                u.id as provider_id,
                u.name as provider_name,
                u.phone as provider_phone,
                u.email as provider_email,
                u.profile_image as provider_image,
                c.id as category_id,
                c.name as category_name
            FROM services s
            INNER JOIN users u ON s.provider_id = u.id AND u.user_type = 'provider'
            INNER JOIN categories c ON s.category_id = c.id
            WHERE s.is_featured = 1 
            AND s.is_active = 1 
            AND s.is_verified = 1";
    
    $params = [];
    
    if ($categoryId) {
        $sql .= " AND s.category_id = ?";
        $params[] = $categoryId;
    }
    
    $sql .= " ORDER BY s.rating DESC, s.created_at DESC LIMIT ?";
    $params[] = $limit;
    
    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    $services = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // تحويل البيانات
    foreach ($services as &$service) {
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
    
    echo json_encode([
        'success' => true,
        'message' => 'تم جلب الخدمات المميزة بنجاح',
        'data' => $services,
        'total' => count($services)
    ], JSON_UNESCAPED_UNICODE);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'خطأ في جلب الخدمات المميزة: ' . $e->getMessage(),
        'data' => []
    ], JSON_UNESCAPED_UNICODE);
}
?> 