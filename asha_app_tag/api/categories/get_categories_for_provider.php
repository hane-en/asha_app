<?php
/**
 * ملف الحصول على الفئات المتاحة لمزودي الخدمات
 */

require_once '../config.php';
require_once '../database.php';

// إعداد CORS
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$response = [
    'success' => false,
    'message' => '',
    'data' => null
];

try {
    $database = new Database();
    $database->connect();
    
    if ($_SERVER['REQUEST_METHOD'] === 'GET') {
        // الحصول على جميع الفئات النشطة
        $categories_query = "SELECT id, name, description, icon, is_active, created_at
                           FROM categories 
                           WHERE is_active = 1
                           ORDER BY name ASC";
        
        $categories_stmt = $database->prepare($categories_query);
        $categories_stmt->execute();
        $categories_result = $categories_stmt->get_result();
        
        $categories = [];
        while ($row = $categories_result->fetch_assoc()) {
            // الحصول على عدد مزودي الخدمات في كل فئة
            $providers_count_query = "SELECT COUNT(DISTINCT u.id) as providers_count
                                    FROM users u
                                    INNER JOIN services s ON u.id = s.provider_id
                                    WHERE s.category_id = ? AND u.role = 'provider' AND u.is_active = 1";
            
            $providers_count_stmt = $database->prepare($providers_count_query);
            $providers_count_stmt->bind_param('i', $row['id']);
            $providers_count_stmt->execute();
            $providers_count_result = $providers_count_stmt->get_result();
            $providers_count = $providers_count_result->fetch_assoc();
            
            $row['providers_count'] = $providers_count['providers_count'];
            $categories[] = $row;
        }
        
        // الحصول على إحصائيات عامة
        $stats_query = "SELECT 
                           COUNT(DISTINCT c.id) as total_categories,
                           COUNT(DISTINCT u.id) as total_providers,
                           COUNT(DISTINCT s.id) as total_services
                        FROM categories c
                        LEFT JOIN services s ON c.id = s.category_id
                        LEFT JOIN users u ON s.provider_id = u.id AND u.role = 'provider'
                        WHERE c.is_active = 1";
        
        $stats_stmt = $database->prepare($stats_query);
        $stats_stmt->execute();
        $stats_result = $stats_stmt->get_result();
        $stats = $stats_result->fetch_assoc();
        
        $response['success'] = true;
        $response['message'] = 'تم الحصول على الفئات بنجاح';
        $response['data'] = [
            'categories' => $categories,
            'statistics' => $stats,
            'total_categories' => count($categories)
        ];
        
    } else {
        throw new Exception('طريقة الطلب غير مدعومة');
    }
    
} catch (Exception $e) {
    $response['message'] = $e->getMessage();
    http_response_code(400);
}

echo json_encode($response, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
?> 