<?php
// ملف اختبار فئات الخدمة
require_once 'config.php';
require_once 'database.php';

echo "<h1>اختبار فئات الخدمة</h1>";

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    echo "<h2>1. التحقق من وجود جدول فئات الخدمة</h2>";
    $stmt = $pdo->query("SHOW TABLES LIKE 'service_categories'");
    if ($stmt->rowCount() > 0) {
        echo "✅ جدول فئات الخدمة موجود<br>";
    } else {
        echo "❌ جدول فئات الخدمة غير موجود<br>";
        exit();
    }
    
    echo "<h2>2. عدد فئات الخدمة في قاعدة البيانات</h2>";
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM service_categories");
    $count = $stmt->fetch()['count'];
    echo "عدد فئات الخدمة: $count<br>";
    
    echo "<h2>3. عرض فئات الخدمة للخدمة الأولى</h2>";
    $stmt = $pdo->query("
        SELECT 
            sc.*,
            s.title as service_title,
            u.name as provider_name
        FROM service_categories sc
        INNER JOIN services s ON sc.service_id = s.id
        INNER JOIN users u ON s.provider_id = u.id
        WHERE sc.service_id = 1
        ORDER BY sc.price ASC
        LIMIT 5
    ");
    
    $categories = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    if (empty($categories)) {
        echo "❌ لا توجد فئات خدمة للخدمة الأولى<br>";
    } else {
        echo "✅ تم العثور على " . count($categories) . " فئة خدمة للخدمة الأولى<br>";
        echo "<table border='1' style='border-collapse: collapse; margin: 10px 0;'>";
        echo "<tr><th>ID</th><th>الاسم</th><th>السعر</th><th>الحجم</th><th>المدة</th><th>المواد</th></tr>";
        
        foreach ($categories as $category) {
            echo "<tr>";
            echo "<td>{$category['id']}</td>";
            echo "<td>{$category['name']}</td>";
            echo "<td>{$category['price']} ريال</td>";
            echo "<td>{$category['size']}</td>";
            echo "<td>{$category['duration']}</td>";
            echo "<td>{$category['materials']}</td>";
            echo "</tr>";
        }
        echo "</table>";
    }
    
    echo "<h2>4. اختبار API جلب فئات الخدمة</h2>";
    $service_id = 1;
    $url = "http://localhost/asha_app_tag/api/services/get_service_categories.php?service_id=$service_id";
    
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_TIMEOUT, 30);
    
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    
    if ($httpCode == 200) {
        $data = json_decode($response, true);
        if ($data['success']) {
            echo "✅ API يعمل بشكل صحيح<br>";
            echo "عدد فئات الخدمة: " . count($data['data']) . "<br>";
            echo "رسالة: " . $data['message'] . "<br>";
        } else {
            echo "❌ API يعمل ولكن هناك خطأ: " . $data['message'] . "<br>";
        }
    } else {
        echo "❌ خطأ في الاتصال بـ API: HTTP $httpCode<br>";
    }
    
    echo "<h2>5. إحصائيات فئات الخدمة</h2>";
    
    // عدد فئات الخدمة لكل خدمة
    $stmt = $pdo->query("
        SELECT 
            s.id,
            s.title,
            COUNT(sc.id) as categories_count
        FROM services s
        LEFT JOIN service_categories sc ON s.id = sc.service_id
        GROUP BY s.id, s.title
        ORDER BY categories_count DESC
        LIMIT 10
    ");
    
    $stats = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo "<table border='1' style='border-collapse: collapse; margin: 10px 0;'>";
    echo "<tr><th>معرف الخدمة</th><th>اسم الخدمة</th><th>عدد فئات الخدمة</th></tr>";
    
    foreach ($stats as $stat) {
        echo "<tr>";
        echo "<td>{$stat['id']}</td>";
        echo "<td>{$stat['title']}</td>";
        echo "<td>{$stat['categories_count']}</td>";
        echo "</tr>";
    }
    echo "</table>";
    
    echo "<h2>6. نطاق الأسعار في فئات الخدمة</h2>";
    $stmt = $pdo->query("
        SELECT 
            MIN(price) as min_price,
            MAX(price) as max_price,
            AVG(price) as avg_price,
            COUNT(*) as total_categories
        FROM service_categories
        WHERE is_active = 1
    ");
    
    $priceStats = $stmt->fetch(PDO::FETCH_ASSOC);
    
    echo "أقل سعر: {$priceStats['min_price']} ريال<br>";
    echo "أعلى سعر: {$priceStats['max_price']} ريال<br>";
    echo "متوسط السعر: " . round($priceStats['avg_price'], 2) . " ريال<br>";
    echo "إجمالي فئات الخدمة: {$priceStats['total_categories']}<br>";
    
    echo "<h2>7. اختبار إضافة فئة خدمة جديدة</h2>";
    
    // محاولة إضافة فئة خدمة جديدة
    $testData = [
        'service_id' => 1,
        'name' => 'فئة اختبار',
        'description' => 'وصف فئة اختبار',
        'price' => 100.00,
        'image' => 'test_image.jpg',
        'size' => 'متوسط',
        'dimensions' => 'اختبار',
        'location' => 'صنعاء',
        'quantity' => 1,
        'duration' => 'ساعة واحدة',
        'materials' => 'مواد اختبار',
        'additional_features' => 'ميزات اختبار',
        'is_active' => 1
    ];
    
    $url = "http://localhost/asha_app_tag/api/services/add_service_category.php";
    
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($testData));
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Content-Type: application/json',
        'Accept: application/json'
    ]);
    curl_setopt($ch, CURLOPT_TIMEOUT, 30);
    
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    
    if ($httpCode == 200) {
        $data = json_decode($response, true);
        if ($data['success']) {
            echo "✅ تم إضافة فئة خدمة جديدة بنجاح<br>";
            echo "معرف فئة الخدمة الجديدة: " . $data['data']['id'] . "<br>";
        } else {
            echo "❌ فشل في إضافة فئة خدمة: " . $data['message'] . "<br>";
        }
    } else {
        echo "❌ خطأ في الاتصال بـ API الإضافة: HTTP $httpCode<br>";
    }
    
    echo "<h2>✅ اختبار فئات الخدمة مكتمل</h2>";
    
} catch (PDOException $e) {
    echo "❌ خطأ في قاعدة البيانات: " . $e->getMessage();
} catch (Exception $e) {
    echo "❌ خطأ عام: " . $e->getMessage();
}
?> 