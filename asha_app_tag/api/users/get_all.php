<?php
/**
 * API endpoint لجلب جميع المستخدمين
 * GET /api/users/get_all.php
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

require_once '../../config.php';
require_once '../../database.php';

try {
    $database = new Database();
    $database->connect();
    
    // جلب جميع المستخدمين
    $query = "SELECT id, name, email, phone, role, is_active, created_at 
              FROM users 
              ORDER BY created_at DESC";
    
    // إضافة debug
    error_log("Executing users query: " . $query);
    
    $users = $database->select($query);
    
    if ($users === false) {
        throw new Exception('خطأ في جلب المستخدمين من قاعدة البيانات');
    }
    
    // إضافة debug
    error_log("Users found: " . count($users));
    
    // تحويل البيانات إلى التنسيق المطلوب
    $formattedUsers = [];
    foreach ($users as $user) {
        $formattedUsers[] = [
            'id' => (int)$user['id'],
            'name' => $user['name'],
            'email' => $user['email'],
            'phone' => $user['phone'],
            'role' => $user['role'],
            'is_active' => (bool)$user['is_active'],
            'created_at' => $user['created_at']
        ];
    }
    
    $response = [
        'success' => true,
        'message' => 'تم جلب المستخدمين بنجاح',
        'timestamp' => date('Y-m-d H:i:s'),
        'data' => $formattedUsers,
        'count' => count($formattedUsers)
    ];
    
    echo json_encode($response, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    
} catch (Exception $e) {
    $errorResponse = [
        'success' => false,
        'message' => 'خطأ في جلب المستخدمين: ' . $e->getMessage(),
        'timestamp' => date('Y-m-d H:i:s'),
        'data' => [],
        'count' => 0
    ];
    
    http_response_code(500);
    echo json_encode($errorResponse, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
}
?> 