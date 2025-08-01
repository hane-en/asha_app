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

require_once '../config.php';
require_once '../database.php';

try {
    $database = new Database();
    $conn = $database->connect();
    
    if (!$conn) {
        throw new Exception('فشل في الاتصال بقاعدة البيانات');
    }
    
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
            WHERE c.is_active = 1
            GROUP BY c.id
            ORDER BY c.name ASC";
    
    error_log("Categories API: Executing query: $sql");
    
    $categories = $database->select($sql);
    
    if ($categories === false) {
        throw new Exception('خطأ في جلب الفئات من قاعدة البيانات');
    }
    
    error_log("Categories API: Found " . count($categories) . " categories");
    
    // تحويل البيانات
    foreach ($categories as &$category) {
        $category['services_count'] = (int)$category['services_count'];
        $category['providers_count'] = (int)$category['providers_count'];
        $category['avg_rating'] = $category['avg_rating'] ? (float)round($category['avg_rating'], 1) : 0.0;
        $category['is_active'] = (bool)$category['is_active'];
    }
    
    successResponse($categories, 'تم جلب الفئات بنجاح');
    
} catch (Exception $e) {
    error_log("Categories API Error: " . $e->getMessage());
    logError("Get categories error: " . $e->getMessage());
    errorResponse('خطأ في قاعدة البيانات: ' . $e->getMessage(), 500);
}
?>

