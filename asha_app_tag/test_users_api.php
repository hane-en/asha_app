<?php
$url = "http://localhost/asha_app_tag/api/admin/get_all_users.php";
$response = file_get_contents($url);

if ($response === false) {
    echo "❌ فشل في الوصول إلى API\n";
} else {
    $data = json_decode($response, true);
    if ($data === null) {
        echo "❌ فشل في تحليل JSON\n";
        echo "الاستجابة: " . substr($response, 0, 500) . "\n";
    } else {
        echo "✅ نجح API المستخدمين\n";
        echo "النجاح: " . ($data['success'] ? 'نعم' : 'لا') . "\n";
        if (isset($data['data']) && is_array($data['data'])) {
            echo "عدد المستخدمين: " . count($data['data']) . "\n";
        }
        if (isset($data['stats'])) {
            echo "الإحصائيات: " . json_encode($data['stats'], JSON_UNESCAPED_UNICODE) . "\n";
        }
    }
}
?> 