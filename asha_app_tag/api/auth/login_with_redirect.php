<?php
/**
 * ملف تسجيل الدخول مع إعادة التوجيه إلى صفحة الحجز
 */

require_once '../config.php';
require_once '../database.php';

// إعداد CORS
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
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
    
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $input = json_decode(file_get_contents('php://input'), true);
        
        if (!$input) {
            throw new Exception('بيانات الطلب غير صحيحة');
        }
        
        // استخراج البيانات
        $email = isset($input['email']) ? trim($input['email']) : '';
        $password = isset($input['password']) ? $input['password'] : '';
        $service_id = isset($input['service_id']) ? intval($input['service_id']) : 0;
        
        // التحقق من البيانات المطلوبة
        if (empty($email) || empty($password)) {
            throw new Exception('البريد الإلكتروني وكلمة المرور مطلوبان');
        }
        
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            throw new Exception('البريد الإلكتروني غير صحيح');
        }
        
        // البحث عن المستخدم
        $user_query = "SELECT id, name, email, phone, password, role, is_active, is_verified 
                       FROM users WHERE email = ?";
        $user_stmt = $database->prepare($user_query);
        $user_stmt->bind_param('s', $email);
        $user_stmt->execute();
        $user_result = $user_stmt->get_result();
        
        if ($user_result->num_rows === 0) {
            throw new Exception('البريد الإلكتروني أو كلمة المرور غير صحيحة');
        }
        
        $user_data = $user_result->fetch_assoc();
        
        // التحقق من كلمة المرور
        if (!password_verify($password, $user_data['password'])) {
            throw new Exception('البريد الإلكتروني أو كلمة المرور غير صحيحة');
        }
        
        // التحقق من حالة الحساب
        if (!$user_data['is_active']) {
            throw new Exception('الحساب غير نشط');
        }
        
        // التحقق من التحقق من البريد الإلكتروني
        if (!$user_data['is_verified']) {
            throw new Exception('يرجى التحقق من بريدك الإلكتروني أولاً');
        }
        
        // إنشاء رمز الجلسة
        $session_token = bin2hex(random_bytes(32));
        $session_expiry = date('Y-m-d H:i:s', strtotime('+30 days'));
        
        // حذف الجلسات السابقة للمستخدم
        $delete_sessions_query = "DELETE FROM user_sessions WHERE user_id = ?";
        $delete_sessions_stmt = $database->prepare($delete_sessions_query);
        $delete_sessions_stmt->bind_param('i', $user_data['id']);
        $delete_sessions_stmt->execute();
        
        // إنشاء جلسة جديدة
        $session_query = "INSERT INTO user_sessions (user_id, token, expires_at) 
                         VALUES (?, ?, ?)";
        $session_stmt = $database->prepare($session_query);
        $session_stmt->bind_param('iss', $user_data['id'], $session_token, $session_expiry);
        $session_stmt->execute();
        
        // الحصول على معلومات الخدمة إذا كان هناك service_id
        $service_info = null;
        if ($service_id > 0) {
            $service_query = "SELECT id, name, price, provider_id FROM services WHERE id = ?";
            $service_stmt = $database->prepare($service_query);
            $service_stmt->bind_param('i', $service_id);
            $service_stmt->execute();
            $service_result = $service_stmt->get_result();
            
            if ($service_result->num_rows > 0) {
                $service_info = $service_result->fetch_assoc();
            }
        }
        
        $response['success'] = true;
        $response['message'] = 'تم تسجيل الدخول بنجاح';
        $response['data'] = [
            'user' => [
                'id' => $user_data['id'],
                'name' => $user_data['name'],
                'email' => $user_data['email'],
                'phone' => $user_data['phone'],
                'role' => $user_data['role']
            ],
            'session_token' => $session_token,
            'service_id' => $service_id,
            'service_info' => $service_info,
            'redirect_to_booking' => $service_id > 0
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