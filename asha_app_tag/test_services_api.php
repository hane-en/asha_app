<?php
/**
 * صفحة اختبار لجلب الخدمات من قاعدة البيانات
 * يمكن الوصول إليها عبر: http://localhost/asha_app_backend/test_services_api.php
 */

require_once 'config.php';
require_once 'database.php';

// إعداد CORS
header('Access-Control-Allow-Origin: *');
header('Content-Type: text/html; charset=utf-8');

echo '<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>اختبار جلب الخدمات</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .section { margin: 20px 0; padding: 15px; border: 1px solid #ddd; border-radius: 5px; }
        .success { background-color: #d4edda; border-color: #c3e6cb; }
        .error { background-color: #f8d7da; border-color: #f5c6cb; }
        .info { background-color: #d1ecf1; border-color: #bee5eb; }
        .service-item { background: #f8f9fa; padding: 10px; margin: 5px 0; border-radius: 3px; }
        .api-link { display: inline-block; margin: 5px; padding: 8px 15px; background: #007bff; color: white; text-decoration: none; border-radius: 3px; }
        .api-link:hover { background: #0056b3; }
        table { width: 100%; border-collapse: collapse; margin: 10px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: right; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔍 اختبار جلب الخدمات من قاعدة البيانات</h1>';

try {
    $database = new Database();
    $database->connect();
    
    echo '<div class="section success">
        <h2>✅ تم الاتصال بقاعدة البيانات بنجاح</h2>
    </div>';
    
    // فحص الجداول
    echo '<div class="section info">
        <h2>📊 معلومات الجداول</h2>';
    
    $tables = ['services', 'categories', 'users', 'ads'];
    foreach ($tables as $table) {
        $countQuery = "SELECT COUNT(*) as total FROM $table";
        $result = $database->selectOne($countQuery);
        $count = $result ? $result['total'] : 0;
        echo "<p><strong>$table:</strong> $count سجل</p>";
    }
    echo '</div>';
    
    // اختبار جلب الخدمات
    echo '<div class="section info">
        <h2>🔍 اختبار جلب الخدمات</h2>';
    
    $servicesQuery = "
        SELECT 
            s.*,
            c.name as category_name,
            u.name as provider_name
        FROM services s
        LEFT JOIN categories c ON s.category_id = c.id
        LEFT JOIN users u ON s.provider_id = u.id
        WHERE s.is_active = 1
        ORDER BY s.created_at DESC
        LIMIT 5
    ";
    
    $services = $database->select($servicesQuery);
    
    if ($services && count($services) > 0) {
        echo '<div class="success">
            <h3>✅ تم جلب ' . count($services) . ' خدمة</h3>
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>العنوان</th>
                        <th>الوصف</th>
                        <th>السعر</th>
                        <th>الفئة</th>
                        <th>المزود</th>
                        <th>الحالة</th>
                    </tr>
                </thead>
                <tbody>';
        
        foreach ($services as $service) {
            echo '<tr>
                <td>' . $service['id'] . '</td>
                <td>' . htmlspecialchars($service['title']) . '</td>
                <td>' . htmlspecialchars(substr($service['description'], 0, 50)) . '...</td>
                <td>' . $service['price'] . '</td>
                <td>' . htmlspecialchars($service['category_name']) . '</td>
                <td>' . htmlspecialchars($service['provider_name']) . '</td>
                <td>' . ($service['is_active'] ? 'نشط' : 'غير نشط') . '</td>
            </tr>';
        }
        
        echo '</tbody></table></div>';
    } else {
        echo '<div class="error">
            <h3>❌ لم يتم العثور على خدمات</h3>
            <p>قد تكون قاعدة البيانات فارغة أو لا توجد خدمات نشطة.</p>
        </div>';
    }
    
    // اختبار API endpoints
    echo '<div class="section info">
        <h2>🔗 روابط API للاختبار</h2>
        <p>اضغط على الروابط التالية لاختبار API endpoints:</p>
        <a href="api/services/get_all.php" class="api-link" target="_blank">جلب جميع الخدمات</a>
        <a href="api/services/get_categories.php" class="api-link" target="_blank">جلب الفئات</a>
        <a href="api/ads/get_active_ads.php" class="api-link" target="_blank">جلب الإعلانات</a>
        <a href="api/users/get_all.php" class="api-link" target="_blank">جلب المستخدمين</a>
    </div>';
    
    // اختبار الاستعلام المباشر
    echo '<div class="section info">
        <h2>🔍 اختبار الاستعلام المباشر</h2>';
    
    $simpleQuery = "SELECT * FROM services LIMIT 3";
    $simpleResult = $database->select($simpleQuery);
    
    if ($simpleResult && count($simpleResult) > 0) {
        echo '<div class="success">
            <h3>✅ تم جلب البيانات المباشرة</h3>
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>العنوان</th>
                        <th>السعر</th>
                        <th>الحالة</th>
                    </tr>
                </thead>
                <tbody>';
        
        foreach ($simpleResult as $row) {
            echo '<tr>
                <td>' . $row['id'] . '</td>
                <td>' . htmlspecialchars($row['title']) . '</td>
                <td>' . $row['price'] . '</td>
                <td>' . ($row['is_active'] ? 'نشط' : 'غير نشط') . '</td>
            </tr>';
        }
        
        echo '</tbody></table></div>';
    } else {
        echo '<div class="error">
            <h3>❌ فشل في جلب البيانات المباشرة</h3>
        </div>';
    }
    
} catch (Exception $e) {
    echo '<div class="section error">
        <h2>❌ خطأ في الاتصال بقاعدة البيانات</h2>
        <p><strong>الخطأ:</strong> ' . $e->getMessage() . '</p>
    </div>';
}

echo '</div></body></html>';
?> 