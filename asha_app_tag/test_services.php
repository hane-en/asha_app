<?php
/**
 * ملف اختبار الخدمات
 * للتحقق من أن الخدمات تعمل بشكل صحيح
 */

require_once 'config.php';
require_once 'database.php';

// إعداد CORS
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');

// معالجة preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$result = [
    'success' => true,
    'message' => 'Services test completed',
    'timestamp' => date('Y-m-d H:i:s'),
    'tests' => []
];

try {
    $database = new Database();
    $database->connect();
    
    // اختبار الاتصال بقاعدة البيانات
    $result['tests']['database'] = [
        'status' => 'success',
        'message' => 'Database connection successful'
    ];
    
    // اختبار وجود جدول الخدمات
    if ($database->tableExists('services')) {
        $result['tests']['table'] = [
            'status' => 'success',
            'message' => 'Services table exists'
        ];
        
        // اختبار عدد الخدمات
        $count = $database->getTotalCount('services');
        $result['tests']['count'] = [
            'status' => 'success',
            'message' => "Found $count services",
            'count' => $count
        ];
        
        // اختبار جلب الخدمات النشطة
        $activeServices = $database->select(
            "SELECT * FROM services WHERE is_active = 1 AND is_verified = 1 ORDER BY created_at DESC LIMIT 10"
        );
        
        if (!empty($activeServices)) {
            $result['tests']['active_services'] = [
                'status' => 'success',
                'message' => 'Active services found',
                'services' => $activeServices
            ];
        } else {
            $result['tests']['active_services'] = [
                'status' => 'warning',
                'message' => 'No active services found'
            ];
        }
        
        // اختبار الخدمات مع الفئات
        $servicesWithCategories = $database->select("
            SELECT 
                s.*,
                c.name as category_name,
                u.name as provider_name
            FROM services s
            LEFT JOIN categories c ON s.category_id = c.id
            LEFT JOIN users u ON s.provider_id = u.id
            WHERE s.is_active = 1 AND s.is_verified = 1
            ORDER BY s.created_at DESC
            LIMIT 10
        ");
        
        $result['tests']['services_with_categories'] = [
            'status' => 'success',
            'message' => 'Services with categories retrieved',
            'data' => $servicesWithCategories
        ];
        
        // اختبار الخدمات حسب الفئة
        $categoryServices = $database->select("
            SELECT 
                s.*,
                c.name as category_name
            FROM services s
            LEFT JOIN categories c ON s.category_id = c.id
            WHERE s.is_active = 1 AND s.is_verified = 1 
            AND s.category_id = 1
            ORDER BY s.created_at DESC
            LIMIT 5
        ");
        
        $result['tests']['category_services'] = [
            'status' => 'success',
            'message' => 'Category services retrieved',
            'data' => $categoryServices
        ];
        
    } else {
        $result['tests']['table'] = [
            'status' => 'error',
            'message' => 'Services table does not exist'
        ];
    }
    
} catch (Exception $e) {
    $result['success'] = false;
    $result['message'] = 'Services test failed: ' . $e->getMessage();
    $result['tests']['error'] = [
        'status' => 'error',
        'message' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine()
    ];
}

// إرجاع النتيجة
echo json_encode($result, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
?> 