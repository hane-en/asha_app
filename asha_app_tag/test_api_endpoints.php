<?php
/**
 * ملف اختبار نقاط النهاية API
 * استخدم هذا الملف لاختبار جميع نقاط النهاية الجديدة
 */

// إعدادات الاختبار
$baseUrl = 'http://localhost/asha_app_tag'; // تغيير حسب إعداداتك
$testResults = [];

// دالة لاختبار نقطة نهاية
function testEndpoint($url, $name) {
    global $testResults;
    
    echo "اختبار: $name\n";
    echo "URL: $url\n";
    
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_TIMEOUT, 30);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Content-Type: application/json',
        'Accept: application/json'
    ]);
    
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $error = curl_error($ch);
    curl_close($ch);
    
    if ($error) {
        echo "خطأ في الاتصال: $error\n";
        $testResults[$name] = ['status' => 'error', 'message' => $error];
        return false;
    }
    
    if ($httpCode !== 200) {
        echo "خطأ HTTP: $httpCode\n";
        $testResults[$name] = ['status' => 'error', 'http_code' => $httpCode];
        return false;
    }
    
    $data = json_decode($response, true);
    if (!$data) {
        echo "خطأ في تنسيق JSON\n";
        $testResults[$name] = ['status' => 'error', 'message' => 'Invalid JSON'];
        return false;
    }
    
    if (isset($data['success']) && $data['success'] === true) {
        echo "✅ نجح الاختبار\n";
        $testResults[$name] = ['status' => 'success', 'data' => $data];
        return true;
    } else {
        echo "❌ فشل الاختبار: " . ($data['message'] ?? 'Unknown error') . "\n";
        $testResults[$name] = ['status' => 'error', 'data' => $data];
        return false;
    }
    
    echo "----------------------------------------\n";
}

echo "بدء اختبار نقاط النهاية API\n";
echo "========================================\n\n";

// اختبار الخدمات المميزة
testEndpoint("$baseUrl/api/services/featured.php", "الخدمات المميزة");

// اختبار جلب جميع الفئات
testEndpoint("$baseUrl/api/categories/get_all.php", "جلب جميع الفئات");

// اختبار جلب فئة محددة (افترض أن ID = 1 موجود)
testEndpoint("$baseUrl/api/categories/get_by_id.php?category_id=1", "جلب فئة محددة");

// اختبار جلب مزودي الخدمات حسب الفئة
testEndpoint("$baseUrl/api/providers/get_by_category.php?category_id=1", "مزودي الخدمات حسب الفئة");

// اختبار جلب خدمات مزود معين (افترض أن ID = 1 موجود)
testEndpoint("$baseUrl/api/providers/get_services.php?provider_id=1", "خدمات مزود معين");

// اختبار جلب معلومات مزود معين
testEndpoint("$baseUrl/api/providers/get_profile.php?provider_id=1", "معلومات مزود معين");

// اختبار جلب جميع الخدمات
testEndpoint("$baseUrl/api/services/get_all.php", "جلب جميع الخدمات");

// اختبار جلب الإعلانات النشطة
testEndpoint("$baseUrl/api/ads/get_active_ads.php", "الإعلانات النشطة");

echo "\n========================================\n";
echo "نتائج الاختبار:\n";
echo "========================================\n";

$successCount = 0;
$totalCount = count($testResults);

foreach ($testResults as $name => $result) {
    $status = $result['status'] === 'success' ? '✅' : '❌';
    echo "$status $name: " . $result['status'] . "\n";
    
    if ($result['status'] === 'success') {
        $successCount++;
    }
}

echo "\n========================================\n";
echo "النتيجة النهائية: $successCount/$totalCount نجح\n";

if ($successCount === $totalCount) {
    echo "🎉 جميع الاختبارات نجحت!\n";
} else {
    echo "⚠️ بعض الاختبارات فشلت. تحقق من الأخطاء أعلاه.\n";
}

// حفظ النتائج في ملف
$logFile = 'test_results_' . date('Y-m-d_H-i-s') . '.json';
file_put_contents($logFile, json_encode($testResults, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));
echo "\nتم حفظ النتائج في: $logFile\n";
?> 