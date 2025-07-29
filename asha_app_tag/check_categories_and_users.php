<?php
require_once 'config.php';
require_once 'database.php';

echo "<h1>فحص بيانات الفئات والمستخدمين</h1>\n";

try {
    $pdo = new PDO("mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=utf8mb4", DB_USER, DB_PASS);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // فحص جدول الفئات
    echo "<h2>فحص جدول الفئات:</h2>\n";
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM categories");
    $categoryCount = $stmt->fetch(PDO::FETCH_ASSOC)['count'];
    echo "📊 عدد الفئات: $categoryCount\n";
    
    if ($categoryCount > 0) {
        $stmt = $pdo->query("SELECT id, name FROM categories ORDER BY id");
        $categories = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        echo "<table border='1' style='border-collapse: collapse; width: 100%;'>\n";
        echo "<tr><th>ID</th><th>اسم الفئة</th></tr>\n";
        
        foreach ($categories as $category) {
            echo "<tr>";
            echo "<td>{$category['id']}</td>";
            echo "<td>{$category['name']}</td>";
            echo "</tr>\n";
        }
        echo "</table>\n";
    }
    
    // فحص جدول المستخدمين
    echo "<h2>فحص جدول المستخدمين:</h2>\n";
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM users");
    $userCount = $stmt->fetch(PDO::FETCH_ASSOC)['count'];
    echo "📊 عدد المستخدمين: $userCount\n";
    
    if ($userCount > 0) {
        $stmt = $pdo->query("SELECT id, name, email FROM users ORDER BY id LIMIT 10");
        $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        echo "<table border='1' style='border-collapse: collapse; width: 100%;'>\n";
        echo "<tr><th>ID</th><th>الاسم</th><th>البريد الإلكتروني</th></tr>\n";
        
        foreach ($users as $user) {
            echo "<tr>";
            echo "<td>{$user['id']}</td>";
            echo "<td>{$user['name']}</td>";
            echo "<td>{$user['email']}</td>";
            echo "</tr>\n";
        }
        echo "</table>\n";
    }
    
    // اختبار JOIN
    echo "<h2>اختبار JOIN:</h2>\n";
    $query = "
        SELECT 
            s.id,
            s.title,
            s.category_id,
            s.provider_id,
            COALESCE(c.name, 'غير محدد') as category_name,
            COALESCE(u.name, 'غير محدد') as provider_name
        FROM services s
        LEFT JOIN categories c ON s.category_id = c.id
        LEFT JOIN users u ON s.provider_id = u.id
        WHERE s.is_active = 1
        LIMIT 5
    ";
    
    try {
        $stmt = $pdo->query($query);
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo "✅ اختبار JOIN نجح - عدد النتائج: " . count($results) . "\n";
        
        if (count($results) > 0) {
            echo "<table border='1' style='border-collapse: collapse; width: 100%;'>\n";
            echo "<tr><th>ID</th><th>العنوان</th><th>فئة ID</th><th>مزود ID</th><th>اسم الفئة</th><th>اسم المزود</th></tr>\n";
            
            foreach ($results as $result) {
                echo "<tr>";
                echo "<td>{$result['id']}</td>";
                echo "<td>{$result['title']}</td>";
                echo "<td>{$result['category_id']}</td>";
                echo "<td>{$result['provider_id']}</td>";
                echo "<td>{$result['category_name']}</td>";
                echo "<td>{$result['provider_name']}</td>";
                echo "</tr>\n";
            }
            echo "</table>\n";
        }
    } catch (Exception $e) {
        echo "❌ خطأ في اختبار JOIN: " . $e->getMessage() . "\n";
    }
    
} catch (PDOException $e) {
    echo "<h2>❌ خطأ في قاعدة البيانات</h2>\n";
    echo "<p>الخطأ: " . $e->getMessage() . "</p>\n";
} catch (Exception $e) {
    echo "<h2>❌ خطأ عام</h2>\n";
    echo "<p>الخطأ: " . $e->getMessage() . "</p>\n";
}
?> 