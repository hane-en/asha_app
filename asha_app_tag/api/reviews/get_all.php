<?php
/**
 * API endpoint لجلب جميع التقييمات
 * GET /api/reviews/get_all.php
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
    
    // جلب جميع التقييمات مع معلومات الخدمة والمستخدم
    $query = "SELECT 
                r.id, r.service_id, r.user_id, r.rating, r.comment, r.created_at,
                s.title as service_title,
                u.name as user_name,
                p.name as provider_name
              FROM reviews r
              LEFT JOIN services s ON r.service_id = s.id
              LEFT JOIN users u ON r.user_id = u.id
              LEFT JOIN users p ON s.provider_id = p.id
              ORDER BY r.created_at DESC";
    
    // إضافة debug
    error_log("Executing reviews query: " . $query);
    
    $reviews = $database->select($query);
    
    if ($reviews === false) {
        throw new Exception('خطأ في جلب التقييمات من قاعدة البيانات');
    }
    
    // إضافة debug
    error_log("Reviews found: " . count($reviews));
    
    // تحويل البيانات إلى التنسيق المطلوب
    $formattedReviews = [];
    foreach ($reviews as $review) {
        $formattedReviews[] = [
            'id' => (int)$review['id'],
            'service_id' => (int)$review['service_id'],
            'user_id' => (int)$review['user_id'],
            'rating' => (float)$review['rating'],
            'comment' => $review['comment'],
            'service_title' => $review['service_title'],
            'user_name' => $review['user_name'],
            'provider_name' => $review['provider_name'],
            'created_at' => $review['created_at']
        ];
    }
    
    $response = [
        'success' => true,
        'message' => 'تم جلب التقييمات بنجاح',
        'timestamp' => date('Y-m-d H:i:s'),
        'data' => $formattedReviews,
        'count' => count($formattedReviews)
    ];
    
    echo json_encode($response, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    
} catch (Exception $e) {
    $errorResponse = [
        'success' => false,
        'message' => 'خطأ في جلب التقييمات: ' . $e->getMessage(),
        'timestamp' => date('Y-m-d H:i:s'),
        'data' => [],
        'count' => 0
    ];
    
    http_response_code(500);
    echo json_encode($errorResponse, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
}
?> 