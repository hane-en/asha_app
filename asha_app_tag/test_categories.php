<?php
/**
 * ملف اختبار الفئات
 * للتحقق من أن الفئات تعمل بشكل صحيح
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
    'message' => 'Categories test completed',
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
    
    // اختبار وجود جدول الفئات
    if ($database->tableExists('categories')) {
        $result['tests']['table'] = [
            'status' => 'success',
            'message' => 'Categories table exists'
        ];
        
        // اختبار عدد الفئات
        $count = $database->getTotalCount('categories');
        $result['tests']['count'] = [
            'status' => 'success',
            'message' => "Found $count categories",
            'count' => $count
        ];
        
        // اختبار جلب الفئات النشطة
        $activeCategories = $database->select(
            "SELECT * FROM categories WHERE is_active = 1 ORDER BY created_at ASC"
        );
        
        if (!empty($activeCategories)) {
            $result['tests']['active_categories'] = [
                'status' => 'success',
                'message' => 'Active categories found',
                'categories' => $activeCategories
            ];
        } else {
            $result['tests']['active_categories'] = [
                'status' => 'warning',
                'message' => 'No active categories found'
            ];
        }
        
        // اختبار الفئات مع عدد الخدمات
        $categoriesWithServices = $database->select("
            SELECT 
                c.*,
                COUNT(s.id) as services_count
            FROM categories c
            LEFT JOIN services s ON c.id = s.category_id AND s.is_active = 1 AND s.is_verified = 1
            WHERE c.is_active = 1
            GROUP BY c.id
            ORDER BY c.created_at ASC
        ");
        
        $result['tests']['categories_with_services'] = [
            'status' => 'success',
            'message' => 'Categories with services count retrieved',
            'data' => $categoriesWithServices
        ];
        
    } else {
        $result['tests']['table'] = [
            'status' => 'error',
            'message' => 'Categories table does not exist'
        ];
    }
    
} catch (Exception $e) {
    $result['success'] = false;
    $result['message'] = 'Categories test failed: ' . $e->getMessage();
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