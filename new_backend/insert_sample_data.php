<?php
/**
 * ملف إدخال البيانات الافتراضية
 * Sample Data Insertion Script
 */

require_once 'config.php';

header('Content-Type: text/html; charset=utf-8');

echo "<h1>إدخال البيانات الافتراضية - Asha App</h1>";
echo "<h2>Sample Data Insertion - Asha App</h2>";

try {
    $pdo = getDatabaseConnection();
    
    if (!$pdo) {
        throw new Exception("فشل الاتصال بقاعدة البيانات");
    }
    
    echo "<p>✅ تم الاتصال بقاعدة البيانات بنجاح</p>";
    
    // قراءة ملف البيانات الافتراضية
    $sqlFile = 'sample_data.sql';
    
    if (!file_exists($sqlFile)) {
        throw new Exception("ملف البيانات الافتراضية غير موجود: $sqlFile");
    }
    
    $sqlContent = file_get_contents($sqlFile);
    
    if (!$sqlContent) {
        throw new Exception("فشل في قراءة ملف البيانات الافتراضية");
    }
    
    echo "<p>✅ تم قراءة ملف البيانات الافتراضية</p>";
    
    // تقسيم SQL إلى أوامر منفصلة
    $statements = array_filter(
        array_map('trim', 
            explode(';', $sqlContent)
        ),
        function($stmt) {
            return !empty($stmt) && !preg_match('/^--/', $stmt);
        }
    );
    
    $totalStatements = count($statements);
    $successCount = 0;
    $errorCount = 0;
    
    echo "<h3>بدء إدخال البيانات...</h3>";
    echo "<ul>";
    
    foreach ($statements as $index => $statement) {
        try {
            if (!empty(trim($statement))) {
                $pdo->exec($statement);
                $successCount++;
                echo "<li style='color: green;'>✅ تم تنفيذ الأمر " . ($index + 1) . "</li>";
            }
        } catch (PDOException $e) {
            $errorCount++;
            echo "<li style='color: red;'>❌ خطأ في الأمر " . ($index + 1) . ": " . $e->getMessage() . "</li>";
        }
    }
    
    echo "</ul>";
    
    // عرض الإحصائيات
    echo "<h3>إحصائيات الإدخال:</h3>";
    echo "<table border='1' style='border-collapse: collapse; width: 100%;'>";
    echo "<tr><th>الوصف</th><th>العدد</th></tr>";
    echo "<tr><td>إجمالي الأوامر</td><td>$totalStatements</td></tr>";
    echo "<tr><td>الأوامر الناجحة</td><td style='color: green;'>$successCount</td></tr>";
    echo "<tr><td>الأوامر الفاشلة</td><td style='color: red;'>$errorCount</td></tr>";
    echo "</table>";
    
    // التحقق من البيانات المدخلة
    echo "<h3>التحقق من البيانات المدخلة:</h3>";
    
    $tables = [
        'users' => 'المستخدمين',
        'categories' => 'الفئات',
        'services' => 'الخدمات',
        'bookings' => 'الحجوزات',
        'reviews' => 'التقييمات',
        'favorites' => 'المفضلة',
        'ads' => 'الإعلانات',
        'notifications' => 'الإشعارات',
        'messages' => 'الرسائل',
        'provider_requests' => 'طلبات المزودين',
        'profile_requests' => 'طلبات الملف الشخصي',
        'payments' => 'المدفوعات',
        'statistics' => 'الإحصائيات',
        'settings' => 'الإعدادات'
    ];
    
    echo "<table border='1' style='border-collapse: collapse; width: 100%;'>";
    echo "<tr><th>الجدول</th><th>الاسم العربي</th><th>عدد السجلات</th></tr>";
    
    foreach ($tables as $table => $arabicName) {
        try {
            $stmt = $pdo->query("SELECT COUNT(*) FROM $table");
            $count = $stmt->fetchColumn();
            echo "<tr><td>$table</td><td>$arabicName</td><td style='color: green;'>$count</td></tr>";
        } catch (PDOException $e) {
            echo "<tr><td>$table</td><td>$arabicName</td><td style='color: red;'>خطأ</td></tr>";
        }
    }
    
    echo "</table>";
    
    // عرض بيانات المستخدمين للاختبار
    echo "<h3>بيانات المستخدمين للاختبار:</h3>";
    echo "<table border='1' style='border-collapse: collapse; width: 100%;'>";
    echo "<tr><th>الاسم</th><th>البريد الإلكتروني</th><th>نوع المستخدم</th><th>كلمة المرور</th></tr>";
    
    $users = [
        ['أحمد محمد', 'ahmed@example.com', 'user', 'password'],
        ['فاطمة علي', 'fatima@example.com', 'user', 'password'],
        ['محمد عبدالله', 'mohammed@example.com', 'provider', 'password'],
        ['سارة أحمد', 'sara@example.com', 'provider', 'password'],
        ['علي حسن', 'ali@example.com', 'admin', 'password']
    ];
    
    foreach ($users as $user) {
        echo "<tr>";
        echo "<td>{$user[0]}</td>";
        echo "<td>{$user[1]}</td>";
        echo "<td>{$user[2]}</td>";
        echo "<td>{$user[3]}</td>";
        echo "</tr>";
    }
    
    echo "</table>";
    
    // عرض بيانات الخدمات
    echo "<h3>بيانات الخدمات:</h3>";
    echo "<table border='1' style='border-collapse: collapse; width: 100%;'>";
    echo "<tr><th>الخدمة</th><th>السعر</th><th>الموقع</th></tr>";
    
    $services = [
        ['تنظيف شامل للمنازل', '200 ريال', 'الرياض'],
        ['تصوير الأعراس', '1500 ريال', 'جدة'],
        ['تنسيق الحدائق', '800 ريال', 'الدمام'],
        ['تركيب الكهرباء', '300 ريال', 'الرياض'],
        ['إصلاح السباكة', '250 ريال', 'جدة']
    ];
    
    foreach ($services as $service) {
        echo "<tr>";
        echo "<td>{$service[0]}</td>";
        echo "<td>{$service[1]}</td>";
        echo "<td>{$service[2]}</td>";
        echo "</tr>";
    }
    
    echo "</table>";
    
    echo "<h2 style='color: green;'>✅ تم إدخال البيانات الافتراضية بنجاح!</h2>";
    echo "<p>يمكنك الآن اختبار التطبيق باستخدام البيانات المدخلة.</p>";
    
} catch (Exception $e) {
    echo "<h2 style='color: red;'>❌ خطأ: " . $e->getMessage() . "</h2>";
    echo "<p>يرجى التحقق من إعدادات قاعدة البيانات وملف البيانات الافتراضية.</p>";
}

echo "<hr>";
echo "<h3>تعليمات الاختبار:</h3>";
echo "<ol>";
echo "<li>افتح التطبيق في المتصفح</li>";
echo "<li>جرب تسجيل الدخول باستخدام البيانات أعلاه</li>";
echo "<li>اختبر جلب الخدمات والفئات</li>";
echo "<li>اختبر إضافة خدمات جديدة</li>";
echo "<li>اختبر نظام الحجوزات</li>";
echo "</ol>";

echo "<p><strong>ملاحظة:</strong> جميع كلمات المرور هي 'password'</p>";
?> 