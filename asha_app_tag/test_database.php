<?php
/**
 * اختبار الـ database class
 */

require_once 'config.php';
require_once 'database.php';

header('Content-Type: application/json; charset=utf-8');

try {
    $database = new Database();
    $database->connect();
    
    echo "Database connected successfully\n";
    
    // اختبار استعلام بسيط
    $simpleQuery = "SELECT COUNT(*) as total FROM services";
    $result = $database->selectOne($simpleQuery);
    echo "Count result: " . json_encode($result) . "\n";
    
    // اختبار استعلام مع LIMIT
    $limitQuery = "SELECT * FROM services LIMIT 5";
    $limitResult = $database->select($limitQuery);
    echo "Limit result count: " . count($limitResult) . "\n";
    if (count($limitResult) > 0) {
        echo "First service: " . json_encode($limitResult[0]) . "\n";
    }
    
    // اختبار استعلام مع parameters
    $paramQuery = "SELECT * FROM services LIMIT :limit OFFSET :offset";
    $paramResult = $database->select($paramQuery, ['limit' => 5, 'offset' => 0]);
    echo "Param result count: " . count($paramResult) . "\n";
    
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
    echo "Trace: " . $e->getTraceAsString() . "\n";
}
?> 