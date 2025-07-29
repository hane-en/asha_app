<?php
/**
 * ملف اختبار الاتصال
 * للتحقق من أن الخادم يعمل بشكل صحيح
 */

// إعداد CORS
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');

// معالجة preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// معلومات الخادم
$serverInfo = [
    'success' => true,
    'message' => 'Server is running!',
    'timestamp' => date('Y-m-d H:i:s'),
    'php_version' => PHP_VERSION,
    'server_software' => $_SERVER['SERVER_SOFTWARE'] ?? 'Unknown',
    'request_method' => $_SERVER['REQUEST_METHOD'],
    'request_uri' => $_SERVER['REQUEST_URI'],
    'remote_addr' => $_SERVER['REMOTE_ADDR'] ?? 'Unknown',
    'user_agent' => $_SERVER['HTTP_USER_AGENT'] ?? 'Unknown',
    'headers' => getallheaders(),
];

// التحقق من قاعدة البيانات
try {
    require_once 'config.php';
    require_once 'database.php';
    
    $database = new Database();
    $database->connect();
    
    $serverInfo['database'] = [
        'status' => 'connected',
        'message' => 'Database connection successful'
    ];
    
} catch (Exception $e) {
    $serverInfo['database'] = [
        'status' => 'error',
        'message' => 'Database connection failed: ' . $e->getMessage()
    ];
}

// التحقق من الملفات المهمة
$importantFiles = [
    'config.php',
    'database.php',
    'api/auth/login.php',
    'api/auth/register.php',
    'api/services/get_all.php',
    'api/categories/get_all.php'
];

$serverInfo['files'] = [];
foreach ($importantFiles as $file) {
    $serverInfo['files'][$file] = file_exists($file) ? 'exists' : 'missing';
}

// إرجاع النتيجة
echo json_encode($serverInfo, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
?> 