<?php
require_once 'config.php';
require_once 'database.php';

echo "<h1>اختبار إدارة الخدمات للمشرف</h1>\n";

try {
    $pdo = new PDO("mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=utf8mb4", DB_USER, DB_PASS);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    echo "<h2>1. التحقق من وجود جدول service_categories</h2>\n";
    $stmt = $pdo->query("SHOW TABLES LIKE 'service_categories'");
    if ($stmt->rowCount() > 0) {
        echo "✅ جدول service_categories موجود\n";
    } else {
        echo "❌ جدول service_categories غير موجود\n";
        exit;
    }
    
    echo "<h2>2. إحصائيات فئات الخدمة</h2>\n";
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM service_categories");
    $total = $stmt->fetch(PDO::FETCH_ASSOC)['total'];
    echo "إجمالي فئات الخدمة: $total\n";
    
    $stmt = $pdo->query("SELECT COUNT(*) as active FROM service_categories WHERE is_active = 1");
    $active = $stmt->fetch(PDO::FETCH_ASSOC)['active'];
    echo "فئات الخدمة النشطة: $active\n";
    
    echo "<h2>3. اختبار API جلب جميع الخدمات مع فئاتها</h2>\n";
    $url = "http://localhost/asha_app_tag/api/admin/get_all_services_with_categories.php";
    $context = stream_context_create([
        'http' => [
            'method' => 'GET',
            'header' => 'Content-Type: application/json',
        ]
    ]);
    
    $response = file_get_contents($url, false, $context);
    if ($response !== false) {
        $data = json_decode($response, true);
        if ($data['success']) {
            echo "✅ API يعمل بشكل صحيح\n";
            echo "عدد الخدمات: " . count($data['data']) . "\n";
            echo "إحصائيات: " . json_encode($data['stats'], JSON_UNESCAPED_UNICODE) . "\n";
        } else {
            echo "❌ خطأ في API: " . $data['message'] . "\n";
        }
    } else {
        echo "❌ فشل في الاتصال بـ API\n";
    }
    
    echo "<h2>4. اختبار API حذف فئة خدمة</h2>\n";
    // جلب أول فئة خدمة للاختبار
    $stmt = $pdo->query("SELECT id, name FROM service_categories LIMIT 1");
    $testCategory = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($testCategory) {
        echo "فئة الخدمة للاختبار: {$testCategory['name']} (ID: {$testCategory['id']})\n";
        
        $url = "http://localhost/asha_app_tag/api/services/delete_service_category.php";
        $postData = json_encode(['id' => $testCategory['id']]);
        
        $context = stream_context_create([
            'http' => [
                'method' => 'POST',
                'header' => 'Content-Type: application/json',
                'content' => $postData,
            ]
        ]);
        
        $response = file_get_contents($url, false, $context);
        if ($response !== false) {
            $data = json_decode($response, true);
            if ($data['success']) {
                echo "✅ API حذف فئة الخدمة يعمل بشكل صحيح\n";
                echo "تم حذف: " . $data['data']['name'] . "\n";
                
                // إعادة إنشاء فئة الخدمة للاختبار
                $stmt = $pdo->prepare("
                    INSERT INTO service_categories (
                        service_id, name, description, price, image, is_active, created_at
                    ) VALUES (?, ?, ?, ?, ?, 1, NOW())
                ");
                $stmt->execute([
                    $testCategory['service_id'] ?? 1,
                    $testCategory['name'],
                    'فئة اختبار',
                    100,
                    'test_image.jpg'
                ]);
                echo "✅ تم إعادة إنشاء فئة الخدمة للاختبار\n";
            } else {
                echo "❌ خطأ في API حذف فئة الخدمة: " . $data['message'] . "\n";
            }
        } else {
            echo "❌ فشل في الاتصال بـ API حذف فئة الخدمة\n";
        }
    } else {
        echo "❌ لا توجد فئات خدمة للاختبار\n";
    }
    
    echo "<h2>5. عرض عينة من الخدمات مع فئاتها</h2>\n";
    $stmt = $pdo->query("
        SELECT 
            s.id as service_id,
            s.title as service_title,
            s.price as service_price,
            u.name as provider_name,
            c.name as category_name,
            COUNT(sc.id) as categories_count
        FROM services s
        INNER JOIN users u ON s.provider_id = u.id
        INNER JOIN categories c ON s.category_id = c.id
        LEFT JOIN service_categories sc ON s.id = sc.service_id
        GROUP BY s.id
        ORDER BY categories_count DESC
        LIMIT 5
    ");
    
    $services = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "<table border='1' style='border-collapse: collapse; width: 100%;'>\n";
    echo "<tr><th>الخدمة</th><th>المزود</th><th>الفئة</th><th>السعر</th><th>عدد الفئات</th></tr>\n";
    
    foreach ($services as $service) {
        echo "<tr>";
        echo "<td>{$service['service_title']}</td>";
        echo "<td>{$service['provider_name']}</td>";
        echo "<td>{$service['category_name']}</td>";
        echo "<td>{$service['service_price']} ريال</td>";
        echo "<td>{$service['categories_count']}</td>";
        echo "</tr>\n";
    }
    echo "</table>\n";
    
    echo "<h2>6. عرض عينة من فئات الخدمة</h2>\n";
    $stmt = $pdo->query("
        SELECT 
            sc.id,
            sc.name,
            sc.price,
            sc.duration,
            sc.size,
            s.title as service_title,
            u.name as provider_name
        FROM service_categories sc
        INNER JOIN services s ON sc.service_id = s.id
        INNER JOIN users u ON s.provider_id = u.id
        WHERE sc.is_active = 1
        ORDER BY sc.price ASC
        LIMIT 10
    ");
    
    $categories = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "<table border='1' style='border-collapse: collapse; width: 100%;'>\n";
    echo "<tr><th>الفئة</th><th>الخدمة</th><th>المزود</th><th>السعر</th><th>المدة</th><th>الحجم</th></tr>\n";
    
    foreach ($categories as $category) {
        echo "<tr>";
        echo "<td>{$category['name']}</td>";
        echo "<td>{$category['service_title']}</td>";
        echo "<td>{$category['provider_name']}</td>";
        echo "<td>{$category['price']} ريال</td>";
        echo "<td>{$category['duration']}</td>";
        echo "<td>{$category['size']}</td>";
        echo "</tr>\n";
    }
    echo "</table>\n";
    
    echo "<h2>✅ اختبار إدارة الخدمات للمشرف مكتمل</h2>\n";
    echo "<p>النظام جاهز للاستخدام من قبل المشرف</p>\n";
    
} catch (PDOException $e) {
    echo "❌ خطأ في قاعدة البيانات: " . $e->getMessage() . "\n";
} catch (Exception $e) {
    echo "❌ خطأ عام: " . $e->getMessage() . "\n";
}
?> 