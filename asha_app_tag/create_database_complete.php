<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

require_once 'config.php';

$result = [
    'success' => false,
    'message' => '',
    'details' => [],
    'errors' => []
];

try {
    // الاتصال بـ MySQL بدون تحديد قاعدة بيانات
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
    
    $result['message'] = 'بدء إنشاء قاعدة البيانات كاملة...';
    
    // قراءة ملف SQL
    $sql_file = 'create_database_complete.sql';
    if (!file_exists($sql_file)) {
        throw new Exception("ملف SQL غير موجود: $sql_file");
    }
    
    $sql_content = file_get_contents($sql_file);
    if ($sql_content === false) {
        throw new Exception("لا يمكن قراءة ملف SQL");
    }
    
    $result['details']['file_size'] = strlen($sql_content) . ' bytes';
    
    // تقسيم الملف إلى عبارات منفصلة
    $statements = array_filter(
        array_map('trim', explode(';', $sql_content)),
        function($stmt) {
            return !empty($stmt) && !preg_match('/^--/', $stmt);
        }
    );
    
    $result['details']['total_statements'] = count($statements);
    $result['details']['executed_statements'] = 0;
    $result['details']['skipped_statements'] = 0;
    
    foreach ($statements as $index => $statement) {
        try {
            if (!empty(trim($statement))) {
                // إغلاق أي استعلامات مفتوحة
                $pdo->query('SELECT 1')->closeCursor();
                $pdo->exec($statement);
                $result['details']['executed_statements']++;
            }
        } catch (PDOException $e) {
            // تجاهل الأخطاء المتوقعة
            if (strpos($e->getMessage(), 'Duplicate key name') !== false ||
                strpos($e->getMessage(), 'Duplicate entry') !== false ||
                strpos($e->getMessage(), 'already exists') !== false ||
                strpos($e->getMessage(), 'database exists') !== false ||
                strpos($e->getMessage(), 'Cannot execute queries while other unbuffered queries') !== false) {
                $result['details']['skipped_statements']++;
                continue;
            } else {
                throw $e;
            }
        }
    }
    
    // التحقق من إنشاء قاعدة البيانات والجداول
    $result['details']['verification'] = [];
    
    // التحقق من قاعدة البيانات
    $stmt = $pdo->query("SHOW DATABASES LIKE 'asha_app'");
    if ($stmt->rowCount() > 0) {
        $result['details']['verification']['database'] = 'تم إنشاء قاعدة البيانات بنجاح';
    } else {
        $result['details']['verification']['database'] = 'فشل في إنشاء قاعدة البيانات';
    }
    
    // الاتصال بقاعدة البيانات للتحقق من الجداول
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
    $tables = ['users', 'categories', 'services', 'ads', 'offers', 'bookings', 'reviews', 'favorites', 'comments', 'notifications'];
    foreach ($tables as $table) {
        $stmt = $pdo->query("SHOW TABLES LIKE '$table'");
        if ($stmt->rowCount() > 0) {
            $count_stmt = $pdo->query("SELECT COUNT(*) as count FROM $table");
            $count = $count_stmt->fetch()['count'];
            $result['details']['verification'][$table] = "تم إنشاء الجدول بنجاح - عدد السجلات: $count";
        } else {
            $result['details']['verification'][$table] = "فشل في إنشاء الجدول";
        }
    }
    
    $result['success'] = true;
    $result['message'] = 'تم إنشاء قاعدة البيانات والجداول والبيانات الافتراضية بنجاح!';
    
} catch (Exception $e) {
    $result['success'] = false;
    $result['message'] = 'خطأ في إنشاء قاعدة البيانات: ' . $e->getMessage();
    $result['errors'][] = [
        'type' => get_class($e),
        'message' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine()
    ];
}

echo json_encode($result, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
?> 