<?php
/**
 * صفحة اختبار بسيطة للتحقق من API
 */

require_once 'config.php';
require_once 'database.php';

header('Content-Type: application/json; charset=utf-8');

try {
    $database = new Database();
    $database->connect();
    
    // اختبار بسيط
    $query = "SELECT * FROM services LIMIT 3";
    $result = $database->select($query);
    
    echo json_encode([
        'success' => true,
        'data' => $result,
        'count' => count($result)
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
}
?>

