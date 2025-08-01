<?php
// إنشاء قاعدة البيانات
$host = 'localhost';
$username = 'root';
$password = '';

try {
    // الاتصال بـ MySQL بدون تحديد قاعدة بيانات
    $pdo = new PDO("mysql:host=$host", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
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
        if (!empty($statement)) {
            try {
                $pdo->exec($statement);
                echo "تم تنفيذ الأمر بنجاح\n";
            } catch (PDOException $e) {
                // تجاهل الأخطاء المتعلقة بإنشاء قاعدة البيانات إذا كانت موجودة
                if (!strpos($e->getMessage(), 'database exists')) {
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