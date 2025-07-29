<?php
/**
 * صفحة اختبار سريعة
 * يمكن الوصول إليها عبر: http://localhost/asha_app_backend/quick_test.php
 */

require_once 'config.php';
require_once 'database.php';

// إعداد CORS
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json; charset=utf-8');

try {
    $database = new Database();
    $database->connect();
    
    // اختبار بسيط
    $query = "
        SELECT 
            s.*,
            c.name as category_name,
            u.name as provider_name
        FROM services s
        LEFT JOIN categories c ON s.category_id = c.id
        LEFT JOIN users u ON s.provider_id = u.id
        ORDER BY s.created_at DESC
        LIMIT 5
    ";
    
    $result = $database->select($query);
    
    $response = [
        'success' => true,
        'message' => 'اختبار سريع',
        'timestamp' => date('Y-m-d H:i:s'),
        'data' => [
            'services' => $result ?: [],
            'count' => $result ? count($result) : 0
        ]
    ];
    
    echo json_encode($response, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    
} catch (Exception $e) {
    $response = [
        'success' => false,
        'message' => 'خطأ: ' . $e->getMessage(),
        'timestamp' => date('Y-m-d H:i:s'),
        'data' => []
    ];
    
    echo json_encode($response, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
}
?> 