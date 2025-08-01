<?php
// تنظيف قاعدة البيانات
$host = 'localhost';
$username = 'root';
$password = '';

try {
    // الاتصال بـ MySQL
    $pdo = new PDO("mysql:host=$host", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // حذف قاعدة البيانات إذا كانت موجودة
    $pdo->exec("DROP DATABASE IF EXISTS asha_app_events");
    echo "تم حذف قاعدة البيانات القديمة\n";
    
    // إنشاء قاعدة البيانات من جديد
    $pdo->exec("CREATE DATABASE asha_app_events CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");
    echo "تم إنشاء قاعدة البيانات الجديدة\n";
    
    // اختيار قاعدة البيانات
    $pdo->exec("USE asha_app_events");
    
    // قراءة ملف SQL
    $sqlFile = __DIR__ . '/database_complete_final.sql';
    $sql = file_get_contents($sqlFile);
    
    if ($sql === false) {
        throw new Exception("لا يمكن قراءة ملف قاعدة البيانات");
    }
    
    // تقسيم SQL إلى أوامر منفصلة
    $statements = explode(';', $sql);
    
    foreach ($statements as $statement) {
        $statement = trim($statement);
        if (!empty($statement) && !preg_match('/^--/', $statement)) {
            try {
                $pdo->exec($statement);
                echo "تم تنفيذ الأمر بنجاح\n";
            } catch (PDOException $e) {
                // تجاهل بعض الأخطاء المتوقعة
                if (!strpos($e->getMessage(), 'Duplicate') && 
                    !strpos($e->getMessage(), 'already exists')) {
                    echo "خطأ في تنفيذ الأمر: " . $e->getMessage() . "\n";
                }
            }
        }
    }
    
    echo "تم إنشاء قاعدة البيانات بنجاح!\n";
    
} catch(PDOException $e) {
    echo "خطأ في الاتصال: " . $e->getMessage() . "\n";
} catch(Exception $e) {
    echo "خطأ: " . $e->getMessage() . "\n";
}
?> 