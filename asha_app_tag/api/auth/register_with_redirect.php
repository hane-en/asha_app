<?php
/**
 * ملف التسجيل مع إعادة التوجيه إلى صفحة الحجز
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
        $name = isset($input['name']) ? trim($input['name']) : '';
        $email = isset($input['email']) ? trim($input['email']) : '';
        $phone = isset($input['phone']) ? trim($input['phone']) : '';
        $password = isset($input['password']) ? $input['password'] : '';
        $role = isset($input['role']) ? $input['role'] : 'user';
        $service_id = isset($input['service_id']) ? intval($input['service_id']) : 0;
        $category_id = isset($input['category_id']) ? intval($input['category_id']) : 0;
        
        // التحقق من البيانات المطلوبة
        if (empty($name) || empty($email) || empty($phone) || empty($password)) {
            throw new Exception('جميع الحقول مطلوبة');
        }
        
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            throw new Exception('البريد الإلكتروني غير صحيح');
        }
        
        if (strlen($password) < 6) {
            throw new Exception('كلمة المرور يجب أن تكون 6 أحرف على الأقل');
        }
        
        // التحقق من عدم وجود البريد الإلكتروني مسبقاً
        $email_check_query = "SELECT id FROM users WHERE email = ?";
        $email_check_stmt = $database->prepare($email_check_query);
        $email_check_stmt->bind_param('s', $email);
        $email_check_stmt->execute();
        $email_check_result = $email_check_stmt->get_result();
        
        if ($email_check_result->num_rows > 0) {
            throw new Exception('البريد الإلكتروني مستخدم مسبقاً');
        }
        
        // التحقق من عدم وجود رقم الهاتف مسبقاً
        $phone_check_query = "SELECT id FROM users WHERE phone = ?";
        $phone_check_stmt = $database->prepare($phone_check_query);
        $phone_check_stmt->bind_param('s', $phone);
        $phone_check_stmt->execute();
        $phone_check_result = $phone_check_stmt->get_result();
        
        if ($phone_check_result->num_rows > 0) {
            throw new Exception('رقم الهاتف مستخدم مسبقاً');
        }
        
        // تشفير كلمة المرور
        $hashed_password = password_hash($password, PASSWORD_DEFAULT);
        
        // إدراج المستخدم الجديد
        $insert_query = "INSERT INTO users (name, email, phone, password, role, is_active, created_at) 
                        VALUES (?, ?, ?, ?, ?, 1, NOW())";
        $insert_stmt = $database->prepare($insert_query);
        $insert_stmt->bind_param('sssss', $name, $email, $phone, $hashed_password, $role);
        
        if (!$insert_stmt->execute()) {
            throw new Exception('فشل في إنشاء الحساب');
        }
        
        $user_id = $database->getLastInsertId();
        
        // إذا كان المستخدم مزود خدمة، إضافة معلومات الفئة
        if ($role === 'provider' && $category_id > 0) {
            $provider_category_query = "UPDATE users SET category_id = ? WHERE id = ?";
            $provider_category_stmt = $database->prepare($provider_category_query);
            $provider_category_stmt->bind_param('ii', $category_id, $user_id);
            $provider_category_stmt->execute();
        }
        
        // إنشاء رمز التحقق
        $verification_code = sprintf('%06d', mt_rand(100000, 999999));
        $verification_expiry = date('Y-m-d H:i:s', strtotime('+1 hour'));
        
        $verification_query = "INSERT INTO verification_codes (user_id, code, expires_at) 
                              VALUES (?, ?, ?)";
        $verification_stmt = $database->prepare($verification_query);
        $verification_stmt->bind_param('iss', $user_id, $verification_code, $verification_expiry);
        $verification_stmt->execute();
        
        // إرسال رمز التحقق (يمكن إضافة إرسال SMS هنا)
        // sendSMS($phone, "رمز التحقق الخاص بك هو: $verification_code");
        
        $response['success'] = true;
        $response['message'] = 'تم إنشاء الحساب بنجاح';
        $response['data'] = [
            'user_id' => $user_id,
            'name' => $name,
            'email' => $email,
            'phone' => $phone,
            'role' => $role,
            'verification_code' => $verification_code, // للتطوير فقط
            'service_id' => $service_id,
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