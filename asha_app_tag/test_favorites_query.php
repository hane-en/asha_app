<?php
/**
 * اختبار استعلام المفضلة
 */

require_once 'config.php';
require_once 'database.php';

// إيقاف عرض الأخطاء
error_reporting(0);
ini_set('display_errors', 0);

echo "<h2>اختبار استعلام المفضلة</h2>";

try {
    $db = new Database();
    $db->connect();
    echo "✅ الاتصال بقاعدة البيانات نجح<br>";
    
    $userId = 1;
    
    // فحص عدد المفضلات
    $countQuery = "
        SELECT COUNT(*) as total
        FROM favorites f
        LEFT JOIN services s ON f.service_id = s.id
        WHERE f.user_id = :user_id AND s.is_active = 1
    ";
    
    $totalResult = $db->selectOne($countQuery, ['user_id' => $userId]);
    $total = $totalResult['total'];
    echo "<h3>عدد المفضلات: $total</h3>";
    
    // فحص المفضلات بدون JOIN
    $simpleQuery = "
        SELECT * FROM favorites 
        WHERE user_id = :user_id
    ";
    
    $favorites = $db->select($simpleQuery, ['user_id' => $userId]);
    echo "<h3>المفضلات البسيطة:</h3>";
    foreach ($favorites as $favorite) {
        echo "ID: {$favorite['id']} - Service ID: {$favorite['service_id']}<br>";
    }
    
    // فحص الخدمات المرتبطة
    if (!empty($favorites)) {
        $serviceIds = array_column($favorites, 'service_id');
        $serviceIdsStr = implode(',', $serviceIds);
        
        $servicesQuery = "
            SELECT id, title, is_active 
            FROM services 
            WHERE id IN ($serviceIdsStr)
        ";
        
        $services = $db->select($servicesQuery);
        echo "<h3>الخدمات المرتبطة:</h3>";
        foreach ($services as $service) {
            echo "ID: {$service['id']} - {$service['title']} - Active: {$service['is_active']}<br>";
        }
    }
    
    // فحص الاستعلام الكامل
    $fullQuery = "
        SELECT 
            f.id as favorite_id,
            f.created_at as favorited_at,
            s.*,
            c.name as category_name,
            u.name as provider_name
        FROM favorites f
        LEFT JOIN services s ON f.service_id = s.id
        LEFT JOIN categories c ON s.category_id = c.id
        LEFT JOIN users u ON s.provider_id = u.id
        WHERE f.user_id = :user_id AND s.is_active = 1
        ORDER BY f.created_at DESC
        LIMIT 10
    ";
    
    $fullResults = $db->select($fullQuery, ['user_id' => $userId]);
    echo "<h3>النتائج الكاملة:</h3>";
    foreach ($fullResults as $result) {
        echo "Service ID: {$result['id']} - {$result['title']} - Active: {$result['is_active']}<br>";
    }
    
} catch (Exception $e) {
    echo "❌ خطأ: " . $e->getMessage() . "<br>";
}
?> 