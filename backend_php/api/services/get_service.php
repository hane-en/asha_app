<?php
require_once '../../config/config.php';
require_once '../../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    jsonResponse(['error' => 'Method not allowed'], 405);
}

if (!isset($_GET['id'])) {
    jsonResponse(['error' => 'معرف الخدمة مطلوب'], 400);
}

$serviceId = (int)$_GET['id'];

$pdo = getDBConnection();
if (!$pdo) {
    jsonResponse(['error' => 'خطأ في الاتصال بقاعدة البيانات'], 500);
}

try {
    // جلب تفاصيل الخدمة
    $stmt = $pdo->prepare("
        SELECT s.*, c.name as category_name, u.name as provider_name, u.phone as provider_phone, u.email as provider_email
        FROM services s 
        JOIN categories c ON s.category_id = c.id 
        JOIN users u ON s.provider_id = u.id 
        WHERE s.id = ? AND s.is_active = 1
    ");
    $stmt->execute([$serviceId]);
    $service = $stmt->fetch();
    
    if (!$service) {
        jsonResponse(['error' => 'الخدمة غير موجودة'], 404);
    }
    
    // جلب التقييمات
    $stmt = $pdo->prepare("
        SELECT r.*, u.name as user_name 
        FROM reviews r 
        JOIN users u ON r.user_id = u.id 
        WHERE r.service_id = ? 
        ORDER BY r.created_at DESC
    ");
    $stmt->execute([$serviceId]);
    $reviews = $stmt->fetchAll();
    
    // حساب متوسط التقييم
    $stmt = $pdo->prepare("
        SELECT AVG(rating) as avg_rating, COUNT(*) as total_reviews 
        FROM reviews 
        WHERE service_id = ?
    ");
    $stmt->execute([$serviceId]);
    $ratingStats = $stmt->fetch();
    
    jsonResponse([
        'success' => true,
        'data' => [
            'service' => $service,
            'reviews' => $reviews,
            'rating_stats' => $ratingStats
        ]
    ]);
    
} catch (PDOException $e) {
    error_log("Get service error: " . $e->getMessage());
    jsonResponse(['error' => 'خطأ في جلب الخدمة'], 500);
}
?> 