<?php
/**
 * ملف اختبار قاعدة البيانات
 * Database Test File
 */

require_once 'config.php';

// =====================================================
// دالة اختبار الاتصال بقاعدة البيانات
// =====================================================
function testDatabaseConnection() {
    try {
        $pdo = getDatabaseConnection();
        if ($pdo) {
            echo "✅ تم الاتصال بقاعدة البيانات بنجاح\n";
            return true;
        } else {
            echo "❌ فشل الاتصال بقاعدة البيانات\n";
            return false;
        }
    } catch (Exception $e) {
        echo "❌ خطأ في الاتصال: " . $e->getMessage() . "\n";
        return false;
    }
}

// =====================================================
// دالة اختبار الجداول
// =====================================================
function testTables() {
    try {
        $pdo = getDatabaseConnection();
        $tables = [
            'users',
            'categories',
            'services',
            'bookings',
            'favorites',
            'reviews',
            'ads',
            'notifications',
            'messages',
            'provider_requests',
            'profile_requests',
            'payments',
            'statistics',
            'settings'
        ];
        
        echo "\n🔍 اختبار الجداول:\n";
        foreach ($tables as $table) {
            $stmt = $pdo->query("SHOW TABLES LIKE '$table'");
            if ($stmt->rowCount() > 0) {
                echo "✅ جدول $table موجود\n";
            } else {
                echo "❌ جدول $table غير موجود\n";
            }
        }
        
        return true;
    } catch (Exception $e) {
        echo "❌ خطأ في اختبار الجداول: " . $e->getMessage() . "\n";
        return false;
    }
}

// =====================================================
// دالة اختبار البيانات الأساسية
// =====================================================
function testBasicData() {
    try {
        $pdo = getDatabaseConnection();
        
        echo "\n🔍 اختبار البيانات الأساسية:\n";
        
        // اختبار المستخدم الإداري
        $stmt = $pdo->query("SELECT COUNT(*) as count FROM users WHERE user_type = 'admin'");
        $adminCount = $stmt->fetch()['count'];
        echo "👤 عدد المستخدمين الإداريين: $adminCount\n";
        
        // اختبار فئات الخدمات
        $stmt = $pdo->query("SELECT COUNT(*) as count FROM categories");
        $categoryCount = $stmt->fetch()['count'];
        echo "📂 عدد فئات الخدمات: $categoryCount\n";
        
        // اختبار إعدادات النظام
        $stmt = $pdo->query("SELECT COUNT(*) as count FROM settings");
        $settingsCount = $stmt->fetch()['count'];
        echo "⚙️ عدد إعدادات النظام: $settingsCount\n";
        
        return true;
    } catch (Exception $e) {
        echo "❌ خطأ في اختبار البيانات: " . $e->getMessage() . "\n";
        return false;
    }
}

// =====================================================
// دالة اختبار الإجراءات المخزنة
// =====================================================
function testStoredProcedures() {
    try {
        $pdo = getDatabaseConnection();
        
        echo "\n🔍 اختبار الإجراءات المخزنة:\n";
        
        // اختبار إجراء الإحصائيات العامة
        $stmt = $pdo->query("CALL GetGeneralStats()");
        $stats = $stmt->fetch();
        echo "📊 الإحصائيات العامة:\n";
        echo "   - إجمالي المستخدمين: " . ($stats['total_users'] ?? 0) . "\n";
        echo "   - إجمالي مزودي الخدمة: " . ($stats['total_providers'] ?? 0) . "\n";
        echo "   - إجمالي الخدمات: " . ($stats['total_services'] ?? 0) . "\n";
        echo "   - الحجوزات المعلقة: " . ($stats['pending_bookings'] ?? 0) . "\n";
        echo "   - إجمالي الإيرادات: " . ($stats['total_revenue'] ?? 0) . " ريال\n";
        
        return true;
    } catch (Exception $e) {
        echo "❌ خطأ في اختبار الإجراءات: " . $e->getMessage() . "\n";
        return false;
    }
}

// =====================================================
// دالة اختبار Views
// =====================================================
function testViews() {
    try {
        $pdo = getDatabaseConnection();
        
        echo "\n🔍 اختبار Views:\n";
        
        // اختبار view الخدمات مع التفاصيل
        $stmt = $pdo->query("SELECT COUNT(*) as count FROM services_with_details");
        $servicesCount = $stmt->fetch()['count'];
        echo "✅ services_with_details: $servicesCount خدمة\n";
        
        // اختبار view الحجوزات مع التفاصيل
        $stmt = $pdo->query("SELECT COUNT(*) as count FROM bookings_with_details");
        $bookingsCount = $stmt->fetch()['count'];
        echo "✅ bookings_with_details: $bookingsCount حجز\n";
        
        // اختبار view التقييمات مع التفاصيل
        $stmt = $pdo->query("SELECT COUNT(*) as count FROM reviews_with_details");
        $reviewsCount = $stmt->fetch()['count'];
        echo "✅ reviews_with_details: $reviewsCount تقييم\n";
        
        return true;
    } catch (Exception $e) {
        echo "❌ خطأ في اختبار Views: " . $e->getMessage() . "\n";
        return false;
    }
}

// =====================================================
// دالة اختبار الأداء
// =====================================================
function testPerformance() {
    try {
        $pdo = getDatabaseConnection();
        
        echo "\n🔍 اختبار الأداء:\n";
        
        // قياس وقت الاستعلام
        $start = microtime(true);
        $stmt = $pdo->query("SELECT * FROM services_with_details LIMIT 10");
        $services = $stmt->fetchAll();
        $end = microtime(true);
        $time = round(($end - $start) * 1000, 2);
        echo "⏱️ وقت استعلام الخدمات: {$time}ms\n";
        
        // اختبار البحث
        $start = microtime(true);
        $stmt = $pdo->query("SELECT * FROM services WHERE MATCH(title, description) AGAINST('حفلة' IN BOOLEAN MODE) LIMIT 5");
        $searchResults = $stmt->fetchAll();
        $end = microtime(true);
        $time = round(($end - $start) * 1000, 2);
        echo "🔍 وقت البحث: {$time}ms\n";
        
        return true;
    } catch (Exception $e) {
        echo "❌ خطأ في اختبار الأداء: " . $e->getMessage() . "\n";
        return false;
    }
}

// =====================================================
// دالة اختبار الصلاحيات
// =====================================================
function testPermissions() {
    try {
        $pdo = getDatabaseConnection();
        
        echo "\n🔍 اختبار الصلاحيات:\n";
        
        // اختبار القراءة
        $stmt = $pdo->query("SELECT 1");
        echo "✅ صلاحية القراءة: متاحة\n";
        
        // اختبار الكتابة
        $stmt = $pdo->query("INSERT INTO settings (setting_key, setting_value, setting_type, description) VALUES ('test_key', 'test_value', 'string', 'Test setting')");
        echo "✅ صلاحية الكتابة: متاحة\n";
        
        // حذف البيانات التجريبية
        $stmt = $pdo->query("DELETE FROM settings WHERE setting_key = 'test_key'");
        echo "✅ صلاحية الحذف: متاحة\n";
        
        return true;
    } catch (Exception $e) {
        echo "❌ خطأ في اختبار الصلاحيات: " . $e->getMessage() . "\n";
        return false;
    }
}

// =====================================================
// دالة اختبار النظام
// =====================================================
function testSystemRequirements() {
    echo "\n🔍 اختبار متطلبات النظام:\n";
    
    $requirements = checkSystemRequirements();
    
    foreach ($requirements as $requirement => $status) {
        if ($status) {
            echo "✅ $requirement: متوفر\n";
        } else {
            echo "❌ $requirement: غير متوفر\n";
        }
    }
    
    return !in_array(false, $requirements);
}

// =====================================================
// دالة إنشاء تقرير شامل
// =====================================================
function generateReport() {
    echo "=====================================================\n";
    echo "تقرير اختبار قاعدة البيانات\n";
    echo "Database Test Report\n";
    echo "=====================================================\n";
    echo "التاريخ: " . date('Y-m-d H:i:s') . "\n";
    echo "إصدار PHP: " . PHP_VERSION . "\n";
    echo "إصدار التطبيق: " . APP_VERSION . "\n";
    echo "=====================================================\n\n";
    
    $tests = [
        'testSystemRequirements' => 'متطلبات النظام',
        'testDatabaseConnection' => 'الاتصال بقاعدة البيانات',
        'testTables' => 'الجداول',
        'testBasicData' => 'البيانات الأساسية',
        'testStoredProcedures' => 'الإجراءات المخزنة',
        'testViews' => 'Views',
        'testPerformance' => 'الأداء',
        'testPermissions' => 'الصلاحيات'
    ];
    
    $results = [];
    foreach ($tests as $test => $description) {
        echo "🔍 اختبار $description...\n";
        $results[$test] = $test();
        echo "\n";
    }
    
    echo "=====================================================\n";
    echo "ملخص النتائج:\n";
    echo "=====================================================\n";
    
    $passed = 0;
    $total = count($results);
    
    foreach ($results as $test => $result) {
        if ($result) {
            echo "✅ " . $tests[$test] . ": نجح\n";
            $passed++;
        } else {
            echo "❌ " . $tests[$test] . ": فشل\n";
        }
    }
    
    echo "\n=====================================================\n";
    echo "النتيجة النهائية: $passed/$total اختبارات نجحت\n";
    
    if ($passed == $total) {
        echo "🎉 جميع الاختبارات نجحت! قاعدة البيانات جاهزة للاستخدام.\n";
    } else {
        echo "⚠️ بعض الاختبارات فشلت. يرجى مراجعة الإعدادات.\n";
    }
    
    echo "=====================================================\n";
}

// =====================================================
// تشغيل الاختبارات
// =====================================================
if (php_sapi_name() === 'cli') {
    // تشغيل من سطر الأوامر
    generateReport();
} else {
    // تشغيل من المتصفح
    header('Content-Type: text/plain; charset=utf-8');
    generateReport();
}
?> 