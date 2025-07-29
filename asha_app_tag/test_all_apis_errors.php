<?php
echo "<h1>اختبار APIs التي بها أخطاء</h1>\n";

$apis = [
    'طلبات مزودي الخدمة' => 'http://localhost/asha_app_tag/api/admin/get_provider_requests.php',
    'التعليقات' => 'http://localhost/asha_app_tag/api/admin/get_all_reviews.php'
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
            echo "الاستجابة: " . substr($response, 0, 200) . "\n";
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
?> 