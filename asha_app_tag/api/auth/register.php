<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// التعامل مع طلبات OPTIONS
if (isset($_SERVER['REQUEST_METHOD']) && $_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once '../config/database.php';

// التحقق من أن الطلب هو POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'طريقة الطلب غير مسموحة'], JSON_UNESCAPED_UNICODE);
    exit();
}

// قراءة البيانات المرسلة
$input = json_decode(file_get_contents('php://input'), true);

if (!$input) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'بيانات غير صحيحة'], JSON_UNESCAPED_UNICODE);
    exit();
}

$name = $input['name'] ?? '';
$email = $input['email'] ?? '';
$phone = $input['phone'] ?? '';
$password = $input['password'] ?? '';
$userType = $input['user_type'] ?? 'user';

// التحقق من البيانات المطلوبة
if (empty($name) || empty($email) || empty($password)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'الاسم والبريد الإلكتروني وكلمة المرور مطلوبة'], JSON_UNESCAPED_UNICODE);
    exit();
}

// التحقق من صحة البريد الإلكتروني
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'البريد الإلكتروني غير صحيح'], JSON_UNESCAPED_UNICODE);
    exit();
}

// التحقق من نوع المستخدم
if (!in_array($userType, ['user', 'provider'])) {
    $userType = 'user';
}

try {
    $db = new Database();
    $pdo = $db->getConnection();
    
    if (!$pdo) {
        throw new Exception('فشل في الاتصال بقاعدة البيانات');
    }
    
    // التحقق من وجود البريد الإلكتروني
    $checkStmt = $pdo->prepare("SELECT id FROM users WHERE email = ?");
    $checkStmt->execute([$email]);
    if ($checkStmt->fetch()) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'البريد الإلكتروني مستخدم بالفعل'], JSON_UNESCAPED_UNICODE);
        exit();
    }
    
    // التحقق من وجود رقم الهاتف إذا تم توفيره
    if (!empty($phone)) {
        $checkPhoneStmt = $pdo->prepare("SELECT id FROM users WHERE phone = ?");
        $checkPhoneStmt->execute([$phone]);
        if ($checkPhoneStmt->fetch()) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'رقم الهاتف مستخدم بالفعل'], JSON_UNESCAPED_UNICODE);
            exit();
        }
    }
    
    // تشفير كلمة المرور
    $hashedPassword = password_hash($password, PASSWORD_DEFAULT);
    
    // إنشاء رمز التحقق
    $verificationCode = bin2hex(random_bytes(16));
    
    // إدراج المستخدم الجديد
    $insertStmt = $pdo->prepare("
        INSERT INTO users (name, email, phone, password, user_type, verification_code, created_at) 
        VALUES (?, ?, ?, ?, ?, ?, NOW())
    ");
    
    $result = $insertStmt->execute([$name, $email, $phone, $hashedPassword, $userType, $verificationCode]);
    
    if ($result) {
        $userId = $pdo->lastInsertId();
        
        echo json_encode([
            'success' => true,
            'message' => 'تم إنشاء الحساب بنجاح. يرجى التحقق من بريدك الإلكتروني',
            'data' => [
                'user_id' => $userId,
                'verification_code' => $verificationCode
            ],
            'timestamp' => date('Y-m-d H:i:s')
        ], JSON_UNESCAPED_UNICODE);
    } else {
        throw new Exception('فشل في إنشاء الحساب');
    }
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'خطأ في الخادم: ' . $e->getMessage(),
        'timestamp' => date('Y-m-d H:i:s')
    ], JSON_UNESCAPED_UNICODE);
}
?>

