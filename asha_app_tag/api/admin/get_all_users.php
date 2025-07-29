<?php
// إيقاف عرض الأخطاء لمنع ظهور warnings في JSON
error_reporting(0);
ini_set('display_errors', 0);

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

require_once '../../config.php';
require_once '../../database.php';

// التحقق من نوع الطلب
if (isset($_SERVER['REQUEST_METHOD']) && $_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

try {
    $pdo = new PDO("mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=utf8mb4", DB_USER, DB_PASS);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    error_log("Database connection successful");
    
    // جلب جميع المستخدمين
    $query = "
        SELECT 
            id,
            name,
            email,
            phone,
            user_type as role,
            is_active,
            is_verified,
            created_at,
            last_login_at as last_login,
            '' as profile_image,
            city,
            address,
            bio
        FROM users
        ORDER BY created_at DESC
    ";
    
    $stmt = $pdo->prepare($query);
    $stmt->execute();
    $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    error_log("Query executed successfully. Found " . count($users) . " users");
    
    // معالجة البيانات
    foreach ($users as &$user) {
        $user['id'] = intval($user['id']);
        $user['is_active'] = boolval($user['is_active']);
        $user['is_verified'] = boolval($user['is_verified']);
        
        // تحويل التواريخ
        if ($user['created_at']) {
            $user['created_at'] = date('Y-m-d H:i:s', strtotime($user['created_at']));
        }
        if ($user['last_login']) {
            $user['last_login'] = date('Y-m-d H:i:s', strtotime($user['last_login']));
        }
        
        // إضافة معلومات إضافية
        $user['status'] = $user['is_active'] ? 'نشط' : 'محظور';
        $user['verification_status'] = $user['is_verified'] ? 'مؤكد' : 'غير مؤكد';
    }
    
    // إحصائيات
    $total_users = count($users);
    $active_users = count(array_filter($users, function($user) { return $user['is_active']; }));
    $verified_users = count(array_filter($users, function($user) { return $user['is_verified']; }));
    $admins = count(array_filter($users, function($user) { return $user['role'] === 'admin'; }));
    $providers = count(array_filter($users, function($user) { return $user['role'] === 'provider'; }));
    $customers = count(array_filter($users, function($user) { return $user['role'] === 'user'; }));
    
    $stats = [
        'total_users' => $total_users,
        'active_users' => $active_users,
        'verified_users' => $verified_users,
        'admins' => $admins,
        'providers' => $providers,
        'customers' => $customers,
        'blocked_users' => $total_users - $active_users
    ];
    
    echo json_encode([
        'success' => true,
        'message' => 'تم جلب المستخدمين بنجاح',
        'data' => $users,
        'stats' => $stats
    ], JSON_UNESCAPED_UNICODE);
    
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'خطأ في قاعدة البيانات: ' . $e->getMessage(),
        'data' => null
    ], JSON_UNESCAPED_UNICODE);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'خطأ عام: ' . $e->getMessage(),
        'data' => null
    ], JSON_UNESCAPED_UNICODE);
}
?> 