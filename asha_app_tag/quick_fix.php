<?php
// إصلاح سريع لقاعدة البيانات
header('Content-Type: text/html; charset=utf-8');

try {
    // الاتصال بقاعدة البيانات
    $host = 'localhost';
    $dbname = 'asha_app_events';
    $username = 'root';
    $password = '';
    
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    echo "<h2>إصلاح قاعدة البيانات</h2>";
    
    // التحقق من وجود العمود
    $checkQuery = "SHOW COLUMNS FROM users LIKE 'profile_image'";
    $stmt = $pdo->prepare($checkQuery);
    $stmt->execute();
    $columnExists = $stmt->rowCount() > 0;
    
    if (!$columnExists) {
        echo "<p>إضافة عمود profile_image...</p>";
        
        // إضافة العمود
        $addColumnQuery = "ALTER TABLE users ADD COLUMN profile_image VARCHAR(255) DEFAULT NULL AFTER website";
        $pdo->exec($addColumnQuery);
        
        // إضافة عمود cover_image
        $addCoverQuery = "ALTER TABLE users ADD COLUMN cover_image VARCHAR(255) DEFAULT NULL AFTER profile_image";
        $pdo->exec($addCoverQuery);
        
        // تحديث البيانات
        $updateQuery = "UPDATE users SET profile_image = 'default_avatar.jpg' WHERE profile_image IS NULL";
        $pdo->exec($updateQuery);
        
        echo "<p style='color: green;'>✅ تم إضافة الأعمدة بنجاح!</p>";
    } else {
        echo "<p style='color: blue;'>ℹ️ الأعمدة موجودة بالفعل</p>";
    }
    
    // التحقق من البيانات
    $checkDataQuery = "SELECT COUNT(*) as total_users, COUNT(profile_image) as users_with_image FROM users";
    $stmt = $pdo->prepare($checkDataQuery);
    $stmt->execute();
    $data = $stmt->fetch(PDO::FETCH_ASSOC);
    
    echo "<p>إجمالي المستخدمين: " . $data['total_users'] . "</p>";
    echo "<p>المستخدمين مع الصور: " . $data['users_with_image'] . "</p>";
    
    echo "<p style='color: green;'>✅ تم إصلاح قاعدة البيانات بنجاح!</p>";
    echo "<p>يمكنك الآن إعادة تشغيل التطبيق</p>";
    
} catch (PDOException $e) {
    echo "<p style='color: red;'>❌ خطأ: " . $e->getMessage() . "</p>";
}
?> 