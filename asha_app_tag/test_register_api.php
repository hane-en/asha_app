<?php
/**
 * اختبار API التسجيل
 */

require_once 'config.php';
require_once 'database.php';
require_once 'auth.php';

// إيقاف عرض الأخطاء
error_reporting(0);
ini_set('display_errors', 0);

echo "<h2>اختبار API التسجيل</h2>";

try {
    $db = new Database();
    $db->connect();
    echo "✅ الاتصال بقاعدة البيانات نجح<br>";
    
    // بيانات الاختبار
    $testData = [
        'name' => 'Test User',
        'email' => 'test@example.com',
        'phone' => '123456789',
        'password' => 'password123',
        'user_type' => 'user',
        'is_yemeni_account' => false
    ];
    
    echo "<h3>اختبار التسجيل:</h3>";
    echo "الاسم: {$testData['name']}<br>";
    echo "البريد: {$testData['email']}<br>";
    echo "الهاتف: {$testData['phone']}<br>";
    echo "نوع المستخدم: {$testData['user_type']}<br>";
    
    // اختبار التسجيل
    $auth = new Auth();
    $result = $auth->register($testData);
    
    if ($result) {
        echo "✅ تم التسجيل بنجاح!<br>";
        echo "معرف المستخدم: {$result['user_id']}<br>";
        echo "الرسالة: {$result['message']}<br>";
    } else {
        echo "❌ فشل في التسجيل<br>";
    }
    
} catch (Exception $e) {
    echo "❌ خطأ: " . $e->getMessage() . "<br>";
}
?> 