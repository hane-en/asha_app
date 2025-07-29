<?php
/**
 * اختبار نهائي لـ API المفضلة الجديد
 */

require_once 'config.php';
require_once 'database.php';

// إيقاف عرض الأخطاء
error_reporting(0);
ini_set('display_errors', 0);

echo "<h2>اختبار API المفضلة الجديد</h2>";

try {
    $db = new Database();
    $db->connect();
    echo "✅ الاتصال بقاعدة البيانات نجح<br>";
    
    // محاكاة طلب POST
    $input = [
        'user_id' => 1,
        'service_id' => 4
    ];
    
    $serviceId = (int)$input['service_id'];
    $userId = (int)$input['user_id'];
    
    echo "<h3>اختبار إضافة مفضلة:</h3>";
    echo "المستخدم ID: {$userId}<br>";
    echo "الخدمة ID: {$serviceId}<br>";
    
    // التحقق من وجود الخدمة
    $service = $db->selectOne(
        "SELECT id, title FROM services WHERE id = :id AND is_active = 1",
        ['id' => $serviceId]
    );

    if (!$service) {
        echo "❌ الخدمة غير موجودة<br>";
        exit;
    }
    
    echo "✅ الخدمة موجودة: {$service['title']}<br>";
    
    // التحقق من وجود المستخدم
    $user = $db->selectOne(
        "SELECT id, name FROM users WHERE id = :id",
        ['id' => $userId]
    );

    if (!$user) {
        echo "❌ المستخدم غير موجود<br>";
        exit;
    }
    
    echo "✅ المستخدم موجود: {$user['name']}<br>";
    
    // التحقق من وجود المفضلة
    $existingFavorite = $db->selectOne(
        "SELECT id FROM favorites WHERE user_id = :user_id AND service_id = :service_id",
        ['user_id' => $userId, 'service_id' => $serviceId]
    );

    if ($existingFavorite) {
        echo "❌ المفضلة موجودة مسبقاً<br>";
        
        // إزالة من المفضلة
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
        echo "✅ المفضلة غير موجودة، سيتم إضافتها<br>";
        
        // إضافة إلى المفضلة
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
    
    // فحص عدد المفضلات بعد التحديث
    $count = $db->selectOne("SELECT COUNT(*) as count FROM favorites");
    echo "<h3>عدد المفضلات بعد التحديث: " . ($count['count'] ?? 0) . "</h3>";
    
    // فحص مفضلات المستخدم
    $userFavorites = $db->select(
        "SELECT f.id, s.title FROM favorites f 
         JOIN services s ON f.service_id = s.id 
         WHERE f.user_id = :user_id",
        ['user_id' => $userId]
    );
    
    echo "<h3>مفضلات المستخدم:</h3>";
    foreach ($userFavorites as $favorite) {
        echo "- {$favorite['title']} (ID: {$favorite['id']})<br>";
    }
    
} catch (Exception $e) {
    echo "❌ خطأ: " . $e->getMessage() . "<br>";
}
?> 