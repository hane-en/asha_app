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
    
    // جلب الدفعات المعلقة
    $query = "
        SELECT 
            b.id as booking_id,
            b.total_price as amount,
            b.payment_status,
            b.payment_method,
            b.created_at,
            b.updated_at,
            s.title as service_title,
            COALESCE(u.name, 'غير محدد') as customer_name,
            COALESCE(u.phone, 'غير محدد') as customer_phone,
            COALESCE(p.name, 'غير محدد') as provider_name
        FROM bookings b
        LEFT JOIN services s ON b.service_id = s.id
        LEFT JOIN users u ON b.user_id = u.id
        LEFT JOIN users p ON b.provider_id = p.id
        WHERE b.payment_status = 'pending'
        ORDER BY b.created_at DESC
    ";
    
    $stmt = $pdo->prepare($query);
    $stmt->execute();
    $payments = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // معالجة البيانات
    foreach ($payments as &$payment) {
        $payment['booking_id'] = intval($payment['booking_id']);
        $payment['amount'] = floatval($payment['amount']);
        
        // تحويل التواريخ
        if ($payment['created_at']) {
            $payment['created_at'] = date('Y-m-d H:i:s', strtotime($payment['created_at']));
        }
        if ($payment['updated_at']) {
            $payment['updated_at'] = date('Y-m-d H:i:s', strtotime($payment['updated_at']));
        }
        
        // إضافة معلومات إضافية
        $payment['status_text'] = getPaymentStatusText($payment['payment_status']);
        $payment['status_color'] = getPaymentStatusColor($payment['payment_status']);
    }
    
    // إحصائيات
    $total_payments = count($payments);
    $total_amount = array_sum(array_column($payments, 'amount'));
    
    $stats = [
        'total_payments' => $total_payments,
        'total_amount' => $total_amount,
        'pending_amount' => $total_amount
    ];
    
    echo json_encode([
        'success' => true,
        'message' => 'تم جلب الدفعات المعلقة بنجاح',
        'data' => $payments,
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

// دالة للحصول على نص حالة الدفع
function getPaymentStatusText($status) {
    switch ($status) {
        case 'pending':
            return 'في الانتظار';
        case 'completed':
            return 'مكتمل';
        case 'failed':
            return 'فشل';
        default:
            return 'غير محدد';
    }
}

// دالة للحصول على لون حالة الدفع
function getPaymentStatusColor($status) {
    switch ($status) {
        case 'pending':
            return '#FFA500'; // برتقالي
        case 'completed':
            return '#008000'; // أخضر
        case 'failed':
            return '#FF0000'; // أحمر
        default:
            return '#808080'; // رمادي
    }
}
?> 