<?php
require_once 'config.php';
require_once 'database.php';

echo "<h1>اختبار مباشر لـ API المشرف</h1>\n";

try {
    $pdo = new PDO("mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=utf8mb4", DB_USER, DB_PASS);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    echo "✅ الاتصال بقاعدة البيانات نجح\n";
    
    // اختبار الاستعلام المبسط
    $query = "
        SELECT 
            s.id as service_id,
            s.title as service_title,
            COALESCE(u.name, 'غير محدد') as provider_name,
            COALESCE(c.name, 'غير محدد') as category_name
        FROM services s
        LEFT JOIN users u ON s.provider_id = u.id
        LEFT JOIN categories c ON s.category_id = c.id
        WHERE s.is_active = 1
        LIMIT 5
    ";
    
    $stmt = $pdo->prepare($query);
    $stmt->execute();
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo "✅ الاستعلام المبسط نجح - عدد النتائج: " . count($results) . "\n";
    
    foreach ($results as $row) {
        echo "- خدمة: {$row['service_title']}, مزود: {$row['provider_name']}, فئة: {$row['category_name']}\n";
    }
    
    // اختبار جدول فئات الخدمات
    echo "\n<h2>اختبار جدول فئات الخدمات:</h2>\n";
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM service_categories");
    $count = $stmt->fetch(PDO::FETCH_ASSOC)['count'];
    echo "عدد فئات الخدمات: $count\n";
    
    if ($count > 0) {
        $stmt = $pdo->query("SELECT id, name, service_id FROM service_categories LIMIT 5");
        $categories = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        foreach ($categories as $cat) {
            echo "- فئة: {$cat['name']}, خدمة ID: {$cat['service_id']}\n";
        }
    }
    
} catch (Exception $e) {
    echo "❌ خطأ: " . $e->getMessage() . "\n";
}
?> 