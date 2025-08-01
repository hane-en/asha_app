<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

require_once '../../config.php';
require_once '../../database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'طريقة الطلب غير صحيحة'], JSON_UNESCAPED_UNICODE);
    exit;
}

$serviceId = isset($_GET['id']) ? (int)$_GET['id'] : null;

if (!$serviceId) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'معرف الخدمة مطلوب'], JSON_UNESCAPED_UNICODE);
    exit;
}

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    $sql = "SELECT 
                s.id,
                s.name,
                s.description,
                s.price,
                s.image_url,
                s.is_active,
                s.created_at,
                p.id as provider_id,
                p.name as provider_name,
                p.phone as provider_phone,
                p.email as provider_email,
                p.rating as provider_rating,
                p.address as provider_address,
                c.id as category_id,
                c.name as category_name
            FROM services s
            INNER JOIN providers p ON s.provider_id = p.id
            INNER JOIN categories c ON s.category_id = c.id
            WHERE s.id = ? AND s.is_active = 1";
    
    $stmt = $pdo->prepare($sql);
    $stmt->execute([$serviceId]);
    $service = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$service) {
        http_response_code(404);
        echo json_encode(['success' => false, 'message' => 'الخدمة غير موجودة'], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // جلب التقييمات للخدمة
    $reviewSql = "SELECT 
                    r.id,
                    r.rating,
                    r.comment,
                    r.created_at,
                    u.name as user_name,
                    u.id as user_id
                   FROM reviews r
                   INNER JOIN users u ON r.user_id = u.id
                   WHERE r.service_id = ?
                   ORDER BY r.created_at DESC";
    
    $reviewStmt = $pdo->prepare($reviewSql);
    $reviewStmt->execute([$serviceId]);
    $reviews = $reviewStmt->fetchAll(PDO::FETCH_ASSOC);
    
    // حساب متوسط التقييم
    $avgRatingStmt = $pdo->prepare("SELECT AVG(rating) as avg_rating, COUNT(*) as count FROM reviews WHERE service_id = ?");
    $avgRatingStmt->execute([$serviceId]);
    $ratingData = $avgRatingStmt->fetch(PDO::FETCH_ASSOC);
    
    $service['reviews'] = $reviews;
    $service['average_rating'] = $ratingData['avg_rating'] ? round($ratingData['avg_rating'], 1) : 0;
    $service['reviews_count'] = (int)$ratingData['count'];
    
    // جلب عدد الحجوزات المكتملة
    $bookingStmt = $pdo->prepare("SELECT COUNT(*) as count FROM bookings WHERE service_id = ? AND status = 'completed'");
    $bookingStmt->execute([$serviceId]);
    $bookingData = $bookingStmt->fetch(PDO::FETCH_ASSOC);
    $service['bookings_count'] = (int)$bookingData['count'];
    
    echo json_encode([
        'success' => true,
        'data' => $service
    ], JSON_UNESCAPED_UNICODE);
    
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'خطأ في قاعدة البيانات: ' . $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'خطأ في الخادم: ' . $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
?>

