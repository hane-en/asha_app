<?php
/**
 * ملف إضافة بيانات تجريبية للخدمات
 * يمكن الوصول إليها عبر: http://localhost/asha_app_backend/insert_sample_data.php
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
    <title>إضافة بيانات تجريبية</title>
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
        .btn-danger { background: #dc3545; }
    </style>
</head>
<body>
    <div class="container">
        <h1>📝 إضافة بيانات تجريبية</h1>';

try {
    $database = new Database();
    $database->connect();
    
    echo '<div class="section success">
        <h2>✅ تم الاتصال بقاعدة البيانات بنجاح</h2>
    </div>';
    
    // التحقق من وجود فئات
    $categoriesQuery = "SELECT COUNT(*) as total FROM categories";
    $categoriesCount = $database->selectOne($categoriesQuery);
    $categoriesExist = $categoriesCount && $categoriesCount['total'] > 0;
    
    if (!$categoriesExist) {
        echo '<div class="section info">
            <h2>📝 إضافة فئات تجريبية</h2>';
        
        $sampleCategories = [
            ['name' => 'تصوير', 'description' => 'خدمات التصوير الاحترافي'],
            ['name' => 'مطاعم', 'description' => 'خدمات المطاعم والضيافة'],
            ['name' => 'قاعات', 'description' => 'قاعات الحفلات والمناسبات'],
            ['name' => 'موسيقى', 'description' => 'خدمات الموسيقى والترفيه'],
            ['name' => 'ديكور', 'description' => 'خدمات الديكور والتزيين'],
            ['name' => 'نقل', 'description' => 'خدمات النقل والمواصلات'],
            ['name' => 'أخرى', 'description' => 'خدمات أخرى متنوعة']
        ];
        
        foreach ($sampleCategories as $category) {
            $insertQuery = "INSERT INTO categories (name, description, is_active, created_at) VALUES (?, ?, 1, NOW())";
            $database->execute($insertQuery, [$category['name'], $category['description']]);
            echo '<p>✅ تم إضافة فئة: ' . $category['name'] . '</p>';
        }
        
        echo '</div>';
    } else {
        echo '<div class="section info">
            <h2>✅ الفئات موجودة بالفعل</h2>
            <p>تم العثور على ' . $categoriesCount['total'] . ' فئة في قاعدة البيانات</p>
        </div>';
    }
    
    // التحقق من وجود مستخدمين مزودين
    $providersQuery = "SELECT COUNT(*) as total FROM users WHERE user_type = 'provider'";
    $providersCount = $database->selectOne($providersQuery);
    $providersExist = $providersCount && $providersCount['total'] > 0;
    
    if (!$providersExist) {
        echo '<div class="section info">
            <h2>📝 إضافة مستخدمين مزودين تجريبيين</h2>';
        
        $sampleProviders = [
            ['name' => 'أحمد محمد', 'email' => 'ahmed@example.com', 'phone' => '0501234567'],
            ['name' => 'فاطمة علي', 'email' => 'fatima@example.com', 'phone' => '0502345678'],
            ['name' => 'محمد حسن', 'email' => 'mohammed@example.com', 'phone' => '0503456789'],
            ['name' => 'سارة أحمد', 'email' => 'sara@example.com', 'phone' => '0504567890'],
            ['name' => 'علي محمد', 'email' => 'ali@example.com', 'phone' => '0505678901']
        ];
        
        foreach ($sampleProviders as $provider) {
            $insertQuery = "INSERT INTO users (name, email, phone, password, user_type, is_verified, is_active, created_at) VALUES (?, ?, ?, ?, 'provider', 1, 1, NOW())";
            $database->execute($insertQuery, [$provider['name'], $provider['email'], $provider['phone'], password_hash('123456', PASSWORD_DEFAULT)]);
            echo '<p>✅ تم إضافة مزود: ' . $provider['name'] . '</p>';
        }
        
        echo '</div>';
    } else {
        echo '<div class="section info">
            <h2>✅ المزودون موجودون بالفعل</h2>
            <p>تم العثور على ' . $providersCount['total'] . ' مزود في قاعدة البيانات</p>
        </div>';
    }
    
    // إضافة خدمات تجريبية
    echo '<div class="section info">
        <h2>📝 إضافة خدمات تجريبية</h2>';
    
    // الحصول على الفئات والمزودين
    $categories = $database->select("SELECT id, name FROM categories WHERE is_active = 1");
    $providers = $database->select("SELECT id, name FROM users WHERE user_type = 'provider' AND is_active = 1");
    
    if ($categories && $providers) {
        $sampleServices = [
            [
                'title' => 'تصوير احترافي للمناسبات',
                'description' => 'خدمة تصوير احترافية لجميع أنواع المناسبات مع كاميرات عالية الجودة',
                'price' => 500,
                'category_id' => $categories[0]['id'],
                'provider_id' => $providers[0]['id']
            ],
            [
                'title' => 'خدمة المطاعم والضيافة',
                'description' => 'خدمات المطاعم والضيافة للمناسبات الخاصة مع قوائم متنوعة',
                'price' => 800,
                'category_id' => $categories[1]['id'],
                'provider_id' => $providers[1]['id']
            ],
            [
                'title' => 'قاعة حفلات فاخرة',
                'description' => 'قاعة حفلات فاخرة مجهزة بالكامل مع خدمة شاملة',
                'price' => 1200,
                'category_id' => $categories[2]['id'],
                'provider_id' => $providers[2]['id']
            ],
            [
                'title' => 'فرقة موسيقية احترافية',
                'description' => 'فرقة موسيقية احترافية لجميع أنواع المناسبات مع مجموعة متنوعة من الموسيقى',
                'price' => 600,
                'category_id' => $categories[3]['id'],
                'provider_id' => $providers[3]['id']
            ],
            [
                'title' => 'خدمة الديكور والتزيين',
                'description' => 'خدمة ديكور وتزيين احترافية للمناسبات مع تصميمات مخصصة',
                'price' => 400,
                'category_id' => $categories[4]['id'],
                'provider_id' => $providers[4]['id']
            ],
            [
                'title' => 'خدمة النقل الفاخر',
                'description' => 'خدمة نقل فاخر للمناسبات مع سيارات حديثة وسائقين محترفين',
                'price' => 300,
                'category_id' => $categories[5]['id'],
                'provider_id' => $providers[0]['id']
            ]
        ];
        
        foreach ($sampleServices as $service) {
            $insertQuery = "INSERT INTO services (title, description, price, category_id, provider_id, is_active, is_verified, created_at) VALUES (?, ?, ?, ?, ?, 1, 1, NOW())";
            $database->execute($insertQuery, [
                $service['title'],
                $service['description'],
                $service['price'],
                $service['category_id'],
                $service['provider_id']
            ]);
            echo '<p>✅ تم إضافة خدمة: ' . $service['title'] . '</p>';
        }
        
        echo '</div>';
    } else {
        echo '<div class="section error">
            <h2>❌ لا يمكن إضافة خدمات</h2>
            <p>يجب وجود فئات ومزودين أولاً</p>
        </div>';
    }
    
    // عرض النتيجة النهائية
    echo '<div class="section success">
        <h2>✅ تم إضافة البيانات التجريبية بنجاح</h2>
        <p>يمكنك الآن اختبار التطبيق والتحقق من ظهور الخدمات</p>
    </div>';
    
    // روابط مفيدة
    echo '<div class="section info">
        <h2>🔗 روابط مفيدة</h2>
        <a href="check_database_status.php" class="btn">فحص حالة قاعدة البيانات</a>
        <a href="test_services_api.php" class="btn">اختبار API الخدمات</a>
        <a href="api/services/get_all.php" class="btn" target="_blank">API الخدمات</a>
        <a href="clear_database.php" class="btn btn-danger">مسح جميع البيانات</a>
    </div>';
    
} catch (Exception $e) {
    echo '<div class="section error">
        <h2>❌ خطأ في إضافة البيانات</h2>
        <p><strong>الخطأ:</strong> ' . $e->getMessage() . '</p>
    </div>';
}

echo '</div></body></html>';
?> 