<?php
require_once 'config.php';
require_once 'database.php';

echo "<h1>تحقق من بيانات API المستخدمين</h1>\n";

try {
    $pdo = new PDO("mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=utf8mb4", DB_USER, DB_PASS);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // نفس الاستعلام المستخدم في API
    $query = "
        SELECT 
            id,
            name,
            email,
            phone,
            user_type as role,
            is_active,
            is_verified,
            created_at,
            last_login_at as last_login,
            '' as profile_image,
            city,
            address,
            bio
        FROM users
        ORDER BY created_at DESC
    ";
    
    $stmt = $pdo->prepare($query);
    $stmt->execute();
    $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo "إجمالي المستخدمين: " . count($users) . "\n\n";
    
    $admins = 0;
    $providers = 0;
    $customers = 0;
    
    foreach ($users as $user) {
        echo "ID: {$user['id']} | الاسم: {$user['name']} | الدور: {$user['role']}\n";
        
        switch ($user['role']) {
            case 'admin':
                $admins++;
                break;
            case 'provider':
                $providers++;
                break;
            case 'user':
                $customers++;
                break;
        }
    }
    
    echo "\n=== الإحصائيات ===\n";
    echo "المديرين: $admins\n";
    echo "مزودي الخدمات: $providers\n";
    echo "العملاء: $customers\n";
    
} catch (Exception $e) {
    echo "❌ خطأ: " . $e->getMessage() . "\n";
}
?> 