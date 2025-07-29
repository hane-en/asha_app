<?php
// ملف اختبار مبسط لفئات الخدمة
require_once 'config.php';

echo "=== اختبار فئات الخدمة ===\n\n";

try {
    $pdo = new PDO("mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=utf8mb4", DB_USER, DB_PASS);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    echo "1. التحقق من وجود جدول فئات الخدمة...\n";
    $stmt = $pdo->query("SHOW TABLES LIKE 'service_categories'");
    if ($stmt->rowCount() > 0) {
        echo "✅ جدول فئات الخدمة موجود\n";
    } else {
        echo "❌ جدول فئات الخدمة غير موجود\n";
        exit();
    }
    
    echo "\n2. عدد فئات الخدمة في قاعدة البيانات...\n";
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM service_categories");
    $count = $stmt->fetch()['count'];
    echo "عدد فئات الخدمة: $count\n";
    
    echo "\n3. عرض فئات الخدمة للخدمة الأولى...\n";
    $stmt = $pdo->query("
        SELECT 
            sc.id,
            sc.name,
            sc.price,
            sc.size,
            sc.duration,
            s.title as service_title
        FROM service_categories sc
        INNER JOIN services s ON sc.service_id = s.id
        WHERE sc.service_id = 1
        ORDER BY sc.price ASC
        LIMIT 3
    ");
    
    $categories = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    if (empty($categories)) {
        echo "❌ لا توجد فئات خدمة للخدمة الأولى\n";
    } else {
        echo "✅ تم العثور على " . count($categories) . " فئة خدمة للخدمة الأولى:\n";
        foreach ($categories as $category) {
            echo "   - {$category['name']}: {$category['price']} ريال ({$category['size']})\n";
        }
    }
    
    echo "\n4. إحصائيات فئات الخدمة...\n";
    $stmt = $pdo->query("
        SELECT 
            s.title,
            COUNT(sc.id) as categories_count
        FROM services s
        LEFT JOIN service_categories sc ON s.id = sc.service_id
        GROUP BY s.id, s.title
        ORDER BY categories_count DESC
        LIMIT 5
    ");
    
    $stats = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    foreach ($stats as $stat) {
        echo "   - {$stat['title']}: {$stat['categories_count']} فئة\n";
    }
    
    echo "\n5. نطاق الأسعار...\n";
    $stmt = $pdo->query("
        SELECT 
            MIN(price) as min_price,
            MAX(price) as max_price,
            AVG(price) as avg_price
        FROM service_categories
        WHERE is_active = 1
    ");
    
    $priceStats = $stmt->fetch(PDO::FETCH_ASSOC);
    
    echo "   - أقل سعر: {$priceStats['min_price']} ريال\n";
    echo "   - أعلى سعر: {$priceStats['max_price']} ريال\n";
    echo "   - متوسط السعر: " . round($priceStats['avg_price'], 2) . " ريال\n";
    
    echo "\n✅ اختبار فئات الخدمة مكتمل بنجاح!\n";
    
} catch (PDOException $e) {
    echo "❌ خطأ في قاعدة البيانات: " . $e->getMessage() . "\n";
} catch (Exception $e) {
    echo "❌ خطأ عام: " . $e->getMessage() . "\n";
}
?> 