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
    
    // جلب جميع طلبات مزودي الخدمة
    $query = "
        SELECT 
            pr.id,
            pr.user_id,
            pr.business_name,
            pr.business_description,
            pr.business_phone,
            pr.business_address,
            pr.business_license,
            pr.service_category,
            pr.status,
            pr.admin_notes,
            pr.created_at,
            pr.updated_at,
            COALESCE(u.name, 'غير محدد') as user_name,
            COALESCE(u.email, 'غير محدد') as user_email,
            COALESCE(u.phone, 'غير محدد') as user_phone
        FROM provider_requests pr
        LEFT JOIN users u ON pr.user_id = u.id
        ORDER BY pr.created_at DESC
    ";
    
    $stmt = $pdo->prepare($query);
    $stmt->execute();
    $requests = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // معالجة البيانات
    foreach ($requests as &$request) {
        $request['id'] = intval($request['id']);
        $request['user_id'] = intval($request['user_id']);
        
        // تحويل التواريخ
        if ($request['created_at']) {
            $request['created_at'] = date('Y-m-d H:i:s', strtotime($request['created_at']));
        }
        if ($request['updated_at']) {
            $request['updated_at'] = date('Y-m-d H:i:s', strtotime($request['updated_at']));
        }
        
        // إضافة معلومات إضافية
        $request['status_text'] = getRequestStatusText($request['status']);
        $request['status_color'] = getRequestStatusColor($request['status']);
        $request['formatted_date'] = date('Y-m-d', strtotime($request['created_at']));
    }
    
    // إحصائيات
    $total_requests = count($requests);
    $pending_requests = count(array_filter($requests, function($r) { return $r['status'] === 'pending'; }));
    $approved_requests = count(array_filter($requests, function($r) { return $r['status'] === 'approved'; }));
    $rejected_requests = count(array_filter($requests, function($r) { return $r['status'] === 'rejected'; }));
    
    $stats = [
        'total_requests' => $total_requests,
        'pending_requests' => $pending_requests,
        'approved_requests' => $approved_requests,
        'rejected_requests' => $rejected_requests
    ];
    
    echo json_encode([
        'success' => true,
        'message' => 'تم جلب طلبات مزودي الخدمة بنجاح',
        'data' => $requests,
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

// دالة للحصول على نص حالة الطلب
function getRequestStatusText($status) {
    switch ($status) {
        case 'pending':
            return 'في الانتظار';
        case 'approved':
            return 'مقبول';
        case 'rejected':
            return 'مرفوض';
        default:
            return 'غير محدد';
    }
}

// دالة للحصول على لون حالة الطلب
function getRequestStatusColor($status) {
    switch ($status) {
        case 'pending':
            return '#FFA500'; // برتقالي
        case 'approved':
            return '#008000'; // أخضر
        case 'rejected':
            return '#FF0000'; // أحمر
        default:
            return '#808080'; // رمادي
    }
}
?> 