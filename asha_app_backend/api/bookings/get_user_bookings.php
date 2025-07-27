<?php
/**
 * API endpoint لجلب حجوزات المستخدم
 * GET /api/bookings/get_user_bookings.php
 */

require_once '../../config.php';
require_once '../../database.php';
require_once '../../middleware.php';

// التحقق من طريقة الطلب
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    errorResponse('طريقة الطلب غير مدعومة', 405);
}

// التحقق من المصادقة
$user = $middleware->requireAuth();

// الحصول على المعاملات
$page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
$limit = isset($_GET['limit']) ? (int)$_GET['limit'] : PAGINATION_LIMIT;
$status = isset($_GET['status']) ? sanitizeInput($_GET['status']) : null;

try {
    $database = new Database();
    $database->connect();

    // بناء الاستعلام
    $whereConditions = ['b.user_id = :user_id'];
    $params = ['user_id' => $user['id']];

    if ($status) {
        $whereConditions[] = 'b.status = :status';
        $params['status'] = $status;
    }

    $whereClause = implode(' AND ', $whereConditions);

    // الاستعلام الرئيسي
    $query = "
        SELECT 
            b.*,
            s.title as service_title,
            s.images as service_images,
            s.price as service_price,
            s.location as service_location,
            u.name as provider_name,
            u.phone as provider_phone,
            u.profile_image as provider_image,
            c.name as category_name
        FROM bookings b
        LEFT JOIN services s ON b.service_id = s.id
        LEFT JOIN users u ON b.provider_id = u.id
        LEFT JOIN categories c ON s.category_id = c.id
        WHERE {$whereClause}
        ORDER BY b.created_at DESC
        LIMIT :limit OFFSET :offset
    ";

    $offset = ($page - 1) * $limit;
    $params['limit'] = $limit;
    $params['offset'] = $offset;

    $bookings = $database->select($query, $params);

    // الحصول على العدد الإجمالي
    $countQuery = "
        SELECT COUNT(*) as total
        FROM bookings b
        WHERE {$whereClause}
    ";
    
    $countParams = $params;
    unset($countParams['limit']);
    unset($countParams['offset']);
    
    $totalResult = $database->selectOne($countQuery, $countParams);
    $total = $totalResult['total'];

    // معالجة البيانات
    foreach ($bookings as &$booking) {
        $booking['service_images'] = json_decode($booking['service_images'], true) ?: [];
        $booking['total_price'] = (float)$booking['total_price'];
        $booking['service_price'] = (float)$booking['service_price'];
        
        // حساب الحالة النسبية للحجز
        $bookingDateTime = $booking['booking_date'] . ' ' . $booking['booking_time'];
        $booking['is_past'] = strtotime($bookingDateTime) < time();
        $booking['can_cancel'] = $booking['status'] === 'pending' && !$booking['is_past'];
        $booking['can_review'] = $booking['status'] === 'completed' && !$booking['is_past'];
    }

    $response = [
        'bookings' => $bookings,
        'pagination' => [
            'current_page' => $page,
            'total_pages' => ceil($total / $limit),
            'total_items' => (int)$total,
            'items_per_page' => $limit
        ]
    ];

    successResponse($response, 'تم جلب الحجوزات بنجاح');

} catch (Exception $e) {
    logError("Get user bookings error: " . $e->getMessage());
    errorResponse('حدث خطأ أثناء جلب الحجوزات', 500);
}

?>

