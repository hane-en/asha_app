<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');

require_once 'config.php';

$result = [
    'success' => false,
    'message' => '',
    'database_info' => []
];

try {
    // الاتصال بقاعدة البيانات
    $pdo = new PDO(
        "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=utf8mb4",
        DB_USER,
        DB_PASS,
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
        ]
    );
    
    $result['database_info']['connection'] = 'Connected';
    $result['database_info']['database_name'] = DB_NAME;
    $result['database_info']['host'] = DB_HOST;
    
    // التحقق من الجداول
    $tables = $pdo->query("SHOW TABLES")->fetchAll(PDO::FETCH_COLUMN);
    $result['database_info']['tables'] = $tables;
    
    // التحقق من جدول الفئات
    if (in_array('categories', $tables)) {
        $categories_count = $pdo->query("SELECT COUNT(*) as count FROM categories WHERE is_active = 1")->fetch()['count'];
        $result['database_info']['categories_count'] = $categories_count;
        
        // جلب عينة من الفئات
        $categories = $pdo->query("SELECT id, name, is_active FROM categories LIMIT 5")->fetchAll();
        $result['database_info']['categories_sample'] = $categories;
    }
    
    // التحقق من جدول الخدمات
    if (in_array('services', $tables)) {
        $services_count = $pdo->query("SELECT COUNT(*) as count FROM services WHERE is_active = 1")->fetch()['count'];
        $result['database_info']['services_count'] = $services_count;
    }
    
    // التحقق من جدول المستخدمين
    if (in_array('users', $tables)) {
        $users_count = $pdo->query("SELECT COUNT(*) as count FROM users")->fetch()['count'];
        $result['database_info']['users_count'] = $users_count;
    }
    
    $result['success'] = true;
    $result['message'] = 'قاعدة البيانات تعمل بشكل صحيح';
    
} catch (PDOException $e) {
    $result['success'] = false;
    $result['message'] = 'خطأ في قاعدة البيانات: ' . $e->getMessage();
    $result['error'] = [
        'code' => $e->getCode(),
        'message' => $e->getMessage()
    ];
} catch (Exception $e) {
    $result['success'] = false;
    $result['message'] = 'خطأ عام: ' . $e->getMessage();
}

echo json_encode($result, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
?> 