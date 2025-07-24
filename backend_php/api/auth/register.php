<?php
// ملاحظة: عند إضافة مستخدم يدوياً يجب أن يكون رقم الهاتف من 9 إلى 15 رقم فقط بدون رموز أو مسافات، وكلمة المرور نص عادي إذا كان التشفير معطل
require_once '../../config/config.php';
require_once '../../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse(['error' => 'Method not allowed'], 405);
}

$input = json_decode(file_get_contents('php://input'), true);

// التحقق من البيانات المطلوبة
if (!isset($input['name']) || !isset($input['email']) || !isset($input['phone']) || !isset($input['password'])) {
    jsonResponse(['error' => 'جميع الحقول مطلوبة'], 400);
}

$name = validateInput($input['name']);
$email = validateInput($input['email']);
$phone = validateInput($input['phone']);
error_log('رقم الهاتف قبل التحقق: ' . $phone);
$password = $input['password'];

// التحقق من صحة البيانات
if (strlen($name) < 2) {
    jsonResponse(['error' => 'الاسم يجب أن يكون أكثر من حرفين'], 400);
}

if (!validateEmail($email)) {
    jsonResponse(['error' => 'البريد الإلكتروني غير صالح'], 400);
}

if (!validatePhone($phone)) {
    // jsonResponse(['error' => 'رقم الهاتف غير صالح'], 400);
    // السماح مؤقتاً بأي رقم هاتف
}

if (strlen($password) < 8) {
    jsonResponse(['error' => 'كلمة المرور يجب أن تكون 8 أحرف على الأقل'], 400);
}

$pdo = getDBConnection();
if (!$pdo) {
    jsonResponse(['error' => 'خطأ في الاتصال بقاعدة البيانات'], 500);
}

try {
    // التحقق من عدم وجود البريد الإلكتروني
    $stmt = $pdo->prepare("SELECT id FROM users WHERE email = ?");
    $stmt->execute([$email]);
    if ($stmt->fetch()) {
        jsonResponse(['success' => false, 'message' => 'البريد الإلكتروني مستخدم بالفعل. إذا كان لديك حساب يمكنك تسجيل الدخول مباشرة.'], 400);
    }
    
    // التحقق من عدم وجود رقم الهاتف
    $stmt = $pdo->prepare("SELECT id FROM users WHERE phone = ?");
    $stmt->execute([$phone]);
    if ($stmt->fetch()) {
        jsonResponse(['success' => false, 'message' => 'رقم الهاتف مستخدم بالفعل. إذا كان لديك حساب يمكنك تسجيل الدخول مباشرة.'], 400);
    }
    
    // إنشاء المستخدم
    $hashedPassword = hashPassword($password);
    $stmt = $pdo->prepare("INSERT INTO users (name, email, phone, password) VALUES (?, ?, ?, ?)");
    $stmt->execute([$name, $email, $phone, $hashedPassword]);
    
    $userId = $pdo->lastInsertId();
    
    // إنشاء token
    $userData = [
        'id' => $userId,
        'email' => $email,
        'user_type' => 'user'
    ];
    $token = createToken($userData);
    
    jsonResponse([
        'success' => true,
        'message' => 'تم التسجيل بنجاح',
        'token' => $token,
        'user' => [
            'id' => $userId,
            'name' => $name,
            'email' => $email,
            'phone' => $phone,
            'user_type' => 'user'
        ]
    ]);
    
} catch (PDOException $e) {
    error_log("Registration error: " . $e->getMessage());
    jsonResponse(['error' => 'خطأ في التسجيل'], 500);
}
?> 