<?php
/**
 * اختبار تسجيل المستخدمين
 */

require_once 'config.php';
require_once 'database.php';
require_once 'auth.php';

// إيقاف عرض الأخطاء
error_reporting(0);
ini_set('display_errors', 0);

echo "<h2>اختبار تسجيل المستخدمين</h2>";

try {
    $db = new Database();
    $db->connect();
    echo "✅ الاتصال بقاعدة البيانات نجح<br>";
    
    // فحص جدول المستخدمين
    $users = $db->select("DESCRIBE users");
    echo "<h3>هيكل جدول المستخدمين:</h3>";
    echo "<table border='1'>";
    echo "<tr><th>Field</th><th>Type</th><th>Null</th><th>Key</th><th>Default</th></tr>";
    foreach ($users as $user) {
        echo "<tr>";
        echo "<td>{$user['Field']}</td>";
        echo "<td>{$user['Type']}</td>";
        echo "<td>{$user['Null']}</td>";
        echo "<td>{$user['Key']}</td>";
        echo "<td>{$user['Default']}</td>";
        echo "</tr>";
    }
    echo "</table>";
    
    // اختبار البيانات
    $testData = [
        'name' => 'Test User',
        'email' => 'test@example.com',
        'phone' => '123456789',
        'password' => 'password123',
        'user_type' => 'user',
        'is_yemeni_account' => false
    ];
    
    echo "<h3>اختبار البيانات:</h3>";
    echo "الاسم: {$testData['name']}<br>";
    echo "البريد: {$testData['email']}<br>";
    echo "الهاتف: {$testData['phone']}<br>";
    echo "نوع المستخدم: {$testData['user_type']}<br>";
    
    // اختبار التحقق من البريد الإلكتروني
    echo "<h3>اختبار التحقق:</h3>";
    echo "صحة البريد الإلكتروني: " . (validateEmail($testData['email']) ? '✅ صحيح' : '❌ خطأ') . "<br>";
    echo "صحة الهاتف: " . (validatePhone($testData['phone']) ? '✅ صحيح' : '❌ خطأ') . "<br>";
    echo "طول كلمة المرور: " . (strlen($testData['password']) >= 6 ? '✅ مناسب' : '❌ قصير') . "<br>";
    
    // اختبار وجود المستخدم
    $auth = new Auth();
    $exists = $db->exists('users', 'email = :email OR phone = :phone', [
        'email' => $testData['email'],
        'phone' => $testData['phone']
    ]);
    echo "المستخدم موجود: " . ($exists ? '✅ نعم' : '❌ لا') . "<br>";
    
} catch (Exception $e) {
    echo "❌ خطأ: " . $e->getMessage() . "<br>";
}
?> 