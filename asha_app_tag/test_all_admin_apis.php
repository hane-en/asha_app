<?php
echo "<h1>اختبار جميع APIs المشرف</h1>\n";

$apis = [
    'المستخدمين' => 'http://localhost/asha_app_tag/api/admin/get_all_users.php',
    'الإعلانات' => 'http://localhost/asha_app_tag/api/admin/get_all_ads.php',
    'الحجوزات' => 'http://localhost/asha_app_tag/api/admin/get_all_bookings.php',
    'التعليقات' => 'http://localhost/asha_app_tag/api/admin/get_all_reviews.php',
    'طلبات مزودي الخدمة' => 'http://localhost/asha_app_tag/api/admin/get_provider_requests.php',
    'الخدمات مع الفئات' => 'http://localhost/asha_app_tag/api/admin/get_all_services_simple.php'
];

foreach ($apis as $name => $url) {
    echo "<h2>اختبار $name:</h2>\n";
    
    $response = file_get_contents($url);
    
    if ($response === false) {
        echo "❌ فشل في الوصول إلى $name\n";
    } else {
        $data = json_decode($response, true);
        if ($data === null) {
            echo "❌ فشل في تحليل JSON لـ $name\n";
        } else {
            echo "✅ نجح $name\n";
            if (isset($data['success'])) {
                echo "النجاح: " . ($data['success'] ? 'نعم' : 'لا') . "\n";
            }
            if (isset($data['data']) && is_array($data['data'])) {
                echo "عدد العناصر: " . count($data['data']) . "\n";
            }
            if (isset($data['stats'])) {
                echo "الإحصائيات: " . json_encode($data['stats'], JSON_UNESCAPED_UNICODE) . "\n";
            }
        }
    }
    echo "<hr>\n";
}

// اختبار الاتصال المباشر بقاعدة البيانات
echo "<h2>اختبار الاتصال المباشر:</h2>\n";
require_once 'config.php';
require_once 'database.php';

try {
    $pdo = new PDO("mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=utf8mb4", DB_USER, DB_PASS);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    $tables = ['users', 'services', 'ads', 'bookings', 'reviews', 'provider_requests'];
    
    foreach ($tables as $table) {
        $stmt = $pdo->query("SELECT COUNT(*) as count FROM $table");
        $count = $stmt->fetch(PDO::FETCH_ASSOC)['count'];
        echo "جدول $table: $count صف\n";
    }
    
} catch (Exception $e) {
    echo "❌ خطأ في الاتصال: " . $e->getMessage() . "\n";
}
?> 