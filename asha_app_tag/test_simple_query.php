<?php
/**
 * اختبار استعلام بسيط على جدول services
 */

require_once 'config.php';
require_once 'database.php';

header('Content-Type: application/json; charset=utf-8');

try {
    $database = new Database();
    $database->connect();

    // استعلام بسيط جداً
    $simpleQuery = "SELECT * FROM services LIMIT 5";
    $simpleResult = $database->select($simpleQuery);
    
    // استعلام مع JOIN بسيط
    $joinQuery = "
        SELECT s.id, s.title, s.is_active, s.is_verified, u.name as provider_name
        FROM services s
        LEFT JOIN users u ON s.provider_id = u.id
        LIMIT 5
    ";
    $joinResult = $database->select($joinQuery);
    
    // فحص جداول أخرى
    $usersQuery = "SELECT COUNT(*) as total FROM users";
    $usersResult = $database->selectOne($usersQuery);
    
    $categoriesQuery = "SELECT COUNT(*) as total FROM categories";
    $categoriesResult = $database->selectOne($categoriesQuery);
    
    $response = [
        'success' => true,
        'data' => [
            'simple_query_count' => count($simpleResult),
            'simple_query_result' => $simpleResult,
            'join_query_count' => count($joinResult),
            'join_query_result' => $joinResult,
            'users_count' => $usersResult['total'],
            'categories_count' => $categoriesResult['total']
        ]
    ];
    
    echo json_encode($response, JSON_UNESCAPED_UNICODE);
    
} catch (Exception $e) {
    $response = [
        'success' => false,
        'error' => $e->getMessage(),
        'trace' => $e->getTraceAsString()
    ];
    
    echo json_encode($response, JSON_UNESCAPED_UNICODE);
}
?> 