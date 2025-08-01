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
    
    $userId = isset($_GET['user_id']) ? (int)$_GET['user_id'] : null;
    $serviceId = isset($_GET['service_id']) ? (int)$_GET['service_id'] : null;
    $status = isset($_GET['status']) ? $_GET['status'] : null;
    
    $sql = "SELECT 
                b.id,
                b.user_id,
                b.service_id,
                b.booking_date,
                b.booking_time,
                b.notes,
                b.status,
                b.created_at,
                u.name as user_name,
                u.email as user_email,
                u.phone as user_phone,
                s.title as service_name,
                s.price as service_price,
                provider.name as provider_name
            FROM bookings b
            INNER JOIN users u ON b.user_id = u.id
            INNER JOIN services s ON b.service_id = s.id
            INNER JOIN users provider ON s.provider_id = provider.id
            WHERE 1=1";
    
    $params = [];
    
    if ($userId) {
        $sql .= " AND b.user_id = ?";
        $params[] = $userId;
    }
    
    if ($serviceId) {
        $sql .= " AND b.service_id = ?";
        $params[] = $serviceId;
    }
    
    if ($status) {
        $sql .= " AND b.status = ?";
        $params[] = $status;
    }
    
    $sql .= " ORDER BY b.created_at DESC";
    
    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    $bookings = $stmt->fetchAll();
    
    // تحويل أنواع البيانات
    foreach ($bookings as &$booking) {
        $booking['id'] = (int)$booking['id'];
        $booking['user_id'] = (int)$booking['user_id'];
        $booking['service_id'] = (int)$booking['service_id'];
        $booking['service_price'] = (float)$booking['service_price'];
    }
    
    echo json_encode([
        'success' => true,
        'data' => $bookings,
        'count' => count($bookings),
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