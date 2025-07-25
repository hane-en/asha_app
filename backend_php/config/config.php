<?php
// إعدادات التطبيق
define('APP_NAME', 'Asha Services');
define('APP_VERSION', '1.0.0');
define('APP_URL', 'http://localhost/backend_php');

// إعدادات JWT
define('JWT_SECRET', 'your-secret-key-here-change-in-production');
define('JWT_EXPIRE', 86400); // 24 ساعة

// إعدادات CORS
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
header('Content-Type: application/json; charset=utf-8');

// معالجة طلبات OPTIONS
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

// دالة للرد بالـ JSON
function jsonResponse($data, $status = 200) {
    http_response_code($status);
    echo json_encode($data, JSON_UNESCAPED_UNICODE);
    exit();
}

// دالة للتحقق من الـ token
function verifyToken() {
    $headers = getallheaders();
    $token = null;
    
    if (isset($headers['Authorization'])) {
        $token = str_replace('Bearer ', '', $headers['Authorization']);
    }
    
    if (!$token) {
        jsonResponse(['error' => 'Token مطلوب'], 401);
    }
    
    try {
        $decoded = JWT::decode($token, JWT_SECRET, array('HS256'));
        return $decoded;
    } catch (Exception $e) {
        jsonResponse(['error' => 'Token غير صالح'], 401);
    }
}

// دالة لإنشاء JWT token
function createToken($userData) {
    $payload = [
        'user_id' => $userData['id'],
        'email' => $userData['email'],
        'user_type' => $userData['user_type'],
        'iat' => time(),
        'exp' => time() + JWT_EXPIRE
    ];
    
    return JWT::encode($payload, JWT_SECRET, 'HS256');
}

// دالة للتحقق من صحة البيانات
function validateInput($data) {
    $data = trim($data);
    $data = stripslashes($data);
    $data = htmlspecialchars($data);
    return $data;
}

// دالة للتحقق من صحة البريد الإلكتروني
function validateEmail($email) {
    return filter_var($email, FILTER_VALIDATE_EMAIL);
}

function convertArabicNumbers($number) {
    $arabic = ['٠','١','٢','٣','٤','٥','٦','٧','٨','٩'];
    $english = ['0','1','2','3','4','5','6','7','8','9'];
    return str_replace($arabic, $english, $number);
}

function validatePhone($phone) {
    $phone = convertArabicNumbers($phone);
    $phone = preg_replace('/[^0-9]/', '', $phone);
    // قبول فقط رقم مكون من 9 أرقام
    return preg_match('/^[0-9]{9}$/', $phone);
}

// دالة لإنشاء كلمة مرور مشفرة
function hashPassword($password) {
    // بدون تشفير مؤقتًا
    return $password;
}

// دالة للتحقق من كلمة المرور
function verifyPassword($password, $hash) {
    // تحقق مباشر بدون تشفير مؤقتًا
    return $password === $hash;
}

// دالة لرفع الصور
function uploadImage($file, $folder = 'uploads/') {
    $target_dir = $folder;
    if (!file_exists($target_dir)) {
        mkdir($target_dir, 0777, true);
    }
    
    $file_extension = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
    $allowed_extensions = ['jpg', 'jpeg', 'png', 'gif'];
    
    if (!in_array($file_extension, $allowed_extensions)) {
        return false;
    }
    
    $file_name = uniqid() . '.' . $file_extension;
    $target_file = $target_dir . $file_name;
    
    if (move_uploaded_file($file['tmp_name'], $target_file)) {
        return $file_name;
    }
    
    return false;
}

// دالة لحذف الصور
function deleteImage($filename, $folder = 'uploads/') {
    $file_path = $folder . $filename;
    if (file_exists($file_path)) {
        unlink($file_path);
        return true;
    }
    return false;
}

// دالة للتحقق من صلاحيات المستخدم
function checkUserPermission($requiredType) {
    $token = verifyToken();
    if ($token->user_type !== $requiredType && $token->user_type !== 'admin') {
        jsonResponse(['error' => 'ليس لديك صلاحية للوصول لهذا المورد'], 403);
    }
    return $token;
}

// دالة للتحقق من أن المستخدم هو نفسه أو admin
function checkOwnership($userId) {
    $token = verifyToken();
    if ($token->user_id != $userId && $token->user_type !== 'admin') {
        jsonResponse(['error' => 'ليس لديك صلاحية للوصول لهذا المورد'], 403);
    }
    return $token;
}
?> 