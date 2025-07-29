<?php
require_once 'config.php';
require_once 'database.php';

echo "<h1>التحقق من أدوار المستخدمين</h1>\n";

try {
    $pdo = new PDO("mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=utf8mb4", DB_USER, DB_PASS);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // جلب جميع المستخدمين مع أدوارهم
    $query = "SELECT id, name, email, user_type, is_active, is_verified FROM users ORDER BY id";
    $stmt = $pdo->prepare($query);
    $stmt->execute();
    $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo "إجمالي المستخدمين: " . count($users) . "\n\n";
    
    $adminCount = 0;
    $providerCount = 0;
    $customerCount = 0;
    $otherCount = 0;
    
    foreach ($users as $user) {
        echo "ID: {$user['id']} | الاسم: {$user['name']} | الدور: {$user['user_type']} | نشط: " . ($user['is_active'] ? 'نعم' : 'لا') . " | مؤكد: " . ($user['is_verified'] ? 'نعم' : 'لا') . "\n";
        
        switch ($user['user_type']) {
            case 'admin':
                $adminCount++;
                break;
            case 'provider':
                $providerCount++;
                break;
            case 'customer':
                $customerCount++;
                break;
            default:
                $otherCount++;
                break;
        }
    }
    
    echo "\n=== الإحصائيات ===\n";
    echo "المديرين: $adminCount\n";
    echo "مزودي الخدمات: $providerCount\n";
    echo "العملاء: $customerCount\n";
    echo "أخرى: $otherCount\n";
    
} catch (Exception $e) {
    echo "❌ خطأ: " . $e->getMessage() . "\n";
}
?> 