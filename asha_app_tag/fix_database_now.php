<?php
// إصلاح فوري لقاعدة البيانات
header('Content-Type: text/html; charset=utf-8');

echo "<h1>إصلاح قاعدة البيانات</h1>";

try {
    // الاتصال بقاعدة البيانات
    $host = 'localhost';
    $dbname = 'asha_app_events';
    $username = 'root';
    $password = '';
    
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    echo "<p>✅ تم الاتصال بقاعدة البيانات بنجاح</p>";
    
    // التحقق من وجود العمود
    $checkQuery = "SHOW COLUMNS FROM users LIKE 'profile_image'";
    $stmt = $pdo->prepare($checkQuery);
    $stmt->execute();
    $columnExists = $stmt->rowCount() > 0;
    
    if (!$columnExists) {
        echo "<p>🔧 إضافة عمود profile_image...</p>";
        
        // إضافة العمود
        $addColumnQuery = "ALTER TABLE users ADD COLUMN profile_image VARCHAR(255) DEFAULT NULL AFTER website";
        $pdo->exec($addColumnQuery);
        echo "<p>✅ تم إضافة عمود profile_image</p>";
        
        // إضافة عمود cover_image
        $addCoverQuery = "ALTER TABLE users ADD COLUMN cover_image VARCHAR(255) DEFAULT NULL AFTER profile_image";
        $pdo->exec($addCoverQuery);
        echo "<p>✅ تم إضافة عمود cover_image</p>";
        
        // تحديث البيانات
        $updateQuery = "UPDATE users SET profile_image = 'default_avatar.jpg' WHERE profile_image IS NULL";
        $pdo->exec($updateQuery);
        echo "<p>✅ تم تحديث البيانات</p>";
        
    } else {
        echo "<p>ℹ️ الأعمدة موجودة بالفعل</p>";
    }
    
    // التحقق من البيانات
    $checkDataQuery = "SELECT COUNT(*) as total_users, COUNT(profile_image) as users_with_image FROM users";
    $stmt = $pdo->prepare($checkDataQuery);
    $stmt->execute();
    $data = $stmt->fetch(PDO::FETCH_ASSOC);
    
    echo "<h2>نتائج الإصلاح:</h2>";
    echo "<p>📊 إجمالي المستخدمين: " . $data['total_users'] . "</p>";
    echo "<p>📊 المستخدمين مع الصور: " . $data['users_with_image'] . "</p>";
    
    // اختبار استعلام API
    echo "<h2>اختبار API:</h2>";
    
    $testQuery = "SELECT DISTINCT
                    u.id,
                    u.name,
                    u.email,
                    u.phone,
                    u.address,
                    'default_avatar.jpg' as profile_image,
                    u.rating,
                    u.total_reviews,
                    u.is_verified,
                    u.created_at,
                    u.user_type,
                    COUNT(s.id) as services_count
                FROM users u
                LEFT JOIN services s ON u.id = s.provider_id AND s.is_active = 1
                WHERE u.user_type = 'provider' AND u.is_active = 1
                GROUP BY u.id, u.name, u.email, u.phone, u.address, 
                         u.rating, u.total_reviews, u.is_verified, u.created_at, u.user_type
                LIMIT 5";
    
    $testStmt = $pdo->prepare($testQuery);
    $testStmt->execute();
    $testResults = $testStmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo "<p>✅ تم اختبار الاستعلام بنجاح</p>";
    echo "<p>📊 عدد النتائج: " . count($testResults) . "</p>";
    
    echo "<h2 style='color: green;'>🎉 تم إصلاح قاعدة البيانات بنجاح!</h2>";
    echo "<p>يمكنك الآن إعادة تشغيل التطبيق</p>";
    
} catch (PDOException $e) {
    echo "<p style='color: red;'>❌ خطأ: " . $e->getMessage() . "</p>";
    echo "<p>تأكد من:</p>";
    echo "<ul>";
    echo "<li>تشغيل خادم MySQL</li>";
    echo "<li>وجود قاعدة البيانات 'asha_app_events'</li>";
    echo "<li>صحة بيانات الاتصال (اسم المستخدم وكلمة المرور)</li>";
    echo "</ul>";
}
?> 