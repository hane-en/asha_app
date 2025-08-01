r<?php
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

$email = $input['email'] ?? '';
$password = $input['password'] ?? '';

if (empty($email) || empty($password)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'البريد الإلكتروني وكلمة المرور مطلوبان'], JSON_UNESCAPED_UNICODE);
    exit();
}

try {
    $db = new Database();
    $pdo = $db->getConnection();
    
    if (!$pdo) {
        throw new Exception('فشل في الاتصال بقاعدة البيانات');
    }
    
    // البحث عن المستخدم
    $stmt = $pdo->prepare("SELECT * FROM users WHERE email = ? AND is_active = 1");
    $stmt->execute([$email]);
    $user = $stmt->fetch();
    
    if (!$user) {
        http_response_code(401);
        echo json_encode(['success' => false, 'message' => 'البريد الإلكتروني أو كلمة المرور غير صحيحة'], JSON_UNESCAPED_UNICODE);
        exit();
    }
    
    // التحقق من كلمة المرور
    if (!password_verify($password, $user['password'])) {
        http_response_code(401);
        echo json_encode(['success' => false, 'message' => 'البريد الإلكتروني أو كلمة المرور غير صحيحة'], JSON_UNESCAPED_UNICODE);
        exit();
    }
    
    // التحقق من التحقق من الحساب
    if (!$user['is_verified']) {
        http_response_code(401);
        echo json_encode(['success' => false, 'message' => 'يرجى التحقق من حسابك أولاً'], JSON_UNESCAPED_UNICODE);
        exit();
    }
    
    // تحديث آخر تسجيل دخول
    $updateStmt = $pdo->prepare("UPDATE users SET last_login_at = NOW() WHERE id = ?");
    $updateStmt->execute([$user['id']]);
    
    // إزالة كلمة المرور من البيانات المرسلة
    unset($user['password']);
    
    // تحويل أنواع البيانات
    $user['id'] = (int)$user['id'];
    $user['is_active'] = (bool)$user['is_active'];
    $user['is_verified'] = (bool)$user['is_verified'];
    $user['is_yemeni_account'] = (bool)$user['is_yemeni_account'];
    $user['rating'] = (float)$user['rating'];
    $user['review_count'] = (int)$user['review_count'];
    $user['latitude'] = $user['latitude'] ? (float)$user['latitude'] : null;
    $user['longitude'] = $user['longitude'] ? (float)$user['longitude'] : null;
    
    echo json_encode([
        'success' => true,
        'message' => 'تم تسجيل الدخول بنجاح',
        'data' => $user,
        'timestamp' => date('Y-m-d H:i:s')
    ], JSON_UNESCAPED_UNICODE);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'خطأ في الخادم: ' . $e->getMessage(),
        'timestamp' => date('Y-m-d H:i:s')
    ], JSON_UNESCAPED_UNICODE);
}
?>

