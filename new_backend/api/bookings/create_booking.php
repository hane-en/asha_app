<?php
/**
 * ملف إنشاء حجز جديد
 * Create Booking API
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

require_once '../../config.php';

// التحقق من نوع الطلب
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
    exit;
}

try {
    // قراءة البيانات المرسلة
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!$input) {
        throw new Exception('Invalid JSON data');
    }
    
    // التحقق من البيانات المطلوبة
    $required_fields = ['user_id', 'service_id', 'date', 'time', 'total_price', 'payment_method'];
    foreach ($required_fields as $field) {
        if (!isset($input[$field]) || empty($input[$field])) {
            throw new Exception("Field '$field' is required");
        }
    }
    
    // التحقق من طريقة الدفع
    $allowed_payment_methods = ['cash', 'kareemi_bank'];
    if (!in_array($input['payment_method'], $allowed_payment_methods)) {
        throw new Exception('Invalid payment method');
    }
    
    // التحقق من صحة التاريخ
    $booking_date = DateTime::createFromFormat('Y-m-d', $input['date']);
    if (!$booking_date || $booking_date->format('Y-m-d') !== $input['date']) {
        throw new Exception('Invalid date format. Use YYYY-MM-DD');
    }
    
    // التحقق من أن التاريخ ليس في الماضي
    $today = new DateTime();
    $today->setTime(0, 0, 0);
    if ($booking_date < $today) {
        throw new Exception('Booking date cannot be in the past');
    }
    
    // التحقق من صحة الوقت
    $booking_time = DateTime::createFromFormat('H:i', $input['time']);
    if (!$booking_time || $booking_time->format('H:i') !== $input['time']) {
        throw new Exception('Invalid time format. Use HH:MM');
    }
    
    // التحقق من صحة السعر
    if (!is_numeric($input['total_price']) || $input['total_price'] <= 0) {
        throw new Exception('Invalid price');
    }
    
    // الاتصال بقاعدة البيانات
    $pdo = new PDO(
        "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=" . DB_CHARSET,
        DB_USER,
        DB_PASS,
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false
        ]
    );
    
    // التحقق من وجود المستخدم
    $stmt = $pdo->prepare("SELECT id, name, user_type FROM users WHERE id = ? AND is_active = 1");
    $stmt->execute([$input['user_id']]);
    $user = $stmt->fetch();
    
    if (!$user) {
        throw new Exception('User not found or inactive');
    }
    
    // التحقق من وجود الخدمة
    $stmt = $pdo->prepare("
        SELECT s.*, u.name as provider_name, u.kareemi_account_number 
        FROM services s 
        JOIN users u ON s.provider_id = u.id 
        WHERE s.id = ? AND s.is_active = 1
    ");
    $stmt->execute([$input['service_id']]);
    $service = $stmt->fetch();
    
    if (!$service) {
        throw new Exception('Service not found or inactive');
    }
    
    // التحقق من توفر الخدمة في التاريخ المحدد
    $stmt = $pdo->prepare("
        SELECT COUNT(*) as booking_count 
        FROM bookings 
        WHERE service_id = ? AND date = ? AND status IN ('pending', 'confirmed')
    ");
    $stmt->execute([$input['service_id'], $input['date']]);
    $existing_bookings = $stmt->fetch();
    
    // يمكن إضافة منطق للتحقق من الحد الأقصى للحجوزات في اليوم الواحد
    if ($existing_bookings['booking_count'] >= 5) { // مثال: حد أقصى 5 حجوزات في اليوم
        throw new Exception('Service is fully booked for this date');
    }
    
    // إعداد بيانات الحجز
    $booking_data = [
        'user_id' => $input['user_id'],
        'service_id' => $input['service_id'],
        'date' => $input['date'],
        'time' => $input['time'],
        'total_price' => $input['total_price'],
        'payment_method' => $input['payment_method'],
        'status' => 'pending',
        'payment_status' => 'pending',
        'note' => $input['note'] ?? null
    ];
    
    // إضافة بيانات إضافية لبنك الكريمي
    if ($input['payment_method'] === 'kareemi_bank') {
        if (!isset($input['kareemi_transaction_id']) || empty($input['kareemi_transaction_id'])) {
            throw new Exception('Kareemi transaction ID is required for bank payments');
        }
        $booking_data['kareemi_transaction_id'] = $input['kareemi_transaction_id'];
    }
    
    // إدراج الحجز
    $columns = implode(', ', array_keys($booking_data));
    $placeholders = ':' . implode(', :', array_keys($booking_data));
    
    $stmt = $pdo->prepare("INSERT INTO bookings ($columns) VALUES ($placeholders)");
    $stmt->execute($booking_data);
    
    $booking_id = $pdo->lastInsertId();
    
    // إنشاء سجل الدفع
    $payment_data = [
        'booking_id' => $booking_id,
        'user_id' => $input['user_id'],
        'amount' => $input['total_price'],
        'payment_method' => $input['payment_method'],
        'status' => 'pending'
    ];
    
    if ($input['payment_method'] === 'kareemi_bank') {
        $payment_data['kareemi_transaction_id'] = $input['kareemi_transaction_id'];
    }
    
    $payment_columns = implode(', ', array_keys($payment_data));
    $payment_placeholders = ':' . implode(', :', array_keys($payment_data));
    
    $stmt = $pdo->prepare("INSERT INTO payments ($payment_columns) VALUES ($payment_placeholders)");
    $stmt->execute($payment_data);
    
    // جلب بيانات الحجز المُنشأ
    $stmt = $pdo->prepare("
        SELECT b.*, s.title as service_name, u.name as provider_name, u.kareemi_account_number
        FROM bookings b
        JOIN services s ON b.service_id = s.id
        JOIN users u ON s.provider_id = u.id
        WHERE b.id = ?
    ");
    $stmt->execute([$booking_id]);
    $booking = $stmt->fetch();
    
    // إعداد الاستجابة
    $response = [
        'success' => true,
        'message' => 'تم إنشاء الحجز بنجاح',
        'data' => [
            'booking' => $booking,
            'payment_info' => [
                'method' => $input['payment_method'],
                'amount' => $input['total_price'],
                'status' => 'pending'
            ]
        ]
    ];
    
    // إضافة معلومات بنك الكريمي إذا كانت طريقة الدفع هي البنك
    if ($input['payment_method'] === 'kareemi_bank') {
        $response['data']['kareemi_info'] = [
            'provider_account' => $service['kareemi_account_number'],
            'transaction_id' => $input['kareemi_transaction_id'],
            'instructions' => 'يرجى تحويل المبلغ إلى الحساب المذكور أعلاه وإرفاق إثبات التحويل'
        ];
    }
    
    echo json_encode($response);
    
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'error' => 'Database error: ' . $e->getMessage()
    ]);
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'error' => $e->getMessage()
    ]);
}
?> 