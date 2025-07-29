<?php
// إيقاف عرض الأخطاء لمنع ظهور warnings في JSON
error_reporting(0);
ini_set('display_errors', 0);

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

require_once '../../config.php';
require_once '../../database.php';

// التحقق من نوع الطلب
if (isset($_SERVER['REQUEST_METHOD']) && $_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

try {
    $pdo = new PDO("mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=utf8mb4", DB_USER, DB_PASS);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // جلب جميع الحجوزات
    $query = "
        SELECT 
            b.id,
            b.service_id,
            b.user_id,
            b.provider_id,
            b.booking_date,
            b.booking_time,
            b.status,
            b.total_price as total_amount,
            b.notes,
            b.created_at,
            b.updated_at,
            s.title as service_title,
            s.price as service_price,
            COALESCE(u.name, 'غير محدد') as customer_name,
            COALESCE(u.phone, 'غير محدد') as customer_phone,
            COALESCE(p.name, 'غير محدد') as provider_name,
            COALESCE(p.phone, 'غير محدد') as provider_phone
        FROM bookings b
        LEFT JOIN services s ON b.service_id = s.id
        LEFT JOIN users u ON b.user_id = u.id
        LEFT JOIN users p ON b.provider_id = p.id
        ORDER BY b.created_at DESC
    ";
    
    $stmt = $pdo->prepare($query);
    $stmt->execute();
    $bookings = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // معالجة البيانات
    foreach ($bookings as &$booking) {
        $booking['id'] = intval($booking['id']);
        $booking['service_id'] = intval($booking['service_id']);
        $booking['user_id'] = intval($booking['user_id']);
        $booking['provider_id'] = intval($booking['provider_id']);
        $booking['total_amount'] = floatval($booking['total_amount']);
        
        // تحويل التواريخ
        if ($booking['created_at']) {
            $booking['created_at'] = date('Y-m-d H:i:s', strtotime($booking['created_at']));
        }
        if ($booking['updated_at']) {
            $booking['updated_at'] = date('Y-m-d H:i:s', strtotime($booking['updated_at']));
        }
        if ($booking['booking_date']) {
            $booking['booking_date'] = date('Y-m-d', strtotime($booking['booking_date']));
        }
        
        // إضافة معلومات إضافية
        $booking['status_text'] = getBookingStatusText($booking['status']);
        $booking['status_color'] = getBookingStatusColor($booking['status']);
    }
    
    // إحصائيات
    $total_bookings = count($bookings);
    $pending_bookings = count(array_filter($bookings, function($b) { return $b['status'] === 'pending'; }));
    $confirmed_bookings = count(array_filter($bookings, function($b) { return $b['status'] === 'confirmed'; }));
    $completed_bookings = count(array_filter($bookings, function($b) { return $b['status'] === 'completed'; }));
    $cancelled_bookings = count(array_filter($bookings, function($b) { return $b['status'] === 'cancelled'; }));
    
    $total_revenue = array_sum(array_column($bookings, 'total_amount'));
    
    $stats = [
        'total_bookings' => $total_bookings,
        'pending_bookings' => $pending_bookings,
        'confirmed_bookings' => $confirmed_bookings,
        'completed_bookings' => $completed_bookings,
        'cancelled_bookings' => $cancelled_bookings,
        'total_revenue' => $total_revenue
    ];
    
    echo json_encode([
        'success' => true,
        'message' => 'تم جلب الحجوزات بنجاح',
        'data' => $bookings,
        'stats' => $stats
    ], JSON_UNESCAPED_UNICODE);
    
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'خطأ في قاعدة البيانات: ' . $e->getMessage(),
        'data' => null
    ], JSON_UNESCAPED_UNICODE);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'خطأ عام: ' . $e->getMessage(),
        'data' => null
    ], JSON_UNESCAPED_UNICODE);
}

// دالة للحصول على نص حالة الحجز
function getBookingStatusText($status) {
    switch ($status) {
        case 'pending':
            return 'في الانتظار';
        case 'confirmed':
            return 'مؤكد';
        case 'completed':
            return 'مكتمل';
        case 'cancelled':
            return 'ملغي';
        default:
            return 'غير محدد';
    }
}

// دالة للحصول على لون حالة الحجز
function getBookingStatusColor($status) {
    switch ($status) {
        case 'pending':
            return '#FFA500'; // برتقالي
        case 'confirmed':
            return '#008000'; // أخضر
        case 'completed':
            return '#0000FF'; // أزرق
        case 'cancelled':
            return '#FF0000'; // أحمر
        default:
            return '#808080'; // رمادي
    }
}
?> 