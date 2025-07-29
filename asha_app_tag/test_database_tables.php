<?php
require_once 'config.php';
require_once 'database.php';

echo "<h1>اختبار قاعدة البيانات</h1>\n";

try {
    $pdo = new PDO("mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=utf8mb4", DB_USER, DB_PASS);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    echo "✅ الاتصال بقاعدة البيانات نجح\n";
    
    // التحقق من الجداول
    $tables = ['users', 'services', 'ads', 'bookings', 'reviews', 'provider_requests', 'profile_update_requests', 'messages', 'provider_stats_reports'];
    
    foreach ($tables as $table) {
        $stmt = $pdo->query("SHOW TABLES LIKE '$table'");
        if ($stmt->rowCount() > 0) {
            $count_stmt = $pdo->query("SELECT COUNT(*) as count FROM $table");
            $count = $count_stmt->fetch(PDO::FETCH_ASSOC)['count'];
            echo "✅ جدول $table موجود - عدد الصفوف: $count\n";
            
            // عرض عينة من البيانات
            if ($count > 0) {
                $sample_stmt = $pdo->query("SELECT * FROM $table LIMIT 1");
                $sample = $sample_stmt->fetch(PDO::FETCH_ASSOC);
                echo "   عينة: " . json_encode($sample, JSON_UNESCAPED_UNICODE) . "\n";
            }
        } else {
            echo "❌ جدول $table غير موجود\n";
        }
    }
    
} catch (Exception $e) {
    echo "❌ خطأ: " . $e->getMessage() . "\n";
}
?> 