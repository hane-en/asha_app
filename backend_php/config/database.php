<?php
// تفعيل عرض جميع أخطاء PHP
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// إعدادات قاعدة البيانات لـ XAMPP
define('DB_HOST', 'localhost');
define('DB_NAME', 'asha_app');
define('DB_USER', 'root');
define('DB_PASS', ''); // كلمة المرور فارغة في XAMPP الافتراضي
define('DB_CHARSET', 'utf8mb4');

// إنشاء اتصال قاعدة البيانات
function getDBConnection() {
    try {
        $dsn = "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=" . DB_CHARSET;
        $pdo = new PDO($dsn, DB_USER, DB_PASS);
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
        return $pdo;
    } catch (PDOException $e) {
        error_log("Database connection failed: " . $e->getMessage());
        return null;
    }
}

// دالة للتحقق من الاتصال
function testConnection() {
    $pdo = getDBConnection();
    if ($pdo) {
        return true;
    } else {
        return false;
    }
}

// طباعة نتيجة الاتصال بشكل واضح
if (testConnection()) {
    echo "<h2 style='color:green'>Database connection successful!</h2>";
} else {
    echo "<h2 style='color:red'>Database connection failed!</h2>";
}
?> 