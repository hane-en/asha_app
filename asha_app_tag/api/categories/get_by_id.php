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
    
    // جلب معلومات الفئة
    $sql = "SELECT 
                c.id,
                c.name,
                c.description,
                c.image,
                c.is_active,
                c.created_at,
                COUNT(s.id) as services_count,
                AVG(s.rating) as avg_rating,
                COUNT(DISTINCT s.provider_id) as providers_count
            FROM categories c
            LEFT JOIN services s ON c.id = s.category_id AND s.is_active = 1
            WHERE c.id = ? AND c.is_active = 1
            GROUP BY c.id";
    
    $stmt = $pdo->prepare($sql);
    $stmt->execute([$categoryId]);
    $category = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$category) {
        throw new Exception('الفئة غير موجودة');
    }
    
    // تحويل البيانات
    $category['services_count'] = (int)$category['services_count'];
    $category['providers_count'] = (int)$category['providers_count'];
    $category['avg_rating'] = $category['avg_rating'] ? (float)round($category['avg_rating'], 1) : 0.0;
    $category['is_active'] = (bool)$category['is_active'];
    
    // جلب الخدمات المميزة في هذه الفئة
    $featuredServicesSql = "SELECT 
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
                                u.profile_image as provider_image
                            FROM services s
                            INNER JOIN users u ON s.provider_id = u.id
                            WHERE s.category_id = ?
                            AND s.is_active = 1
                            AND s.is_featured = 1
                            ORDER BY s.rating DESC, s.created_at DESC
                            LIMIT 5";
    
    $featuredStmt = $pdo->prepare($featuredServicesSql);
    $featuredStmt->execute([$categoryId]);
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
    
    echo json_encode([
        'success' => true,
        'message' => 'تم جلب معلومات الفئة بنجاح',
        'data' => [
            'category' => $category,
            'featured_services' => $featuredServices
        ]
    ], JSON_UNESCAPED_UNICODE);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'خطأ في جلب معلومات الفئة: ' . $e->getMessage(),
        'data' => []
    ], JSON_UNESCAPED_UNICODE);
}
?> 