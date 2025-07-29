<?php
/**
 * ملف تنظيف قاعدة البيانات
 * لحذف البيانات الموجودة قبل إدخال البيانات الجديدة
 */

require_once 'config.php';
require_once 'database.php';

// إعداد CORS
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');

// معالجة preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$result = [
    'success' => true,
    'message' => 'تم تنظيف قاعدة البيانات بنجاح',
    'timestamp' => date('Y-m-d H:i:s'),
    'deleted_counts' => [],
    'warnings' => []
];

try {
    $database = new Database();
    $database->connect();
    
    // ترتيب الحذف حسب Foreign Key Constraints
    $tables_to_delete = [
        'bookings',
        'reviews', 
        'favorites',
        'comments',
        'notifications',
        'offers',
        'ads',
        'services',
        'categories'
    ];
    
    $deleted_counts = [];
    
    foreach ($tables_to_delete as $table) {
        try {
            // احصل على عدد السجلات قبل الحذف
            $count_before = $database->getTotalCount($table);
            
            // احذف جميع السجلات
            $query = "DELETE FROM $table";
            $database->execute($query);
            
            $deleted_counts[$table] = $count_before;
            
        } catch (Exception $e) {
            $result['warnings'][] = "خطأ في حذف جدول $table: " . $e->getMessage();
        }
    }
    
    // حذف المستخدمين (باستثناء المستخدم الأول إذا كان موجود)
    try {
        $count_before = $database->getTotalCount('users');
        $query = "DELETE FROM users WHERE id > 1";
        $database->execute($query);
        $deleted_counts['users'] = $count_before - 1; // ناقص 1 للمستخدم الأول
        
    } catch (Exception $e) {
        $result['warnings'][] = "خطأ في حذف المستخدمين: " . $e->getMessage();
    }
    
    $result['deleted_counts'] = $deleted_counts;
    
    // إعادة تعيين Auto Increment
    $reset_tables = [
        'users' => 1,
        'categories' => 1,
        'services' => 1,
        'ads' => 1,
        'bookings' => 1,
        'reviews' => 1,
        'favorites' => 1,
        'comments' => 1,
        'notifications' => 1,
        'offers' => 1
    ];
    
    foreach ($reset_tables as $table => $start_value) {
        try {
            $query = "ALTER TABLE $table AUTO_INCREMENT = $start_value";
            $database->execute($query);
        } catch (Exception $e) {
            $result['warnings'][] = "خطأ في إعادة تعيين Auto Increment لجدول $table: " . $e->getMessage();
        }
    }
    
    // فحص النتيجة النهائية
    $final_counts = [];
    $tables_to_check = ['users', 'categories', 'services', 'ads', 'bookings', 'reviews', 'favorites', 'comments', 'notifications', 'offers'];
    
    foreach ($tables_to_check as $table) {
        try {
            $count = $database->getTotalCount($table);
            $final_counts[$table] = $count;
        } catch (Exception $e) {
            $final_counts[$table] = 'خطأ: ' . $e->getMessage();
        }
    }
    
    $result['final_counts'] = $final_counts;
    
    // إضافة معلومات إضافية
    $result['info'] = [
        'total_deleted_records' => array_sum($deleted_counts),
        'database_name' => $database->getDatabaseName(),
        'server_time' => date('Y-m-d H:i:s')
    ];
    
} catch (Exception $e) {
    $result['success'] = false;
    $result['message'] = 'فشل في تنظيف قاعدة البيانات: ' . $e->getMessage();
    $result['error'] = [
        'message' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine()
    ];
}

// إرجاع النتيجة
echo json_encode($result, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
?> 