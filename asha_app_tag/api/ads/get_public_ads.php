<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// التعامل مع طلبات OPTIONS
if (isset($_SERVER['REQUEST_METHOD']) && $_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once '../config/database.php';

try {
    $db = new Database();
    $pdo = $db->getConnection();
    
    if (!$pdo) {
        throw new Exception('فشل في الاتصال بقاعدة البيانات');
    }
    
    $sql = "SELECT 
                a.id,
                a.title,
                a.description,
                a.image,
                a.is_active,
                a.start_date,
                a.end_date,
                a.created_at,
                u.name as provider_name
            FROM ads a
            INNER JOIN users u ON a.provider_id = u.id
            WHERE a.is_active = 1 
            AND (a.start_date IS NULL OR a.start_date <= NOW())
            AND (a.end_date IS NULL OR a.end_date >= NOW())
            ORDER BY a.created_at DESC
            LIMIT 10";
    
    $stmt = $pdo->prepare($sql);
    $stmt->execute();
    $ads = $stmt->fetchAll();
    
    echo json_encode([
        'success' => true,
        'data' => $ads,
        'count' => count($ads),
        'timestamp' => date('Y-m-d H:i:s')
    ], JSON_UNESCAPED_UNICODE);
    
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'خطأ في قاعدة البيانات: ' . $e->getMessage(),
        'timestamp' => date('Y-m-d H:i:s')
    ], JSON_UNESCAPED_UNICODE);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'خطأ في الخادم: ' . $e->getMessage(),
        'timestamp' => date('Y-m-d H:i:s')
    ], JSON_UNESCAPED_UNICODE);
}
?> 