<?php
/**
 * صفحة اختبار للتحقق من مشكلة get_all.php
 * يمكن الوصول إليها عبر: http://localhost/asha_app_backend/debug_get_all.php
 */

require_once 'config.php';
require_once 'database.php';

// إعداد CORS
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json; charset=utf-8');

try {
    $database = new Database();
    $database->connect();
    
    // اختبار 1: استعلام بسيط
    $simpleQuery = "SELECT * FROM services LIMIT 5";
    $simpleResult = $database->select($simpleQuery);
    
    // اختبار 2: استعلام مع JOIN
    $joinQuery = "
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
    $joinResult = $database->select($joinQuery);
    
    // اختبار 3: استعلام مع LIMIT و OFFSET
    $limit = 5;
    $offset = 0;
    $limitQuery = "
        SELECT 
            s.*,
            c.name as category_name,
            u.name as provider_name
        FROM services s
        LEFT JOIN categories c ON s.category_id = c.id
        LEFT JOIN users u ON s.provider_id = u.id
        ORDER BY s.created_at DESC
        LIMIT $limit OFFSET $offset
    ";
    $limitResult = $database->select($limitQuery);
    
    $response = [
        'success' => true,
        'message' => 'اختبار get_all.php',
        'timestamp' => date('Y-m-d H:i:s'),
        'data' => [
            'simple_query' => [
                'query' => $simpleQuery,
                'result' => $simpleResult,
                'count' => $simpleResult ? count($simpleResult) : 0
            ],
            'join_query' => [
                'query' => $joinQuery,
                'result' => $joinResult,
                'count' => $joinResult ? count($joinResult) : 0
            ],
            'limit_query' => [
                'query' => $limitQuery,
                'result' => $limitResult,
                'count' => $limitResult ? count($limitResult) : 0
            ]
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