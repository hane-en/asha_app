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

require_once 'api/config/database.php';

try {
    $db = new Database();
    $pdo = $db->getConnection();
    
    if (!$pdo) {
        throw new Exception('فشل في الاتصال بقاعدة البيانات');
    }
    
    $results = [];
    
    // فحص جدول الفئات
    try {
        $stmt = $pdo->query("SELECT * FROM categories ORDER BY id");
        $categories = $stmt->fetchAll(PDO::FETCH_ASSOC);
        $results['categories'] = $categories;
        $results['categories_count'] = count($categories);
    } catch (PDOException $e) {
        $results['categories_error'] = $e->getMessage();
    }
    
    // فحص جدول المستخدمين
    try {
        $stmt = $pdo->query("SELECT id, name, email, user_type, is_active FROM users ORDER BY id");
        $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
        $results['users'] = $users;
        $results['users_count'] = count($users);
    } catch (PDOException $e) {
        $results['users_error'] = $e->getMessage();
    }
    
    // فحص جدول الخدمات
    try {
        $stmt = $pdo->query("SELECT id, provider_id, category_id, title, is_active FROM services ORDER BY id");
        $services = $stmt->fetchAll(PDO::FETCH_ASSOC);
        $results['services'] = $services;
        $results['services_count'] = count($services);
    } catch (PDOException $e) {
        $results['services_error'] = $e->getMessage();
    }
    
    // فحص هيكل الجداول
    try {
        $stmt = $pdo->query("SHOW TABLES");
        $tables = $stmt->fetchAll(PDO::FETCH_COLUMN);
        $results['tables'] = $tables;
    } catch (PDOException $e) {
        $results['tables_error'] = $e->getMessage();
    }
    
    echo json_encode([
        'success' => true,
        'message' => 'تم فحص قاعدة البيانات بنجاح',
        'data' => $results
    ], JSON_UNESCAPED_UNICODE);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'خطأ في فحص قاعدة البيانات: ' . $e->getMessage(),
        'data' => []
    ], JSON_UNESCAPED_UNICODE);
}
?> 