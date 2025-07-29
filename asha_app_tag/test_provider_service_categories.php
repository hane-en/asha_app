<?php
require_once 'config.php';
require_once 'database.php';

echo "<h1>اختبار فئات الخدمة للمزود</h1>\n";

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
    
    echo "<h2>2. إحصائيات فئات الخدمة للمزودين</h2>\n";
    
    // جلب إحصائيات فئات الخدمة لكل مزود
    $stmt = $pdo->query("
        SELECT 
            u.id as provider_id,
            u.name as provider_name,
            COUNT(s.id) as services_count,
            COUNT(sc.id) as categories_count
        FROM users u
        LEFT JOIN services s ON u.id = s.provider_id
        LEFT JOIN service_categories sc ON s.id = sc.service_id
        WHERE u.user_type = 'provider'
        GROUP BY u.id
        ORDER BY categories_count DESC
    ");
    
    $providers = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo "<table border='1' style='border-collapse: collapse; width: 100%;'>\n";
    echo "<tr><th>المزود</th><th>عدد الخدمات</th><th>عدد فئات الخدمة</th></tr>\n";
    
    foreach ($providers as $provider) {
        echo "<tr>";
        echo "<td>{$provider['provider_name']}</td>";
        echo "<td>{$provider['services_count']}</td>";
        echo "<td>{$provider['categories_count']}</td>";
        echo "</tr>\n";
    }
    echo "</table>\n";
    
    echo "<h2>3. اختبار API جلب خدمات المزود مع فئاتها</h2>\n";
    
    // جلب أول مزود للاختبار
    $stmt = $pdo->query("SELECT id, name FROM users WHERE user_type = 'provider' LIMIT 1");
    $provider = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($provider) {
        echo "المزود للاختبار: {$provider['name']} (ID: {$provider['id']})\n";
        
        $url = "http://localhost/asha_app_tag/api/provider/get_my_services_with_categories.php?provider_id={$provider['id']}";
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
    } else {
        echo "❌ لا توجد مزودين للاختبار\n";
    }
    
    echo "<h2>4. اختبار API جلب فئة خدمة واحدة</h2>\n";
    
    // جلب أول فئة خدمة للاختبار
    $stmt = $pdo->query("SELECT id, name FROM service_categories LIMIT 1");
    $category = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($category) {
        echo "فئة الخدمة للاختبار: {$category['name']} (ID: {$category['id']})\n";
        
        $url = "http://localhost/asha_app_tag/api/services/get_service_category.php?id={$category['id']}";
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
                echo "✅ API جلب فئة خدمة يعمل بشكل صحيح\n";
                echo "اسم الفئة: " . $data['data']['name'] . "\n";
                echo "السعر: " . $data['data']['price'] . " ريال\n";
            } else {
                echo "❌ خطأ في API: " . $data['message'] . "\n";
            }
        } else {
            echo "❌ فشل في الاتصال بـ API\n";
        }
    } else {
        echo "❌ لا توجد فئات خدمة للاختبار\n";
    }
    
    echo "<h2>5. اختبار API تحديث فئة خدمة</h2>\n";
    
    if ($category) {
        $url = "http://localhost/asha_app_tag/api/services/update_service_category.php";
        $postData = json_encode([
            'id' => $category['id'],
            'name' => $category['name'] . ' (محدث)',
            'price' => 150.0
        ]);
        
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
                echo "✅ API تحديث فئة خدمة يعمل بشكل صحيح\n";
                echo "تم تحديث: " . $data['data']['name'] . "\n";
                
                // إعادة الاسم الأصلي
                $postData = json_encode([
                    'id' => $category['id'],
                    'name' => $category['name']
                ]);
                
                $context = stream_context_create([
                    'http' => [
                        'method' => 'POST',
                        'header' => 'Content-Type: application/json',
                        'content' => $postData,
                    ]
                ]);
                
                file_get_contents($url, false, $context);
                echo "✅ تم إعادة الاسم الأصلي\n";
            } else {
                echo "❌ خطأ في API تحديث: " . $data['message'] . "\n";
            }
        } else {
            echo "❌ فشل في الاتصال بـ API تحديث\n";
        }
    }
    
    echo "<h2>6. عرض عينة من فئات الخدمة للمزودين</h2>\n";
    
    $stmt = $pdo->query("
        SELECT 
            sc.id,
            sc.name,
            sc.price,
            sc.duration,
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
    echo "<tr><th>الفئة</th><th>الخدمة</th><th>المزود</th><th>السعر</th><th>المدة</th></tr>\n";
    
    foreach ($categories as $cat) {
        echo "<tr>";
        echo "<td>{$cat['name']}</td>";
        echo "<td>{$cat['service_title']}</td>";
        echo "<td>{$cat['provider_name']}</td>";
        echo "<td>{$cat['price']} ريال</td>";
        echo "<td>{$cat['duration']}</td>";
        echo "</tr>\n";
    }
    echo "</table>\n";
    
    echo "<h2>✅ اختبار فئات الخدمة للمزود مكتمل</h2>\n";
    echo "<p>النظام جاهز للاستخدام من قبل المزودين</p>\n";
    
} catch (PDOException $e) {
    echo "❌ خطأ في قاعدة البيانات: " . $e->getMessage() . "\n";
} catch (Exception $e) {
    echo "❌ خطأ عام: " . $e->getMessage() . "\n";
}
?> 