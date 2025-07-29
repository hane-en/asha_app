<?php
echo "<h1>اختبار API المشرف</h1>\n";

// اختبار API الخدمات العادي
echo "<h2>اختبار API الخدمات العادي:</h2>\n";
$services_url = "http://localhost/asha_app_tag/api/services/get_all.php";
$services_response = file_get_contents($services_url);
echo "الاستجابة من الخدمات: " . substr($services_response, 0, 200) . "...\n";

// اختبار API المشرف
echo "<h2>اختبار API المشرف:</h2>\n";
$admin_url = "http://localhost/asha_app_tag/api/admin/get_all_services_with_categories.php";
$admin_response = file_get_contents($admin_url);
echo "الاستجابة من المشرف: " . substr($admin_response, 0, 200) . "...\n";

// اختبار الاتصال المباشر بقاعدة البيانات
echo "<h2>اختبار الاتصال المباشر:</h2>\n";
require_once 'config.php';
require_once 'database.php';

try {
    $pdo = new PDO("mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=utf8mb4", DB_USER, DB_PASS);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // اختبار جدول الخدمات
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM services");
    $services_count = $stmt->fetch(PDO::FETCH_ASSOC)['count'];
    echo "عدد الخدمات: $services_count\n";
    
    // اختبار جدول فئات الخدمات
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM service_categories");
    $categories_count = $stmt->fetch(PDO::FETCH_ASSOC)['count'];
    echo "عدد فئات الخدمات: $categories_count\n";
    
    // اختبار الاستعلام المعقد
    $query = "
        SELECT 
            s.id as service_id,
            s.title as service_title,
            sc.id as category_id,
            sc.name as category_name
        FROM services s
        LEFT JOIN service_categories sc ON s.id = sc.service_id
        WHERE s.is_active = 1
        LIMIT 5
    ";
    
    $stmt = $pdo->query($query);
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "نتائج الاستعلام المعقد: " . count($results) . " صف\n";
    
    foreach ($results as $row) {
        echo "- خدمة: {$row['service_title']}, فئة: {$row['category_name']}\n";
    }
    
} catch (Exception $e) {
    echo "خطأ: " . $e->getMessage() . "\n";
}
?> 