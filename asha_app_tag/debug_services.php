<?php
/**
 * صفحة للتحقق من البيانات في جدول الخدمات
 * يمكن الوصول إليها عبر: http://localhost/asha_app_backend/debug_services.php
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
    <title>تحقق من بيانات الخدمات</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .section { margin: 20px 0; padding: 15px; border: 1px solid #ddd; border-radius: 5px; }
        .success { background-color: #d4edda; border-color: #c3e6cb; }
        .error { background-color: #f8d7da; border-color: #f5c6cb; }
        .info { background-color: #d1ecf1; border-color: #bee5eb; }
        table { width: 100%; border-collapse: collapse; margin: 10px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: right; }
        th { background-color: #f2f2f2; }
        .btn { display: inline-block; margin: 5px; padding: 8px 15px; background: #007bff; color: white; text-decoration: none; border-radius: 3px; }
        .btn:hover { background: #0056b3; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔍 تحقق من بيانات الخدمات</h1>';

try {
    $database = new Database();
    $database->connect();
    
    echo '<div class="section success">
        <h2>✅ تم الاتصال بقاعدة البيانات بنجاح</h2>
    </div>';
    
    // فحص جميع الخدمات
    echo '<div class="section info">
        <h2>📊 جميع الخدمات في قاعدة البيانات</h2>';
    
    $allServicesQuery = "SELECT * FROM services ORDER BY id DESC";
    $allServices = $database->select($allServicesQuery);
    
    if ($allServices && count($allServices) > 0) {
        echo '<div class="success">
            <h3>✅ تم العثور على ' . count($allServices) . ' خدمة</h3>
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>العنوان</th>
                        <th>الوصف</th>
                        <th>السعر</th>
                        <th>الفئة ID</th>
                        <th>المزود ID</th>
                        <th>نشط</th>
                        <th>متحقق</th>
                        <th>تاريخ الإنشاء</th>
                    </tr>
                </thead>
                <tbody>';
        
        foreach ($allServices as $service) {
            echo '<tr>
                <td>' . $service['id'] . '</td>
                <td>' . htmlspecialchars($service['title']) . '</td>
                <td>' . htmlspecialchars(substr($service['description'], 0, 50)) . '...</td>
                <td>' . $service['price'] . '</td>
                <td>' . $service['category_id'] . '</td>
                <td>' . $service['provider_id'] . '</td>
                <td>' . ($service['is_active'] ? 'نعم' : 'لا') . '</td>
                <td>' . ($service['is_verified'] ? 'نعم' : 'لا') . '</td>
                <td>' . $service['created_at'] . '</td>
            </tr>';
        }
        
        echo '</tbody></table></div>';
    } else {
        echo '<div class="error">
            <h3>❌ لا توجد خدمات في قاعدة البيانات</h3>
        </div>';
    }
    
    // فحص الخدمات النشطة فقط
    echo '<div class="section info">
        <h2>🔍 الخدمات النشطة فقط</h2>';
    
    $activeServicesQuery = "SELECT * FROM services WHERE is_active = 1 ORDER BY id DESC";
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
                        <th>الفئة ID</th>
                        <th>المزود ID</th>
                        <th>تاريخ الإنشاء</th>
                    </tr>
                </thead>
                <tbody>';
        
        foreach ($activeServices as $service) {
            echo '<tr>
                <td>' . $service['id'] . '</td>
                <td>' . htmlspecialchars($service['title']) . '</td>
                <td>' . htmlspecialchars(substr($service['description'], 0, 50)) . '...</td>
                <td>' . $service['price'] . '</td>
                <td>' . $service['category_id'] . '</td>
                <td>' . $service['provider_id'] . '</td>
                <td>' . $service['created_at'] . '</td>
            </tr>';
        }
        
        echo '</tbody></table></div>';
    } else {
        echo '<div class="warning">
            <h3>⚠️ لا توجد خدمات نشطة</h3>
            <p>جميع الخدمات غير مفعلة أو is_active = 0</p>
        </div>';
    }
    
    // فحص الفئات
    echo '<div class="section info">
        <h2>📋 الفئات المتاحة</h2>';
    
    $categoriesQuery = "SELECT * FROM categories ORDER BY id";
    $categories = $database->select($categoriesQuery);
    
    if ($categories && count($categories) > 0) {
        echo '<div class="success">
            <h3>✅ تم العثور على ' . count($categories) . ' فئة</h3>
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>الاسم</th>
                        <th>الوصف</th>
                        <th>نشط</th>
                    </tr>
                </thead>
                <tbody>';
        
        foreach ($categories as $category) {
            echo '<tr>
                <td>' . $category['id'] . '</td>
                <td>' . htmlspecialchars($category['name']) . '</td>
                <td>' . htmlspecialchars($category['description']) . '</td>
                <td>' . ($category['is_active'] ? 'نعم' : 'لا') . '</td>
            </tr>';
        }
        
        echo '</tbody></table></div>';
    } else {
        echo '<div class="error">
            <h3>❌ لا توجد فئات</h3>
        </div>';
    }
    
    // فحص المزودين
    echo '<div class="section info">
        <h2>👥 المزودون المتاحون</h2>';
    
    $providersQuery = "SELECT * FROM users WHERE user_type = 'provider' ORDER BY id";
    $providers = $database->select($providersQuery);
    
    if ($providers && count($providers) > 0) {
        echo '<div class="success">
            <h3>✅ تم العثور على ' . count($providers) . ' مزود</h3>
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>الاسم</th>
                        <th>البريد الإلكتروني</th>
                        <th>الهاتف</th>
                        <th>نشط</th>
                    </tr>
                </thead>
                <tbody>';
        
        foreach ($providers as $provider) {
            echo '<tr>
                <td>' . $provider['id'] . '</td>
                <td>' . htmlspecialchars($provider['name']) . '</td>
                <td>' . htmlspecialchars($provider['email']) . '</td>
                <td>' . htmlspecialchars($provider['phone']) . '</td>
                <td>' . ($provider['is_active'] ? 'نعم' : 'لا') . '</td>
            </tr>';
        }
        
        echo '</tbody></table></div>';
    } else {
        echo '<div class="error">
            <h3>❌ لا توجد مزودين</h3>
        </div>';
    }
    
    // روابط مفيدة
    echo '<div class="section info">
        <h2>🔗 روابط مفيدة</h2>
        <a href="api/services/get_all.php" class="btn" target="_blank">API الخدمات</a>
        <a href="insert_sample_data.php" class="btn">إضافة بيانات تجريبية</a>
        <a href="check_database_status.php" class="btn">فحص حالة قاعدة البيانات</a>
    </div>';
    
} catch (Exception $e) {
    echo '<div class="section error">
        <h2>❌ خطأ في الاتصال بقاعدة البيانات</h2>
        <p><strong>الخطأ:</strong> ' . $e->getMessage() . '</p>
    </div>';
}

echo '</div></body></html>';
?> 