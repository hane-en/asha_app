<?php
/**
 * صفحة اختبار الاستعلام مباشرة
 * يمكن الوصول إليها عبر: http://localhost/asha_app_backend/test_query.php
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
    <title>اختبار الاستعلام</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .section { margin: 20px 0; padding: 15px; border: 1px solid #ddd; border-radius: 5px; }
        .success { background-color: #d4edda; border-color: #c3e6cb; }
        .error { background-color: #f8d7da; border-color: #f5c6cb; }
        .info { background-color: #d1ecf1; border-color: #bee5eb; }
        pre { background: #f8f9fa; padding: 10px; border-radius: 5px; overflow-x: auto; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔍 اختبار الاستعلام</h1>';

try {
    $database = new Database();
    $database->connect();
    
    echo '<div class="section success">
        <h2>✅ تم الاتصال بقاعدة البيانات بنجاح</h2>
    </div>';
    
    // اختبار 1: استعلام بسيط للخدمات
    echo '<div class="section info">
        <h2>🔍 اختبار 1: استعلام بسيط للخدمات</h2>';
    
    $simpleQuery = "SELECT * FROM services LIMIT 5";
    $simpleResult = $database->select($simpleQuery);
    
    if ($simpleResult && count($simpleResult) > 0) {
        echo '<div class="success">
            <h3>✅ تم جلب ' . count($simpleResult) . ' خدمة</h3>
            <pre>' . json_encode($simpleResult, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . '</pre>
        </div>';
    } else {
        echo '<div class="error">
            <h3>❌ فشل في جلب الخدمات</h3>
        </div>';
    }
    
    // اختبار 2: استعلام مع JOIN
    echo '<div class="section info">
        <h2>🔍 اختبار 2: استعلام مع JOIN</h2>';
    
    $joinQuery = "
        SELECT 
            s.*,
            c.name as category_name,
            u.name as provider_name
        FROM services s
        LEFT JOIN categories c ON s.category_id = c.id
        LEFT JOIN users u ON s.provider_id = u.id
        ORDER BY s.created_at DESC
        LIMIT 5
    ";
    
    $joinResult = $database->select($joinQuery);
    
    if ($joinResult && count($joinResult) > 0) {
        echo '<div class="success">
            <h3>✅ تم جلب ' . count($joinResult) . ' خدمة مع JOIN</h3>
            <pre>' . json_encode($joinResult, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . '</pre>
        </div>';
    } else {
        echo '<div class="error">
            <h3>❌ فشل في جلب الخدمات مع JOIN</h3>
        </div>';
    }
    
    // اختبار 3: استعلام مع LIMIT و OFFSET
    echo '<div class="section info">
        <h2>🔍 اختبار 3: استعلام مع LIMIT و OFFSET</h2>';
    
    $limit = 5;
    $offset = 0;
    
    $limitQuery = "
        SELECT 
            s.*,
            c.name as category_name,
            u.name as provider_name
        FROM services s
        LEFT JOIN categories c ON s.category_id = c.id
        LEFT JOIN users u ON s.provider_id = u.id
        ORDER BY s.created_at DESC
        LIMIT ? OFFSET ?
    ";
    
    $limitResult = $database->select($limitQuery, [$limit, $offset]);
    
    if ($limitResult && count($limitResult) > 0) {
        echo '<div class="success">
            <h3>✅ تم جلب ' . count($limitResult) . ' خدمة مع LIMIT و OFFSET</h3>
            <pre>' . json_encode($limitResult, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . '</pre>
        </div>';
    } else {
        echo '<div class="error">
            <h3>❌ فشل في جلب الخدمات مع LIMIT و OFFSET</h3>
        </div>';
    }
    
    // اختبار 4: فحص الفئات والمزودين
    echo '<div class="section info">
        <h2>🔍 اختبار 4: فحص الفئات والمزودين</h2>';
    
    $categoriesQuery = "SELECT * FROM categories LIMIT 3";
    $categoriesResult = $database->select($categoriesQuery);
    
    $providersQuery = "SELECT * FROM users WHERE user_type = 'provider' LIMIT 3";
    $providersResult = $database->select($providersQuery);
    
    echo '<div class="info">
        <h3>الفئات:</h3>
        <pre>' . json_encode($categoriesResult, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . '</pre>
        
        <h3>المزودون:</h3>
        <pre>' . json_encode($providersResult, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . '</pre>
    </div>';
    
    // اختبار 5: فحص البيانات الخام
    echo '<div class="section info">
        <h2>🔍 اختبار 5: فحص البيانات الخام</h2>';
    
    $rawQuery = "SELECT id, title, category_id, provider_id, is_active FROM services LIMIT 3";
    $rawResult = $database->select($rawQuery);
    
    if ($rawResult && count($rawResult) > 0) {
        echo '<div class="success">
            <h3>✅ البيانات الخام:</h3>
            <pre>' . json_encode($rawResult, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . '</pre>
        </div>';
    } else {
        echo '<div class="error">
            <h3>❌ لا توجد بيانات خام</h3>
        </div>';
    }
    
} catch (Exception $e) {
    echo '<div class="section error">
        <h2>❌ خطأ في الاختبار</h2>
        <p><strong>الخطأ:</strong> ' . $e->getMessage() . '</p>
    </div>';
}

echo '</div></body></html>';
?> 