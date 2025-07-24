<?php
require_once '../../config/config.php';
require_once '../../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse(['error' => 'Method not allowed'], 405);
}

$input = json_decode(file_get_contents('php://input'), true);

// التحقق من البيانات المطلوبة
if (!isset($input['email']) || !isset($input['password'])) {
    jsonResponse(['error' => 'البريد الإلكتروني وكلمة المرور مطلوبان'], 400);
}

$email = validateInput($input['email']);
$password = $input['password'];

// التحقق من صحة البيانات
if (!validateEmail($email)) {
    jsonResponse(['error' => 'البريد الإلكتروني غير صالح'], 400);
}

$pdo = getDBConnection();
if (!$pdo) {
    jsonResponse(['error' => 'خطأ في الاتصال بقاعدة البيانات'], 500);
}

try {
    // البحث عن المستخدم (admin فقط)
    $stmt = $pdo->prepare("SELECT id, name, email, phone, password, user_type, is_verified, is_active FROM users WHERE email = ? AND user_type = 'admin'");
    $stmt->execute([$email]);
    $user = $stmt->fetch();
    
    if (!$user) {
        jsonResponse(['error' => 'البريد الإلكتروني أو كلمة المرور غير صحيحة'], 401);
    }
    
    // التحقق من كلمة المرور
    if (!verifyPassword($password, $user['password'])) {
        jsonResponse(['error' => 'البريد الإلكتروني أو كلمة المرور غير صحيحة'], 401);
    }
    
    // التحقق من حالة الحساب
    if (!$user['is_active']) {
        jsonResponse(['error' => 'الحساب معطل'], 403);
    }
    
    // إنشاء token
    $userData = [
        'id' => $user['id'],
        'email' => $user['email'],
        'user_type' => $user['user_type']
    ];
    $token = createToken($userData);
    
    jsonResponse([
        'success' => true,
        'message' => 'تم تسجيل الدخول بنجاح',
        'token' => $token,
        'user' => [
            'id' => $user['id'],
            'name' => $user['name'],
            'email' => $user['email'],
            'phone' => $user['phone'],
            'user_type' => $user['user_type'],
            'is_verified' => $user['is_verified']
        ]
    ]);
    
} catch (PDOException $e) {
    error_log("Admin login error: " . $e->getMessage());
    jsonResponse(['error' => 'خطأ في تسجيل الدخول'], 500);
}
?> 