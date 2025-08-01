<?php
/**
 * ملف التكوين لقاعدة البيانات
 * Database Configuration File
 */

// =====================================================
// إعدادات قاعدة البيانات
// =====================================================
define('DB_HOST', 'localhost');
define('DB_NAME', 'asha_app_db');
define('DB_USER', 'asha_app');
define('DB_PASS', 'app_password');
define('DB_CHARSET', 'utf8mb4');

// =====================================================
// إعدادات التطبيق
// =====================================================
define('APP_NAME', 'تطبيق خدمات الأحداث');
define('APP_VERSION', '1.0.0');
define('APP_URL', 'http://127.0.0.1/asha_app_h');
define('API_VERSION', 'v1');

// =====================================================
// إعدادات الملفات
// =====================================================
define('UPLOAD_PATH', '../uploads/');
define('MAX_UPLOAD_SIZE', 5242880); // 5MB
define('ALLOWED_IMAGE_TYPES', ['jpg', 'jpeg', 'png', 'webp']);
define('MAX_IMAGES_PER_SERVICE', 10);

// =====================================================
// إعدادات الأمان
// =====================================================
define('JWT_SECRET', 'asha-app-secret-key-2024-change-this-in-production');
define('JWT_EXPIRE', 86400); // 24 hours
define('PASSWORD_SALT', 'asha-app-salt-2024');

// =====================================================
// إعدادات SMS
// =====================================================
define('SMS_API_KEY', 'your-sms-api-key-here');
define('SMS_SENDER', 'ASHA-APP');
define('SMS_ENABLED', false);

// =====================================================
// إعدادات الدفع
// =====================================================
define('PAYMENT_GATEWAY_KEY', 'your-payment-gateway-key');
define('PAYMENT_GATEWAY_SECRET', 'your-payment-gateway-secret');
define('COMMISSION_PERCENTAGE', 10); // 10%

// =====================================================
// إعدادات النظام
// =====================================================
define('MAINTENANCE_MODE', false);
define('DEBUG_MODE', true);
define('LOG_ENABLED', true);
define('LOG_PATH', '../logs/');

// =====================================================
// إعدادات الحجز
// =====================================================
define('BOOKING_ADVANCE_DAYS', 30);
define('AUTO_APPROVE_PROVIDERS', false);
define('REVIEW_AUTO_APPROVE', true);

// =====================================================
// إعدادات CORS
// =====================================================
define('CORS_ENABLED', true);
define('ALLOWED_ORIGINS', [
    'http://localhost:3000',
    'http://127.0.0.1:3000',
    'http://localhost:8080',
    'http://127.0.0.1:8080'
]);

// =====================================================
// دالة الاتصال بقاعدة البيانات
// =====================================================
function getDatabaseConnection() {
    try {
        $dsn = "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=" . DB_CHARSET;
        $pdo = new PDO($dsn, DB_USER, DB_PASS, [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
        ]);
        return $pdo;
    } catch (PDOException $e) {
        error_log("Database connection failed: " . $e->getMessage());
        return null;
    }
}

// =====================================================
// دالة إعداد CORS
// =====================================================
function setupCORS() {
    if (!CORS_ENABLED) return;
    
    $origin = $_SERVER['HTTP_ORIGIN'] ?? '';
    if (in_array($origin, ALLOWED_ORIGINS)) {
        header("Access-Control-Allow-Origin: $origin");
    }
    
    header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
    header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
    header("Access-Control-Allow-Credentials: true");
    
    if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
        http_response_code(200);
        exit();
    }
}

// =====================================================
// دالة التحقق من الصلاحيات
// =====================================================
function checkAuth() {
    $headers = getallheaders();
    $token = $headers['Authorization'] ?? '';
    
    if (empty($token)) {
        return false;
    }
    
    // إزالة "Bearer " من بداية التوكن
    $token = str_replace('Bearer ', '', $token);
    
    try {
        // هنا يمكن إضافة التحقق من JWT
        // decodeJWT($token);
        return true;
    } catch (Exception $e) {
        return false;
    }
}

// =====================================================
// دالة تسجيل الأخطاء
// =====================================================
function logError($message, $context = []) {
    if (!LOG_ENABLED) return;
    
    $logFile = LOG_PATH . 'error_' . date('Y-m-d') . '.log';
    $timestamp = date('Y-m-d H:i:s');
    $logMessage = "[$timestamp] $message" . (!empty($context) ? ' ' . json_encode($context) : '') . PHP_EOL;
    
    if (!is_dir(LOG_PATH)) {
        mkdir(LOG_PATH, 0755, true);
    }
    
    file_put_contents($logFile, $logMessage, FILE_APPEND | LOCK_EX);
}

// =====================================================
// دالة التحقق من نوع الملف
// =====================================================
function isValidImageType($filename) {
    $extension = strtolower(pathinfo($filename, PATHINFO_EXTENSION));
    return in_array($extension, ALLOWED_IMAGE_TYPES);
}

// =====================================================
// دالة تنظيف المدخلات
// =====================================================
function sanitizeInput($input) {
    if (is_array($input)) {
        return array_map('sanitizeInput', $input);
    }
    return htmlspecialchars(trim($input), ENT_QUOTES, 'UTF-8');
}

// =====================================================
// دالة إنشاء استجابة JSON
// =====================================================
function sendJsonResponse($data, $statusCode = 200) {
    http_response_code($statusCode);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($data, JSON_UNESCAPED_UNICODE);
    exit();
}

// =====================================================
// دالة التحقق من وجود الملف
// =====================================================
function fileExists($path) {
    return file_exists($path) && is_file($path);
}

// =====================================================
// دالة إنشاء مجلد الملفات
// =====================================================
function createUploadDirectory() {
    if (!is_dir(UPLOAD_PATH)) {
        mkdir(UPLOAD_PATH, 0755, true);
    }
    
    $subdirs = ['images', 'profiles', 'services', 'ads'];
    foreach ($subdirs as $subdir) {
        $path = UPLOAD_PATH . $subdir . '/';
        if (!is_dir($path)) {
            mkdir($path, 0755, true);
        }
    }
}

// =====================================================
// دالة التحقق من إعدادات النظام
// =====================================================
function checkSystemRequirements() {
    $requirements = [
        'php_version' => version_compare(PHP_VERSION, '7.4.0', '>='),
        'pdo_mysql' => extension_loaded('pdo_mysql'),
        'json' => extension_loaded('json'),
        'mbstring' => extension_loaded('mbstring'),
        'upload_dir_writable' => is_writable(UPLOAD_PATH) || is_writable(dirname(UPLOAD_PATH)),
    ];
    
    return $requirements;
}

// =====================================================
// إعداد CORS عند تحميل الملف
// =====================================================
setupCORS();

// =====================================================
// إنشاء مجلد الملفات
// =====================================================
createUploadDirectory();

// =====================================================
// إعداد معالج الأخطاء
// =====================================================
if (DEBUG_MODE) {
    error_reporting(E_ALL);
    ini_set('display_errors', 1);
} else {
    error_reporting(0);
    ini_set('display_errors', 0);
}

// =====================================================
// إعداد المنطقة الزمنية
// =====================================================
date_default_timezone_set('Asia/Aden');

?> 