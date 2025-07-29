<?php
/**
 * اختبار جدول المفضلة
 */

require_once 'config.php';
require_once 'database.php';

// إيقاف عرض الأخطاء
error_reporting(0);
ini_set('display_errors', 0);

echo "<h2>اختبار جدول المفضلة</h2>";

try {
    $db = new Database();
    $db->connect();
    echo "✅ الاتصال بقاعدة البيانات نجح<br>";
    
    // فحص وجود جدول المفضلة
    $tables = $db->select("SHOW TABLES LIKE 'favorites'");
    if (empty($tables)) {
        echo "❌ جدول المفضلة غير موجود<br>";
        
        // إنشاء جدول المفضلة
        $createTable = "CREATE TABLE favorites (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT NOT NULL,
            service_id INT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            UNIQUE KEY unique_user_service (user_id, service_id),
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
            FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE
        )";
        
        if ($db->execute($createTable)) {
            echo "✅ تم إنشاء جدول المفضلة بنجاح<br>";
        } else {
            echo "❌ فشل في إنشاء جدول المفضلة<br>";
        }
    } else {
        echo "✅ جدول المفضلة موجود<br>";
    }
    
    // فحص هيكل جدول المفضلة
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
    
    // فحص عدد المفضلات الحالية
    $count = $db->selectOne("SELECT COUNT(*) as count FROM favorites");
    echo "<h3>عدد المفضلات الحالية: " . ($count['count'] ?? 0) . "</h3>";
    
    // فحص الخدمات المتاحة
    $services = $db->select("SELECT id, title FROM services LIMIT 5");
    echo "<h3>الخدمات المتاحة:</h3>";
    foreach ($services as $service) {
        echo "ID: {$service['id']} - {$service['title']}<br>";
    }
    
    // فحص المستخدمين المتاحة
    $users = $db->select("SELECT id, name, email FROM users LIMIT 5");
    echo "<h3>المستخدمين المتاحة:</h3>";
    foreach ($users as $user) {
        echo "ID: {$user['id']} - {$user['name']} ({$user['email']})<br>";
    }
    
} catch (Exception $e) {
    echo "❌ خطأ: " . $e->getMessage() . "<br>";
}
?> 