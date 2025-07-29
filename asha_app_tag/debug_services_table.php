<?php
require_once 'config.php';
require_once 'database.php';

echo "<h1>فحص جدول الخدمات</h1>\n";

try {
    $pdo = new PDO("mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=utf8mb4", DB_USER, DB_PASS);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // فحص وجود الجدول
    $stmt = $pdo->query("SHOW TABLES LIKE 'services'");
    if ($stmt->rowCount() > 0) {
        echo "✅ جدول services موجود\n";
        
        // فحص عدد الصفوف
        $stmt = $pdo->query("SELECT COUNT(*) as count FROM services");
        $count = $stmt->fetch(PDO::FETCH_ASSOC)['count'];
        echo "📊 عدد الخدمات: $count\n";
        
        // فحص الخدمات النشطة
        $stmt = $pdo->query("SELECT COUNT(*) as count FROM services WHERE is_active = 1");
        $activeCount = $stmt->fetch(PDO::FETCH_ASSOC)['count'];
        echo "✅ الخدمات النشطة: $activeCount\n";
        
        // عرض عينة من البيانات
        if ($count > 0) {
            echo "\n<h2>عينة من الخدمات:</h2>\n";
            $stmt = $pdo->query("SELECT id, title, category_id, provider_id, is_active FROM services LIMIT 5");
            $services = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            echo "<table border='1' style='border-collapse: collapse; width: 100%;'>\n";
            echo "<tr><th>ID</th><th>العنوان</th><th>فئة ID</th><th>مزود ID</th><th>نشط</th></tr>\n";
            
            foreach ($services as $service) {
                echo "<tr>";
                echo "<td>{$service['id']}</td>";
                echo "<td>{$service['title']}</td>";
                echo "<td>{$service['category_id']}</td>";
                echo "<td>{$service['provider_id']}</td>";
                echo "<td>" . ($service['is_active'] ? 'نعم' : 'لا') . "</td>";
                echo "</tr>\n";
            }
            echo "</table>\n";
        }
        
        // فحص الفئات
        echo "\n<h2>فحص الفئات:</h2>\n";
        $stmt = $pdo->query("SELECT COUNT(*) as count FROM categories");
        $categoryCount = $stmt->fetch(PDO::FETCH_ASSOC)['count'];
        echo "📊 عدد الفئات: $categoryCount\n";
        
        if ($categoryCount > 0) {
            $stmt = $pdo->query("SELECT id, name FROM categories LIMIT 5");
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
        
        // فحص المستخدمين
        echo "\n<h2>فحص المستخدمين:</h2>\n";
        $stmt = $pdo->query("SELECT COUNT(*) as count FROM users");
        $userCount = $stmt->fetch(PDO::FETCH_ASSOC)['count'];
        echo "📊 عدد المستخدمين: $userCount\n";
        
        // اختبار الاستعلام المعقد
        echo "\n<h2>اختبار الاستعلام المعقد:</h2>\n";
        $query = "
            SELECT 
                s.*,
                c.name as category_name,
                u.name as provider_name
            FROM services s
            LEFT JOIN categories c ON s.category_id = c.id
            LEFT JOIN users u ON s.provider_id = u.id
            WHERE s.is_active = 1
            ORDER BY s.created_at DESC 
            LIMIT 5
        ";
        
        try {
            $stmt = $pdo->query($query);
            $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
            echo "✅ الاستعلام المعقد نجح - عدد النتائج: " . count($results) . "\n";
            
            if (count($results) > 0) {
                echo "<table border='1' style='border-collapse: collapse; width: 100%;'>\n";
                echo "<tr><th>ID</th><th>العنوان</th><th>الفئة</th><th>المزود</th></tr>\n";
                
                foreach ($results as $result) {
                    echo "<tr>";
                    echo "<td>{$result['id']}</td>";
                    echo "<td>{$result['title']}</td>";
                    echo "<td>{$result['category_name']}</td>";
                    echo "<td>{$result['provider_name']}</td>";
                    echo "</tr>\n";
                }
                echo "</table>\n";
            }
        } catch (Exception $e) {
            echo "❌ خطأ في الاستعلام المعقد: " . $e->getMessage() . "\n";
        }
        
    } else {
        echo "❌ جدول services غير موجود\n";
    }
    
} catch (PDOException $e) {
    echo "<h2>❌ خطأ في قاعدة البيانات</h2>\n";
    echo "<p>الخطأ: " . $e->getMessage() . "</p>\n";
} catch (Exception $e) {
    echo "<h2>❌ خطأ عام</h2>\n";
    echo "<p>الخطأ: " . $e->getMessage() . "</p>\n";
}
?> 