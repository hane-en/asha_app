<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');

require_once 'config.php';
require_once 'database.php';

try {
    // اختبار الاتصال بقاعدة البيانات
    $db = new Database();
    $pdo = $db->connect();
    
    if ($pdo) {
        // اختبار جلب الفئات
        $sql = "SELECT COUNT(*) as count FROM categories WHERE is_active = 1";
        $result = $db->selectOne($sql);
        
        if ($result !== false) {
            echo json_encode([
                'success' => true,
                'message' => 'الاتصال بقاعدة البيانات يعمل بشكل صحيح',
                'categories_count' => $result['count'],
                'database_name' => DB_NAME,
                'server_info' => [
                    'php_version' => PHP_VERSION,
                    'mysql_version' => $pdo->getAttribute(PDO::ATTR_SERVER_VERSION),
                    'connection_status' => 'Connected'
                ]
            ], JSON_UNESCAPED_UNICODE);
        } else {
            echo json_encode([
                'success' => false,
                'message' => 'فشل في جلب البيانات من قاعدة البيانات',
                'database_name' => DB_NAME
            ], JSON_UNESCAPED_UNICODE);
        }
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'فشل في الاتصال بقاعدة البيانات',
            'database_name' => DB_NAME,
            'host' => DB_HOST,
            'user' => DB_USER
        ], JSON_UNESCAPED_UNICODE);
    }
    
} catch (PDOException $e) {
    echo json_encode([
        'success' => false,
        'message' => 'خطأ في قاعدة البيانات: ' . $e->getMessage(),
        'database_name' => DB_NAME,
        'host' => DB_HOST,
        'user' => DB_USER
    ], JSON_UNESCAPED_UNICODE);
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'خطأ عام: ' . $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
?> 