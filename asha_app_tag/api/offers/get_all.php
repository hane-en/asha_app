<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
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
    
    $serviceId = isset($_GET['service_id']) ? (int)$_GET['service_id'] : null;
    $isActive = isset($_GET['is_active']) ? (bool)$_GET['is_active'] : true;
    
    $sql = "SELECT 
                o.id,
                o.service_id,
                o.title,
                o.description,
                o.discount_percentage,
                o.start_date as valid_from,
                o.end_date as valid_until,
                o.is_active,
                o.created_at
            FROM offers o
            WHERE o.is_active = ?";
    
    $params = [$isActive];
    
    if ($serviceId) {
        $sql .= " AND o.service_id = ?";
        $params[] = $serviceId;
    }
    
    $sql .= " ORDER BY o.created_at DESC";
    
    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    $offers = $stmt->fetchAll();
    
    // إضافة معلومات إضافية لكل عرض
    foreach ($offers as &$offer) {
        // تحويل الأرقام
        $offer['id'] = (int)$offer['id'];
        $offer['service_id'] = (int)$offer['service_id'];
        $offer['discount_percentage'] = (int)$offer['discount_percentage'];
        
        // تحويل القيم المنطقية
        $offer['is_active'] = (bool)$offer['is_active'];
        
        // التحقق من صلاحية العرض
        $now = new DateTime();
        $startDate = new DateTime($offer['valid_from']);
        $endDate = new DateTime($offer['valid_until']);
        
        $offer['is_valid'] = $now >= $startDate && $now <= $endDate && $offer['is_active'];
    }
    
    echo json_encode([
        'success' => true,
        'data' => $offers,
        'count' => count($offers),
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