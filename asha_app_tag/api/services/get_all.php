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
    
    $categoryId = isset($_GET['category_id']) ? (int)$_GET['category_id'] : null;
    $providerId = isset($_GET['provider_id']) ? (int)$_GET['provider_id'] : null;
    $search = isset($_GET['search']) ? $_GET['search'] : null;
    
    $sql = "SELECT 
                s.id,
                s.title as name,
                s.description,
                s.price,
                s.images,
                s.is_active,
                s.created_at,
                u.id as provider_id,
                u.name as provider_name,
                u.phone as provider_phone,
                u.email as provider_email,
                c.id as category_id,
                c.name as category_name
            FROM services s
            INNER JOIN users u ON s.provider_id = u.id AND u.user_type = 'provider'
            INNER JOIN categories c ON s.category_id = c.id
            WHERE s.is_active = 1";
    
    $params = [];
    
    if ($categoryId) {
        $sql .= " AND s.category_id = ?";
        $params[] = $categoryId;
    }
    
    if ($providerId) {
        $sql .= " AND s.provider_id = ?";
        $params[] = $providerId;
    }
    
    if ($search) {
        $sql .= " AND (s.title LIKE ? OR s.description LIKE ? OR u.name LIKE ?)";
        $searchTerm = "%$search%";
        $params[] = $searchTerm;
        $params[] = $searchTerm;
        $params[] = $searchTerm;
    }
    
    $sql .= " ORDER BY s.created_at DESC";
    
    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    $services = $stmt->fetchAll();
    
    // إضافة معلومات إضافية لكل خدمة
    foreach ($services as &$service) {
        // تحويل الأرقام إلى int
        $service['id'] = (int)$service['id'];
        $service['provider_id'] = (int)$service['provider_id'];
        $service['category_id'] = (int)$service['category_id'];
        $service['price'] = (float)$service['price'];
        
        // تحويل القيم المنطقية
        $service['is_active'] = (bool)$service['is_active'];
        
        // جلب عدد التقييمات
        $reviewStmt = $pdo->prepare("SELECT COUNT(*) as count, AVG(rating) as avg_rating FROM reviews WHERE service_id = ?");
        $reviewStmt->execute([$service['id']]);
        $reviewData = $reviewStmt->fetch();
        
        $service['reviews_count'] = (int)$reviewData['count'];
        $service['average_rating'] = $reviewData['avg_rating'] ? (float)round($reviewData['avg_rating'], 1) : 0.0;
        
        // جلب عدد الحجوزات
        $bookingStmt = $pdo->prepare("SELECT COUNT(*) as count FROM bookings WHERE service_id = ? AND status = 'completed'");
        $bookingStmt->execute([$service['id']]);
        $bookingData = $bookingStmt->fetch();
        
        $service['bookings_count'] = (int)$bookingData['count'];
        
        // جلب العروض للخدمة
        $offersStmt = $pdo->prepare("
            SELECT 
                o.id,
                o.title,
                o.description,
                o.discount_percentage,
                o.start_date as valid_from,
                o.end_date as valid_until,
                o.is_active,
                o.created_at
            FROM offers o 
            WHERE o.service_id = ? AND o.is_active = 1
            ORDER BY o.discount_percentage DESC
        ");
        $offersStmt->execute([$service['id']]);
        $offers = $offersStmt->fetchAll();
        
        // إضافة معلومات العروض
        foreach ($offers as &$offer) {
            $offer['id'] = (int)$offer['id'];
            $offer['discount_percentage'] = (int)$offer['discount_percentage'];
            $offer['is_active'] = (bool)$offer['is_active'];
            
            // التحقق من صلاحية العرض
            $now = new DateTime();
            $startDate = new DateTime($offer['valid_from']);
            $endDate = new DateTime($offer['valid_until']);
            $offer['is_valid'] = $now >= $startDate && $now <= $endDate && $offer['is_active'];
        }
        
        $service['offers'] = $offers;
        $service['has_offers'] = count($offers) > 0;
        
        // جلب أفضل عرض
        $bestOffer = null;
        foreach ($offers as $offer) {
            if ($offer['is_valid']) {
                if ($bestOffer === null || $offer['discount_percentage'] > $bestOffer['discount_percentage']) {
                    $bestOffer = $offer;
                }
            }
        }
        $service['best_offer'] = $bestOffer;
        
        // تحويل الصور من JSON
        if ($service['images']) {
            $service['images'] = json_decode($service['images'], true) ?: [];
        } else {
            $service['images'] = [];
        }
    }
    
    echo json_encode([
        'success' => true,
        'data' => $services,
        'count' => count($services),
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

