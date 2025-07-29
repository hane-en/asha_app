<?php
/**
 * اختبار API المفضلة
 */

require_once 'config.php';
require_once 'database.php';

// إيقاف عرض الأخطاء
error_reporting(0);
ini_set('display_errors', 0);

echo "<h2>اختبار API المفضلة</h2>";

try {
    $db = new Database();
    $db->connect();
    echo "✅ الاتصال بقاعدة البيانات نجح<br>";
    
    // فحص جدول المفضلة
    $favorites = $db->select("DESCRIBE favorites");
    echo "<h3>هيكل جدول المفضلة:</h3>";
    echo "<table border='1'>";
    echo "<tr><th>Field</th><th>Type</th><th>Null</th><th>Key</th><th>Default</th></tr>";
    foreach ($favorites as $field) {
        echo "<tr>";
        echo "<td>{$field['Field']}</td>";
        echo "<td>{$field['Type']}</td>";
        echo "<td>{$field['Null']}</td>";
        echo "<td>{$field['Key']}</td>";
        echo "<td>{$field['Default']}</td>";
        echo "</tr>";
    }
    echo "</table>";
    
    // فحص عدد المفضلات
    $count = $db->selectOne("SELECT COUNT(*) as count FROM favorites");
    echo "<h3>عدد المفضلات: " . ($count['count'] ?? 0) . "</h3>";
    
    // فحص الخدمات
    $services = $db->select("SELECT id, title FROM services LIMIT 3");
    echo "<h3>الخدمات المتاحة:</h3>";
    foreach ($services as $service) {
        echo "ID: {$service['id']} - {$service['title']}<br>";
    }
    
    // فحص المستخدمين
    $users = $db->select("SELECT id, name, email FROM users LIMIT 3");
    echo "<h3>المستخدمين المتاحة:</h3>";
    foreach ($users as $user) {
        echo "ID: {$user['id']} - {$user['name']} ({$user['email']})<br>";
    }
    
    // اختبار إضافة مفضلة
    if (!empty($users) && !empty($services)) {
        $userId = $users[0]['id'];
        $serviceId = $services[0]['id'];
        
        echo "<h3>اختبار إضافة مفضلة:</h3>";
        echo "المستخدم: {$users[0]['name']} (ID: {$userId})<br>";
        echo "الخدمة: {$services[0]['title']} (ID: {$serviceId})<br>";
        
        // فحص إذا كانت المفضلة موجودة
        $existing = $db->selectOne(
            "SELECT id FROM favorites WHERE user_id = :user_id AND service_id = :service_id",
            ['user_id' => $userId, 'service_id' => $serviceId]
        );
        
        if ($existing) {
            echo "❌ المفضلة موجودة مسبقاً<br>";
        } else {
            // إضافة مفضلة
            $favoriteData = [
                'user_id' => $userId,
                'service_id' => $serviceId
            ];
            
            $favoriteId = $db->insert('favorites', $favoriteData);
            
            if ($favoriteId) {
                echo "✅ تم إضافة المفضلة بنجاح! (ID: {$favoriteId})<br>";
            } else {
                echo "❌ فشل في إضافة المفضلة<br>";
            }
        }
    }
    
} catch (Exception $e) {
    echo "❌ خطأ: " . $e->getMessage() . "<br>";
}
?> 