<?php
// ملف تثبيت قاعدة البيانات
require_once 'config/database.php';

echo "<h1>تثبيت قاعدة البيانات - Asha Services</h1>";

try {
    // إنشاء اتصال بدون تحديد قاعدة البيانات
    $pdo = new PDO("mysql:host=" . DB_HOST . ";charset=" . DB_CHARSET, DB_USER, DB_PASS);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    echo "<p>✓ تم الاتصال بقاعدة البيانات بنجاح</p>";
    
    // إنشاء قاعدة البيانات
    $sql = "CREATE DATABASE IF NOT EXISTS " . DB_NAME . " CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci";
    $pdo->exec($sql);
    echo "<p>✓ تم إنشاء قاعدة البيانات: " . DB_NAME . "</p>";
    
    // الاتصال بقاعدة البيانات الجديدة
    $pdo = new PDO("mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=" . DB_CHARSET, DB_USER, DB_PASS);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // قراءة ملف SQL
    $sqlFile = file_get_contents('database/create_database.sql');
    
    // تقسيم الملف إلى أوامر منفصلة
    $statements = explode(';', $sqlFile);
    
    foreach ($statements as $statement) {
        $statement = trim($statement);
        if (!empty($statement) && !str_starts_with($statement, '--')) {
            try {
                $pdo->exec($statement);
                echo "<p>✓ تم تنفيذ: " . substr($statement, 0, 50) . "...</p>";
            } catch (PDOException $e) {
                if (strpos($e->getMessage(), 'already exists') === false) {
                    echo "<p style='color: red;'>✗ خطأ: " . $e->getMessage() . "</p>";
                } else {
                    echo "<p>✓ الجدول موجود بالفعل</p>";
                }
            }
        }
    }
    
    echo "<h2>✓ تم تثبيت قاعدة البيانات بنجاح!</h2>";
    echo "<p>يمكنك الآن استخدام التطبيق.</p>";
    echo "<p><strong>بيانات تسجيل دخول المدير الافتراضية:</strong></p>";
    echo "<ul>";
    echo "<li>البريد الإلكتروني: admin@asha.com</li>";
    echo "<li>كلمة المرور: password</li>";
    echo "</ul>";
    echo "<p><strong>تحذير:</strong> يرجى تغيير كلمة مرور المدير بعد تسجيل الدخول لأول مرة.</p>";
    
} catch (PDOException $e) {
    echo "<p style='color: red;'>✗ خطأ في الاتصال بقاعدة البيانات: " . $e->getMessage() . "</p>";
    echo "<p>يرجى التحقق من إعدادات قاعدة البيانات في ملف config/database.php</p>";
}
?> 