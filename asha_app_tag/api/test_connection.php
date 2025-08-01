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

require_once 'config/database.php';

try {
    $db = new Database();
    $pdo = $db->getConnection();
    
    if (!$pdo) {
        throw new Exception('فشل في الاتصال بقاعدة البيانات');
    }
    
    // اختبار الاتصال بقاعدة البيانات
    $stmt = $pdo->query('SELECT 1');
    $result = $stmt->fetch();
    
    if ($result) {
        // جلب عدد المزودين
        $stmt = $pdo->query("SELECT COUNT(*) as count FROM users WHERE user_type = 'provider' AND is_active = 1");
        $providerCount = $stmt->fetch(PDO::FETCH_ASSOC)['count'];
        
        // جلب عدد المستخدمين
        $stmt = $pdo->query("SELECT COUNT(*) as count FROM users WHERE user_type = 'user' AND is_active = 1");
        $userCount = $stmt->fetch(PDO::FETCH_ASSOC)['count'];
        
        // جلب عدد الخدمات
        $stmt = $pdo->query("SELECT COUNT(*) as count FROM services WHERE is_active = 1");
        $serviceCount = $stmt->fetch(PDO::FETCH_ASSOC)['count'];
        
        // جلب عدد الفئات
        $stmt = $pdo->query("SELECT COUNT(*) as count FROM categories WHERE is_active = 1");
        $categoryCount = $stmt->fetch(PDO::FETCH_ASSOC)['count'];
        
        echo json_encode([
            'success' => true,
            'message' => 'الاتصال بقاعدة البيانات يعمل بشكل صحيح',
            'data' => [
                'database_status' => 'connected',
                'providers_count' => (int)$providerCount,
                'users_count' => (int)$userCount,
                'services_count' => (int)$serviceCount,
                'categories_count' => (int)$categoryCount,
                'server_time' => date('Y-m-d H:i:s'),
                'php_version' => PHP_VERSION,
            ]
        ], JSON_UNESCAPED_UNICODE);
    } else {
        throw new Exception('فشل في اختبار قاعدة البيانات');
    }
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'خطأ في الاتصال بقاعدة البيانات: ' . $e->getMessage(),
        'data' => [
            'database_status' => 'error',
            'error_details' => $e->getMessage(),
            'server_time' => date('Y-m-d H:i:s'),
        ]
    ], JSON_UNESCAPED_UNICODE);
}
?> 