<?php
/**
 * اختبار API المفضلة بدون مصادقة
 */

require_once 'config.php';
require_once 'database.php';

// إيقاف عرض الأخطاء
error_reporting(0);
ini_set('display_errors', 0);

echo "<h2>اختبار API المفضلة بدون مصادقة</h2>";

try {
    $db = new Database();
    $db->connect();
    echo "✅ الاتصال بقاعدة البيانات نجح<br>";
    
    // محاكاة بيانات المستخدم (للتجربة فقط)
    $userId = 1; // Admin User
    
    // فحص الخدمات
    $services = $db->select("SELECT id, title FROM services LIMIT 3");
    echo "<h3>الخدمات المتاحة:</h3>";
    foreach ($services as $service) {
        echo "ID: {$service['id']} - {$service['title']}<br>";
    }
    
    if (!empty($services)) {
        $serviceId = $services[0]['id'];
        
        echo "<h3>اختبار إضافة مفضلة:</h3>";
        echo "المستخدم: Admin User (ID: {$userId})<br>";
        echo "الخدمة: {$services[0]['title']} (ID: {$serviceId})<br>";
        
        // فحص إذا كانت المفضلة موجودة
        $existing = $db->selectOne(
            "SELECT id FROM favorites WHERE user_id = :user_id AND service_id = :service_id",
            ['user_id' => $userId, 'service_id' => $serviceId]
        );
        
        if ($existing) {
            echo "❌ المفضلة موجودة مسبقاً<br>";
            
            // إزالة المفضلة
            $deleted = $db->delete(
                'favorites',
                'user_id = :user_id AND service_id = :service_id',
                ['user_id' => $userId, 'service_id' => $serviceId]
            );
            
            if ($deleted) {
                echo "✅ تم إزالة المفضلة بنجاح!<br>";
            } else {
                echo "❌ فشل في إزالة المفضلة<br>";
            }
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
    
    // فحص عدد المفضلات بعد التحديث
    $count = $db->selectOne("SELECT COUNT(*) as count FROM favorites");
    echo "<h3>عدد المفضلات بعد التحديث: " . ($count['count'] ?? 0) . "</h3>";
    
} catch (Exception $e) {
    echo "❌ خطأ: " . $e->getMessage() . "<br>";
}
?> 