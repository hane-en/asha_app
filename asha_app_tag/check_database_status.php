<?php
/**
 * صفحة للتحقق من حالة قاعدة البيانات
 * يمكن الوصول إليها عبر: http://localhost/asha_app_backend/check_database_status.php
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
    <title>فحص حالة قاعدة البيانات</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .section { margin: 20px 0; padding: 15px; border: 1px solid #ddd; border-radius: 5px; }
        .success { background-color: #d4edda; border-color: #c3e6cb; }
        .error { background-color: #f8d7da; border-color: #f5c6cb; }
        .info { background-color: #d1ecf1; border-color: #bee5eb; }
        .warning { background-color: #fff3cd; border-color: #ffeaa7; }
        table { width: 100%; border-collapse: collapse; margin: 10px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: right; }
        th { background-color: #f2f2f2; }
        .btn { display: inline-block; margin: 5px; padding: 8px 15px; background: #007bff; color: white; text-decoration: none; border-radius: 3px; }
        .btn:hover { background: #0056b3; }
        .btn-success { background: #28a745; }
        .btn-warning { background: #ffc107; color: #000; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔍 فحص حالة قاعدة البيانات</h1>';

try {
    $database = new Database();
    $database->connect();
    
    echo '<div class="section success">
        <h2>✅ تم الاتصال بقاعدة البيانات بنجاح</h2>
        <p><strong>اسم قاعدة البيانات:</strong> ' . DB_NAME . '</p>
        <p><strong>اسم المستخدم:</strong> ' . DB_USER . '</p>
        <p><strong>اسم الخادم:</strong> ' . DB_HOST . '</p>
    </div>';
    
    // فحص الجداول الرئيسية
    echo '<div class="section info">
        <h2>📊 فحص الجداول الرئيسية</h2>';
    
    $tables = [
        'services' => 'الخدمات',
        'categories' => 'الفئات',
        'users' => 'المستخدمين',
        'ads' => 'الإعلانات',
        'bookings' => 'الحجوزات',
        'reviews' => 'التقييمات',
        'favorites' => 'المفضلة'
    ];
    
    foreach ($tables as $table => $arabicName) {
        $countQuery = "SELECT COUNT(*) as total FROM $table";
        $result = $database->selectOne($countQuery);
        $count = $result ? $result['total'] : 0;
        
        $statusClass = $count > 0 ? 'success' : 'warning';
        $statusIcon = $count > 0 ? '✅' : '⚠️';
        
        echo "<div class='section $statusClass'>
            <h3>$statusIcon $arabicName</h3>
            <p><strong>عدد السجلات:</strong> $count</p>";
        
        if ($count > 0) {
            // عرض أول 3 سجلات
            $sampleQuery = "SELECT * FROM $table LIMIT 3";
            $sampleResult = $database->select($sampleQuery);
            
            if ($sampleResult && count($sampleResult) > 0) {
                echo '<table>
                    <thead>
                        <tr>';
                
                // عرض أسماء الأعمدة
                foreach (array_keys($sampleResult[0]) as $column) {
                    echo "<th>$column</th>";
                }
                
                echo '</tr></thead><tbody>';
                
                foreach ($sampleResult as $row) {
                    echo '<tr>';
                    foreach ($row as $value) {
                        echo '<td>' . htmlspecialchars($value) . '</td>';
                    }
                    echo '</tr>';
                }
                
                echo '</tbody></table>';
            }
        } else {
            echo '<p>لا توجد بيانات في هذا الجدول</p>';
        }
        
        echo '</div>';
    }
    
    // فحص الخدمات النشطة
    echo '<div class="section info">
        <h2>🔍 فحص الخدمات النشطة</h2>';
    
    $activeServicesQuery = "
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
    
    $activeServices = $database->select($activeServicesQuery);
    
    if ($activeServices && count($activeServices) > 0) {
        echo '<div class="success">
            <h3>✅ تم العثور على ' . count($activeServices) . ' خدمة نشطة</h3>
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
        
        foreach ($activeServices as $service) {
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
        echo '<div class="warning">
            <h3>⚠️ لا توجد خدمات نشطة</h3>
            <p>قد تحتاج إلى إضافة خدمات أو تفعيل الخدمات الموجودة.</p>
        </div>';
    }
    
    // روابط مفيدة
    echo '<div class="section info">
        <h2>🔗 روابط مفيدة</h2>
        <a href="test_services_api.php" class="btn">اختبار API الخدمات</a>
        <a href="api/services/get_all.php" class="btn" target="_blank">API الخدمات</a>
        <a href="api/services/get_categories.php" class="btn" target="_blank">API الفئات</a>
        <a href="api/ads/get_active_ads.php" class="btn" target="_blank">API الإعلانات</a>
        <a href="insert_sample_data.php" class="btn btn-success">إضافة بيانات تجريبية</a>
    </div>';
    
} catch (Exception $e) {
    echo '<div class="section error">
        <h2>❌ خطأ في الاتصال بقاعدة البيانات</h2>
        <p><strong>الخطأ:</strong> ' . $e->getMessage() . '</p>
        <p><strong>تفاصيل:</strong> ' . $e->getTraceAsString() . '</p>
    </div>';
}

echo '</div></body></html>';
?> 