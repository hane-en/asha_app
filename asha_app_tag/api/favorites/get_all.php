<?php
/**
 * API endpoint لجلب جميع المفضلة
 * GET /api/favorites/get_all.php
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

require_once '../../config.php';
require_once '../../database.php';

try {
    $database = new Database();
    $database->connect();
    
    // جلب جميع المفضلة مع معلومات الخدمة والمستخدم
    $query = "SELECT 
                f.id, f.service_id, f.user_id, f.created_at,
                s.title as service_title,
                s.price as service_price,
                u.name as user_name,
                p.name as provider_name
              FROM favorites f
              LEFT JOIN services s ON f.service_id = s.id
              LEFT JOIN users u ON f.user_id = u.id
              LEFT JOIN users p ON s.provider_id = p.id
              ORDER BY f.created_at DESC";
    
    // إضافة debug
    error_log("Executing favorites query: " . $query);
    
    $favorites = $database->select($query);
    
    if ($favorites === false) {
        throw new Exception('خطأ في جلب المفضلة من قاعدة البيانات');
    }
    
    // إضافة debug
    error_log("Favorites found: " . count($favorites));
    
    // تحويل البيانات إلى التنسيق المطلوب
    $formattedFavorites = [];
    foreach ($favorites as $favorite) {
        $formattedFavorites[] = [
            'id' => (int)$favorite['id'],
            'service_id' => (int)$favorite['service_id'],
            'user_id' => (int)$favorite['user_id'],
            'service_title' => $favorite['service_title'],
            'service_price' => (float)$favorite['service_price'],
            'user_name' => $favorite['user_name'],
            'provider_name' => $favorite['provider_name'],
            'created_at' => $favorite['created_at']
        ];
    }
    
    $response = [
        'success' => true,
        'message' => 'تم جلب المفضلة بنجاح',
        'timestamp' => date('Y-m-d H:i:s'),
        'data' => $formattedFavorites,
        'count' => count($formattedFavorites)
    ];
    
    echo json_encode($response, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    
} catch (Exception $e) {
    $errorResponse = [
        'success' => false,
        'message' => 'خطأ في جلب المفضلة: ' . $e->getMessage(),
        'timestamp' => date('Y-m-d H:i:s'),
        'data' => [],
        'count' => 0
    ];
    
    http_response_code(500);
    echo json_encode($errorResponse, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
}
?> 