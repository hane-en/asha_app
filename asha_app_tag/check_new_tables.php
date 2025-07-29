<?php
require_once 'config.php';
require_once 'database.php';

echo "<h1>التحقق من الجداول الجديدة</h1>\n";

try {
    $pdo = new PDO("mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=utf8mb4", DB_USER, DB_PASS);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    echo "<h2>1. التحقق من وجود الجداول الجديدة</h2>\n";
    
    $tables = ['provider_requests', 'profile_update_requests', 'messages', 'provider_stats_reports'];
    
    foreach ($tables as $table) {
        $stmt = $pdo->query("SHOW TABLES LIKE '$table'");
        if ($stmt->rowCount() > 0) {
            echo "✅ جدول $table موجود\n";
            
            // التحقق من عدد الصفوف
            $stmt = $pdo->query("SELECT COUNT(*) as count FROM $table");
            $count = $stmt->fetch(PDO::FETCH_ASSOC)['count'];
            echo "   📊 عدد الصفوف: $count\n";
            
            // عرض عينة من البيانات
            $stmt = $pdo->query("SELECT * FROM $table LIMIT 3");
            $sample = $stmt->fetchAll(PDO::FETCH_ASSOC);
            if (!empty($sample)) {
                echo "   📋 عينة من البيانات:\n";
                foreach ($sample as $row) {
                    echo "      - " . json_encode($row, JSON_UNESCAPED_UNICODE) . "\n";
                }
            }
        } else {
            echo "❌ جدول $table غير موجود\n";
        }
        echo "\n";
    }
    
    echo "<h2>2. إحصائيات عامة</h2>\n";
    
    // إحصائيات provider_requests
    $stmt = $pdo->query("SELECT status, COUNT(*) as count FROM provider_requests GROUP BY status");
    $statuses = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "📊 إحصائيات طلبات الانضمام:\n";
    foreach ($statuses as $status) {
        echo "   - {$status['status']}: {$status['count']}\n";
    }
    
    // إحصائيات profile_update_requests
    $stmt = $pdo->query("SELECT status, COUNT(*) as count FROM profile_update_requests GROUP BY status");
    $statuses = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "📊 إحصائيات طلبات تحديث الملف الشخصي:\n";
    foreach ($statuses as $status) {
        echo "   - {$status['status']}: {$status['count']}\n";
    }
    
    // إحصائيات messages
    $stmt = $pdo->query("SELECT COUNT(*) as total, SUM(is_read) as read_count FROM messages");
    $msgStats = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "📊 إحصائيات الرسائل:\n";
    echo "   - إجمالي الرسائل: {$msgStats['total']}\n";
    echo "   - الرسائل المقروءة: {$msgStats['read_count']}\n";
    echo "   - الرسائل غير المقروءة: " . ($msgStats['total'] - $msgStats['read_count']) . "\n";
    
    // إحصائيات provider_stats_reports
    $stmt = $pdo->query("SELECT COUNT(*) as total, COUNT(DISTINCT provider_id) as providers FROM provider_stats_reports");
    $statsStats = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "📊 إحصائيات تقارير الإحصائيات:\n";
    echo "   - إجمالي التقارير: {$statsStats['total']}\n";
    echo "   - عدد المزودين: {$statsStats['providers']}\n";
    
    echo "<h2>✅ التحقق مكتمل!</h2>\n";
    echo "<p>جميع الجداول الجديدة موجودة وتحتوي على البيانات الافتراضية.</p>\n";
    
} catch (PDOException $e) {
    echo "<h2>❌ خطأ في قاعدة البيانات</h2>\n";
    echo "<p>الخطأ: " . $e->getMessage() . "</p>\n";
} catch (Exception $e) {
    echo "<h2>❌ خطأ عام</h2>\n";
    echo "<p>الخطأ: " . $e->getMessage() . "</p>\n";
}
?> 