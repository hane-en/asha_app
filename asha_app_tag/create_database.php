<?php
/**
 * إنشاء قاعدة البيانات كاملة مع البيانات الافتراضية
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

require_once 'config.php';

$result = [
    'success' => false,
    'message' => '',
    'steps' => [],
    'database_info' => []
];

try {
    // الاتصال بقاعدة البيانات بدون تحديد قاعدة بيانات
    $pdo = new PDO(
        "mysql:host=" . DB_HOST . ";charset=utf8mb4",
        DB_USER,
        DB_PASS,
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8mb4"
        ]
    );
    
    $result['message'] = 'بدء إنشاء قاعدة البيانات...';
    
    // قراءة ملف SQL
    $sql_file = 'create_database_with_data.sql';
    if (!file_exists($sql_file)) {
        throw new Exception('ملف SQL غير موجود: ' . $sql_file);
    }
    
    $sql_content = file_get_contents($sql_file);
    
    // تقسيم الملف إلى أوامر منفصلة
    $statements = array_filter(
        array_map('trim', explode(';', $sql_content)),
        function($stmt) { return !empty($stmt) && !preg_match('/^--/', $stmt); }
    );
    
    $result['steps']['step1_connection'] = 'تم الاتصال بقاعدة البيانات بنجاح';
    
    $executed_statements = 0;
    $total_statements = count($statements);
    
    foreach ($statements as $statement) {
        try {
            if (!empty(trim($statement))) {
                $pdo->exec($statement);
                $executed_statements++;
                
                // تحديث التقدم كل 10 أوامر
                if ($executed_statements % 10 == 0) {
                    $result['steps']['progress'] = "تم تنفيذ $executed_statements من $total_statements أمر";
                }
            }
        } catch (PDOException $e) {
            // تجاهل بعض الأخطاء المتوقعة
            if (strpos($e->getMessage(), 'Duplicate key name') !== false ||
                strpos($e->getMessage(), 'Duplicate entry') !== false ||
                strpos($e->getMessage(), 'already exists') !== false) {
                // هذه أخطاء متوقعة، نستمر
                continue;
            } else {
                throw $e;
            }
        }
    }
    
    $result['steps']['step2_execution'] = "تم تنفيذ جميع الأوامر بنجاح ($executed_statements أمر)";
    
    // التحقق من إنشاء قاعدة البيانات
    $databases = $pdo->query("SHOW DATABASES LIKE 'asha_app'")->fetchAll();
    if (count($databases) > 0) {
        $result['steps']['step3_database'] = 'تم إنشاء قاعدة البيانات asha_app بنجاح';
    }
    
    // الاتصال بقاعدة البيانات الجديدة للتحقق من الجداول
    $pdo = new PDO(
        "mysql:host=" . DB_HOST . ";dbname=asha_app;charset=utf8mb4",
        DB_USER,
        DB_PASS,
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8mb4"
        ]
    );
    
    // التحقق من الجداول
    $tables = $pdo->query("SHOW TABLES")->fetchAll(PDO::FETCH_COLUMN);
    $expected_tables = ['users', 'categories', 'services', 'ads', 'offers', 'bookings', 'reviews', 'favorites', 'comments', 'notifications'];
    
    $created_tables = [];
    foreach ($expected_tables as $table) {
        if (in_array($table, $tables)) {
            $count = $pdo->query("SELECT COUNT(*) as count FROM $table")->fetch()['count'];
            $created_tables[$table] = $count;
        }
    }
    
    $result['steps']['step4_tables'] = 'تم إنشاء جميع الجداول بنجاح';
    $result['database_info']['tables'] = $created_tables;
    
    // التحقق من البيانات
    $total_users = $pdo->query("SELECT COUNT(*) as count FROM users")->fetch()['count'];
    $total_categories = $pdo->query("SELECT COUNT(*) as count FROM categories")->fetch()['count'];
    $total_services = $pdo->query("SELECT COUNT(*) as count FROM services")->fetch()['count'];
    $total_ads = $pdo->query("SELECT COUNT(*) as count FROM ads")->fetch()['count'];
    $total_offers = $pdo->query("SELECT COUNT(*) as count FROM offers")->fetch()['count'];
    $total_bookings = $pdo->query("SELECT COUNT(*) as count FROM bookings")->fetch()['count'];
    $total_reviews = $pdo->query("SELECT COUNT(*) as count FROM reviews")->fetch()['count'];
    $total_favorites = $pdo->query("SELECT COUNT(*) as count FROM favorites")->fetch()['count'];
    $total_comments = $pdo->query("SELECT COUNT(*) as count FROM comments")->fetch()['count'];
    $total_notifications = $pdo->query("SELECT COUNT(*) as count FROM notifications")->fetch()['count'];
    
    $result['database_info']['data_counts'] = [
        'users' => $total_users,
        'categories' => $total_categories,
        'services' => $total_services,
        'ads' => $total_ads,
        'offers' => $total_offers,
        'bookings' => $total_bookings,
        'reviews' => $total_reviews,
        'favorites' => $total_favorites,
        'comments' => $total_comments,
        'notifications' => $total_notifications
    ];
    
    $result['success'] = true;
    $result['message'] = 'تم إنشاء قاعدة البيانات والجداول والبيانات الافتراضية بنجاح!';
    
    // إضافة معلومات إضافية
    $result['info'] = [
        'database_name' => 'asha_app',
        'total_tables' => count($created_tables),
        'total_records' => array_sum($result['database_info']['data_counts']),
        'server_time' => date('Y-m-d H:i:s')
    ];
    
} catch (Exception $e) {
    $result['success'] = false;
    $result['message'] = 'فشل في إنشاء قاعدة البيانات: ' . $e->getMessage();
    $result['error'] = [
        'message' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine()
    ];
}

// إرجاع النتيجة
echo json_encode($result, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
?> 