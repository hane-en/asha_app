<?php
/**
 * API endpoint لإنشاء حجز جديد
 * POST /api/bookings/create.php
 */

require_once '../../config.php';
require_once '../../database.php';
require_once '../../middleware.php';

// التحقق من طريقة الطلب
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    errorResponse('طريقة الطلب غير مدعومة', 405);
}

// التحقق من المصادقة
$user = $middleware->requireAuth();

// الحصول على البيانات
$input = json_decode(file_get_contents('php://input'), true);

if (!$input) {
    errorResponse('بيانات غير صحيحة');
}

// التحقق من وجود البيانات المطلوبة
$requiredFields = ['service_id', 'booking_date', 'booking_time'];
$middleware->validateRequiredParams($input, $requiredFields);

// تنظيف البيانات
$serviceId = (int)$input['service_id'];
$bookingDate = sanitizeInput($input['booking_date']);
$bookingTime = sanitizeInput($input['booking_time']);
$notes = isset($input['notes']) ? sanitizeInput($input['notes']) : null;

// التحقق من صحة التاريخ والوقت
$middleware->validateDate($bookingDate);
$middleware->validateTime($bookingTime);

try {
    $database = new Database();
    $database->connect();

    // التحقق من وجود الخدمة
    $service = $database->selectOne(
        "SELECT s.*, u.id as provider_id FROM services s 
         LEFT JOIN users u ON s.provider_id = u.id 
         WHERE s.id = :id AND s.is_active = 1 AND s.is_verified = 1",
        ['id' => $serviceId]
    );

    if (!$service) {
        errorResponse('الخدمة غير موجودة', 404);
    }

    // التحقق من أن المستخدم لا يحجز خدمته الخاصة
    if ($service['provider_id'] == $user['id']) {
        errorResponse('لا يمكنك حجز خدمتك الخاصة');
    }

    // التحقق من أن التاريخ في المستقبل
    $bookingDateTime = $bookingDate . ' ' . $bookingTime;
    if (strtotime($bookingDateTime) <= time()) {
        errorResponse('يجب أن يكون موعد الحجز في المستقبل');
    }

    // التحقق من عدم وجود حجز مسبق في نفس الوقت
    $existingBooking = $database->selectOne(
        "SELECT id FROM bookings 
         WHERE service_id = :service_id 
         AND booking_date = :booking_date 
         AND booking_time = :booking_time 
         AND status IN ('pending', 'confirmed')",
        [
            'service_id' => $serviceId,
            'booking_date' => $bookingDate,
            'booking_time' => $bookingTime
        ]
    );

    if ($existingBooking) {
        errorResponse('هذا الموعد محجوز مسبقاً');
    }

    // بدء المعاملة
    $database->beginTransaction();

    // إنشاء الحجز
    $bookingData = [
        'user_id' => $user['id'],
        'service_id' => $serviceId,
        'provider_id' => $service['provider_id'],
        'booking_date' => $bookingDate,
        'booking_time' => $bookingTime,
        'total_price' => $service['price'],
        'notes' => $notes,
        'status' => 'pending',
        'payment_status' => 'pending'
    ];

    $bookingId = $database->insert('bookings', $bookingData);

    if (!$bookingId) {
        $database->rollback();
        errorResponse('فشل في إنشاء الحجز');
    }

    // تحديث عداد الحجوزات للخدمة
    $database->query(
        "UPDATE services SET booking_count = booking_count + 1 WHERE id = :id",
        ['id' => $serviceId]
    );

    // إنشاء إشعار للمزود
    $notificationData = [
        'user_id' => $service['provider_id'],
        'title' => 'حجز جديد',
        'message' => "لديك حجز جديد من {$user['name']} للخدمة {$service['title']}",
        'type' => 'booking'
    ];
    $database->insert('notifications', $notificationData);

    // إنشاء إشعار للمستخدم
    $userNotificationData = [
        'user_id' => $user['id'],
        'title' => 'تم إنشاء الحجز',
        'message' => "تم إنشاء حجزك للخدمة {$service['title']} بنجاح",
        'type' => 'booking'
    ];
    $database->insert('notifications', $userNotificationData);

    // تأكيد المعاملة
    $database->commit();

    // جلب تفاصيل الحجز المُنشأ
    $newBooking = $database->selectOne(
        "SELECT 
            b.*,
            s.title as service_title,
            s.images as service_images,
            u.name as provider_name,
            u.phone as provider_phone
         FROM bookings b
         LEFT JOIN services s ON b.service_id = s.id
         LEFT JOIN users u ON b.provider_id = u.id
         WHERE b.id = :id",
        ['id' => $bookingId]
    );

    // معالجة البيانات
    $newBooking['service_images'] = json_decode($newBooking['service_images'], true) ?: [];
    $newBooking['total_price'] = (float)$newBooking['total_price'];

    // تسجيل النشاط
    $middleware->logActivity($user['id'], 'create_booking', "Booking ID: {$bookingId}");

    successResponse($newBooking, 'تم إنشاء الحجز بنجاح');

} catch (Exception $e) {
    if ($database->conn->inTransaction()) {
        $database->rollback();
    }
    logError("Create booking error: " . $e->getMessage());
    errorResponse('حدث خطأ أثناء إنشاء الحجز', 500);
}

?>

