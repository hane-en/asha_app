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
    
    if (!$serviceId) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'معرف الخدمة مطلوب',
            'timestamp' => date('Y-m-d H:i:s')
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }
    
    // التحقق من وجود الخدمة
    $serviceStmt = $pdo->prepare("SELECT id FROM services WHERE id = ?");
    $serviceStmt->execute([$serviceId]);
    if (!$serviceStmt->fetch()) {
        http_response_code(404);
        echo json_encode([
            'success' => false,
            'message' => 'الخدمة غير موجودة',
            'timestamp' => date('Y-m-d H:i:s')
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }
    
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
            WHERE o.service_id = ? AND o.is_active = 1
            ORDER BY o.discount_percentage DESC, o.created_at DESC";
    
    $stmt = $pdo->prepare($sql);
    $stmt->execute([$serviceId]);
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
    
    // جلب أفضل عرض (أعلى نسبة خصم صالحة)
    $bestOffer = null;
    foreach ($offers as $offer) {
        if ($offer['is_valid']) {
            if ($bestOffer === null || $offer['discount_percentage'] > $bestOffer['discount_percentage']) {
                $bestOffer = $offer;
            }
        }
    }
    
    echo json_encode([
        'success' => true,
        'data' => $offers,
        'best_offer' => $bestOffer,
        'count' => count($offers),
        'has_offers' => count($offers) > 0,
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