<?php
/**
 * ملف تفعيل جميع الخدمات
 * يمكن الوصول إليها عبر: http://localhost/asha_app_backend/activate_services.php
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
    <title>تفعيل الخدمات</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .section { margin: 20px 0; padding: 15px; border: 1px solid #ddd; border-radius: 5px; }
        .success { background-color: #d4edda; border-color: #c3e6cb; }
        .error { background-color: #f8d7da; border-color: #f5c6cb; }
        .info { background-color: #d1ecf1; border-color: #bee5eb; }
        .btn { display: inline-block; margin: 5px; padding: 8px 15px; background: #007bff; color: white; text-decoration: none; border-radius: 3px; }
        .btn:hover { background: #0056b3; }
        .btn-success { background: #28a745; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔧 تفعيل الخدمات</h1>';

try {
    $database = new Database();
    $database->connect();
    
    echo '<div class="section success">
        <h2>✅ تم الاتصال بقاعدة البيانات بنجاح</h2>
    </div>';
    
    // تفعيل جميع الخدمات
    echo '<div class="section info">
        <h2>🔧 تفعيل جميع الخدمات</h2>';
    
    $updateQuery = "UPDATE services SET is_active = 1, is_verified = 1 WHERE is_active = 0 OR is_active IS NULL";
    $result = $database->execute($updateQuery);
    
    if ($result) {
        echo '<div class="success">
            <h3>✅ تم تفعيل جميع الخدمات بنجاح</h3>
        </div>';
    } else {
        echo '<div class="error">
            <h3>❌ فشل في تفعيل الخدمات</h3>
        </div>';
    }
    
    // تفعيل جميع الفئات
    echo '<div class="section info">
        <h2>🔧 تفعيل جميع الفئات</h2>';
    
    $updateCategoriesQuery = "UPDATE categories SET is_active = 1 WHERE is_active = 0 OR is_active IS NULL";
    $resultCategories = $database->execute($updateCategoriesQuery);
    
    if ($resultCategories) {
        echo '<div class="success">
            <h3>✅ تم تفعيل جميع الفئات بنجاح</h3>
        </div>';
    } else {
        echo '<div class="error">
            <h3>❌ فشل في تفعيل الفئات</h3>
        </div>';
    }
    
    // تفعيل جميع المزودين
    echo '<div class="section info">
        <h2>🔧 تفعيل جميع المزودين</h2>';
    
    $updateProvidersQuery = "UPDATE users SET is_active = 1, is_verified = 1 WHERE user_type = 'provider' AND (is_active = 0 OR is_active IS NULL)";
    $resultProviders = $database->execute($updateProvidersQuery);
    
    if ($resultProviders) {
        echo '<div class="success">
            <h3>✅ تم تفعيل جميع المزودين بنجاح</h3>
        </div>';
    } else {
        echo '<div class="error">
            <h3>❌ فشل في تفعيل المزودين</h3>
        </div>';
    }
    
    // عرض الإحصائيات بعد التحديث
    echo '<div class="section info">
        <h2>📊 الإحصائيات بعد التحديث</h2>';
    
    $servicesCount = $database->selectOne("SELECT COUNT(*) as total FROM services WHERE is_active = 1");
    $categoriesCount = $database->selectOne("SELECT COUNT(*) as total FROM categories WHERE is_active = 1");
    $providersCount = $database->selectOne("SELECT COUNT(*) as total FROM users WHERE user_type = 'provider' AND is_active = 1");
    
    echo '<div class="success">
        <h3>✅ الإحصائيات النهائية:</h3>
        <p><strong>الخدمات النشطة:</strong> ' . $servicesCount['total'] . '</p>
        <p><strong>الفئات النشطة:</strong> ' . $categoriesCount['total'] . '</p>
        <p><strong>المزودون النشطون:</strong> ' . $providersCount['total'] . '</p>
    </div>';
    
    // روابط مفيدة
    echo '<div class="section info">
        <h2>🔗 روابط مفيدة</h2>
        <a href="api/services/get_all.php" class="btn" target="_blank">اختبار API الخدمات</a>
        <a href="debug_services.php" class="btn">فحص بيانات الخدمات</a>
        <a href="check_database_status.php" class="btn">فحص حالة قاعدة البيانات</a>
    </div>';
    
} catch (Exception $e) {
    echo '<div class="section error">
        <h2>❌ خطأ في تفعيل الخدمات</h2>
        <p><strong>الخطأ:</strong> ' . $e->getMessage() . '</p>
    </div>';
}

echo '</div></body></html>';
?> 