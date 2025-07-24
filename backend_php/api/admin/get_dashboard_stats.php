<?php
require_once '../../config/config.php';
require_once '../../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    jsonResponse(['error' => 'Method not allowed'], 405);
}

$token = verifyToken();
if ($token->user_type !== 'admin') {
    jsonResponse(['error' => 'فقط المديرون يمكنهم الوصول لهذا المورد'], 403);
}

$pdo = getDBConnection();
if (!$pdo) {
    jsonResponse(['error' => 'خطأ في الاتصال بقاعدة البيانات'], 500);
}

try {
    // إحصائيات المستخدمين
    $stmt = $pdo->prepare("
        SELECT 
            COUNT(*) as total_users,
            COUNT(CASE WHEN user_type = 'user' THEN 1 END) as regular_users,
            COUNT(CASE WHEN user_type = 'provider' THEN 1 END) as providers,
            COUNT(CASE WHEN user_type = 'admin' THEN 1 END) as admins,
            COUNT(CASE WHEN created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY) THEN 1 END) as new_users_month
        FROM users 
        WHERE is_active = 1
    ");
    $stmt->execute();
    $userStats = $stmt->fetch();
    
    // إحصائيات الخدمات
    $stmt = $pdo->prepare("
        SELECT 
            COUNT(*) as total_services,
            COUNT(CASE WHEN is_active = 1 THEN 1 END) as active_services,
            COUNT(CASE WHEN created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY) THEN 1 END) as new_services_month
        FROM services
    ");
    $stmt->execute();
    $serviceStats = $stmt->fetch();
    
    // إحصائيات الحجوزات
    $stmt = $pdo->prepare("
        SELECT 
            COUNT(*) as total_bookings,
            COUNT(CASE WHEN status = 'pending' THEN 1 END) as pending_bookings,
            COUNT(CASE WHEN status = 'confirmed' THEN 1 END) as confirmed_bookings,
            COUNT(CASE WHEN status = 'completed' THEN 1 END) as completed_bookings,
            COUNT(CASE WHEN status = 'cancelled' THEN 1 END) as cancelled_bookings,
            COUNT(CASE WHEN created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY) THEN 1 END) as new_bookings_month,
            SUM(CASE WHEN status = 'completed' THEN total_price ELSE 0 END) as total_revenue
        FROM bookings
    ");
    $stmt->execute();
    $bookingStats = $stmt->fetch();
    
    // إحصائيات طلبات الانضمام
    $stmt = $pdo->prepare("
        SELECT 
            COUNT(*) as total_requests,
            COUNT(CASE WHEN status = 'pending' THEN 1 END) as pending_requests,
            COUNT(CASE WHEN status = 'approved' THEN 1 END) as approved_requests,
            COUNT(CASE WHEN status = 'rejected' THEN 1 END) as rejected_requests
        FROM provider_requests
    ");
    $stmt->execute();
    $requestStats = $stmt->fetch();
    
    // الخدمات الأكثر شعبية
    $stmt = $pdo->prepare("
        SELECT s.title, s.rating, COUNT(b.id) as booking_count
        FROM services s
        LEFT JOIN bookings b ON s.id = b.service_id
        WHERE s.is_active = 1
        GROUP BY s.id
        ORDER BY booking_count DESC
        LIMIT 5
    ");
    $stmt->execute();
    $popularServices = $stmt->fetchAll();
    
    // الفئات الأكثر شعبية
    $stmt = $pdo->prepare("
        SELECT c.name, COUNT(s.id) as service_count
        FROM categories c
        LEFT JOIN services s ON c.id = s.category_id AND s.is_active = 1
        WHERE c.is_active = 1
        GROUP BY c.id
        ORDER BY service_count DESC
        LIMIT 5
    ");
    $stmt->execute();
    $popularCategories = $stmt->fetchAll();
    
    jsonResponse([
        'success' => true,
        'data' => [
            'user_stats' => $userStats,
            'service_stats' => $serviceStats,
            'booking_stats' => $bookingStats,
            'request_stats' => $requestStats,
            'popular_services' => $popularServices,
            'popular_categories' => $popularCategories
        ]
    ]);
    
} catch (PDOException $e) {
    error_log("Get dashboard stats error: " . $e->getMessage());
    jsonResponse(['error' => 'خطأ في جلب الإحصائيات'], 500);
}
?> 