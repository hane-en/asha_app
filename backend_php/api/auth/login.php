<?php
// ملاحظة: عند إضافة مستخدم يدوياً يجب أن يكون رقم الهاتف من 9 إلى 15 رقم فقط بدون رموز أو مسافات، وكلمة المرور نص عادي إذا كان التشفير معطل
require_once '../../config/config.php';
require_once '../../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse(['error' => 'Method not allowed'], 405);
}

$input = json_decode(file_get_contents('php://input'), true);

// التحقق من البيانات المطلوبة
if (!isset($input['emailOrPhone']) || !isset($input['password'])) {
    jsonResponse(['error' => 'البريد الإلكتروني أو رقم الهاتف وكلمة المرور مطلوبان'], 400);
}

$login = validateInput($input['emailOrPhone']);
$password = $input['password'];

// التحقق من صحة البيانات
if (!validateEmail($login)) {
    jsonResponse(['error' => 'البريد الإلكتروني غير صالح'], 400);
}

$pdo = getDBConnection();
if (!$pdo) {
    jsonResponse(['error' => 'خطأ في الاتصال بقاعدة البيانات'], 500);
}

try {
    // تحقق هل القيمة بريد إلكتروني أم رقم هاتف
    if (filter_var($login, FILTER_VALIDATE_EMAIL)) {
        $stmt = $pdo->prepare("SELECT id, name, email, phone, password, user_type, is_verified, is_active FROM users WHERE email = ?");
    } else {
        $stmt = $pdo->prepare("SELECT id, name, email, phone, password, user_type, is_verified, is_active FROM users WHERE phone = ?");
    }
    $stmt->execute([$login]);
    $user = $stmt->fetch();
    
    if (!$user) {
        jsonResponse(['error' => 'البريد الإلكتروني أو رقم الهاتف أو كلمة المرور غير صحيحة'], 401);
    }
    
    // التحقق من كلمة المرور
    if (!verifyPassword($password, $user['password'])) {
        jsonResponse(['error' => 'البريد الإلكتروني أو رقم الهاتف أو كلمة المرور غير صحيحة'], 401);
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
    error_log("Login error: " . $e->getMessage());
    jsonResponse(['error' => 'خطأ في تسجيل الدخول'], 500);
}
?> 