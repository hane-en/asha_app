<?php
/**
 * اختبار database->select
 */

require_once 'config.php';
require_once 'database.php';

// إيقاف عرض الأخطاء
error_reporting(0);
ini_set('display_errors', 0);

echo "<h2>اختبار database->select</h2>";

try {
    $db = new Database();
    $db->connect();
    echo "✅ الاتصال بقاعدة البيانات نجح<br>";
    
    $userId = 1;
    
    // اختبار استعلام بسيط
    $simpleQuery = "SELECT * FROM favorites WHERE user_id = :user_id";
    $simpleResults = $db->select($simpleQuery, ['user_id' => $userId]);
    echo "<h3>النتائج البسيطة:</h3>";
    echo "عدد النتائج: " . count($simpleResults) . "<br>";
    foreach ($simpleResults as $result) {
        echo "ID: {$result['id']} - Service ID: {$result['service_id']}<br>";
    }
    
    // اختبار استعلام مع JOIN
    $joinQuery = "
        SELECT f.id, s.title, s.is_active 
        FROM favorites f
        LEFT JOIN services s ON f.service_id = s.id
        WHERE f.user_id = :user_id
    ";
    $joinResults = $db->select($joinQuery, ['user_id' => $userId]);
    echo "<h3>النتائج مع JOIN:</h3>";
    echo "عدد النتائج: " . count($joinResults) . "<br>";
    foreach ($joinResults as $result) {
        echo "ID: {$result['id']} - {$result['title']} - Active: {$result['is_active']}<br>";
    }
    
    // اختبار استعلام كامل
    $fullQuery = "
        SELECT 
            f.id as favorite_id,
            s.*,
            c.name as category_name,
            u.name as provider_name
        FROM favorites f
        LEFT JOIN services s ON f.service_id = s.id
        LEFT JOIN categories c ON s.category_id = c.id
        LEFT JOIN users u ON s.provider_id = u.id
        WHERE f.user_id = :user_id AND s.is_active = 1
    ";
    $fullResults = $db->select($fullQuery, ['user_id' => $userId]);
    echo "<h3>النتائج الكاملة:</h3>";
    echo "عدد النتائج: " . count($fullResults) . "<br>";
    foreach ($fullResults as $result) {
        echo "Service ID: {$result['id']} - {$result['title']} - Active: {$result['is_active']}<br>";
    }
    
} catch (Exception $e) {
    echo "❌ خطأ: " . $e->getMessage() . "<br>";
}
?> 