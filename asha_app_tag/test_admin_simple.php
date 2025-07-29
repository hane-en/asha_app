<?php
// اختبار بسيط لـ API المشرف
$url = "http://localhost/asha_app_tag/api/admin/get_all_services_simple.php";
$response = file_get_contents($url);

if ($response === false) {
    echo "❌ فشل في الوصول إلى API المشرف\n";
} else {
    echo "✅ تم الوصول إلى API المشرف\n";
    echo "الاستجابة: " . substr($response, 0, 500) . "...\n";
    
    // محاولة تحليل JSON
    $data = json_decode($response, true);
    if ($data === null) {
        echo "❌ فشل في تحليل JSON\n";
    } else {
        echo "✅ تم تحليل JSON بنجاح\n";
        if (isset($data['success'])) {
            echo "النجاح: " . ($data['success'] ? 'نعم' : 'لا') . "\n";
        }
        if (isset($data['data']) && is_array($data['data'])) {
            echo "عدد الخدمات: " . count($data['data']) . "\n";
        }
    }
}
?> 