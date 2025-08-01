<?php
/**
 * ملف التكوين لمجلد API
 */

// إعدادات قاعدة البيانات
define('DB_HOST', '127.0.0.1');
define('DB_NAME', 'asha_app_events');
define('DB_USER', 'root');
define('DB_PASS', '');
define('DB_CHARSET', 'utf8mb4');

// إعدادات الأمان
define('JWT_SECRET', 'your-secret-key-here-change-in-production');
define('JWT_ALGORITHM', 'HS256');
define('JWT_EXPIRATION', 86400); // 24 ساعة

// إعدادات التطبيق
define('APP_NAME', 'Asha App');
define('APP_VERSION', '1.0.0');
define('API_VERSION', 'v1');

// إعدادات الملفات
define('UPLOAD_PATH', 'uploads/');
define('MAX_FILE_SIZE', 5 * 1024 * 1024); // 5MB
define('ALLOWED_IMAGE_TYPES', ['jpg', 'jpeg', 'png', 'gif']);

// إعدادات التطبيق
define('DEFAULT_TIMEZONE', 'Asia/Aden');
define('DEFAULT_LANGUAGE', 'ar');
define('PAGINATION_LIMIT', 20);

// إعدادات الأخطاء
error_reporting(E_ALL);
ini_set('display_errors', 1);

// تعيين المنطقة الزمنية
date_default_timezone_set(DEFAULT_TIMEZONE);

// إعدادات CORS - فقط إذا لم يتم إرسال headers بعد
if (!headers_sent()) {
    header('Access-Control-Allow-Origin: *');
    header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
    header('Content-Type: application/json; charset=utf-8');
}

// التعامل مع طلبات OPTIONS
if (isset($_SERVER['REQUEST_METHOD']) && $_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

// دالة لإرجاع استجابة JSON
function jsonResponse($data, $status = 200) {
    http_response_code($status);
    echo json_encode($data, JSON_UNESCAPED_UNICODE);
    exit();
}

// دالة لإرجاع رسالة خطأ
function errorResponse($message, $status = 400) {
    jsonResponse([
        'success' => false,
        'message' => $message,
        'timestamp' => date('Y-m-d H:i:s')
    ], $status);
}

// دالة لإرجاع رسالة نجاح
function successResponse($data = null, $message = 'تمت العملية بنجاح') {
    $response = [
        'success' => true,
        'message' => $message,
        'timestamp' => date('Y-m-d H:i:s')
    ];
    
    if ($data !== null) {
        $response['data'] = $data;
    }
    
    jsonResponse($response);
}

// دالة لتسجيل الأخطاء
function logError($message, $file = 'error.log') {
    $timestamp = date('Y-m-d H:i:s');
    $logMessage = "[$timestamp] $message" . PHP_EOL;
    file_put_contents($file, $logMessage, FILE_APPEND | LOCK_EX);
}

// دالة لتنظيف البيانات
function sanitizeInput($data) {
    if (is_array($data)) {
        return array_map('sanitizeInput', $data);
    }
    return htmlspecialchars(strip_tags(trim($data)), ENT_QUOTES, 'UTF-8');
}

// دالة لتوليد كود التحقق
function generateVerificationCode($length = 6) {
    return str_pad(random_int(0, pow(10, $length) - 1), $length, '0', STR_PAD_LEFT);
}

// دالة لتشفير كلمة المرور
function hashPassword($password) {
    return password_hash($password, PASSWORD_DEFAULT);
}

// دالة للتحقق من كلمة المرور
function verifyPassword($password, $hash) {
    return password_verify($password, $hash);
}

// دالة لتوليد رمز عشوائي
function generateRandomString($length = 32) {
    return bin2hex(random_bytes($length / 2));
}
?> 