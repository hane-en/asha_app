<?php
require_once '../../config/config.php';
require_once '../../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse(['error' => 'Method not allowed'], 405);
}

$token = verifyToken();
if ($token->user_type !== 'user') {
    jsonResponse(['error' => 'فقط المستخدمون العاديون يمكنهم طلب الانضمام كمزود خدمة'], 403);
}

$input = json_decode(file_get_contents('php://input'), true);

// التحقق من البيانات المطلوبة
if (!isset($input['business_name']) || !isset($input['business_description'])) {
    jsonResponse(['error' => 'اسم العمل ووصف العمل مطلوبان'], 400);
}

$businessName = validateInput($input['business_name']);
$businessDescription = validateInput($input['business_description']);
$businessPhone = isset($input['business_phone']) ? validateInput($input['business_phone']) : '';
$businessAddress = isset($input['business_address']) ? validateInput($input['business_address']) : '';
$businessLicense = isset($input['business_license']) ? validateInput($input['business_license']) : '';

// التحقق من صحة البيانات
if (strlen($businessName) < 3) {
    jsonResponse(['error' => 'اسم العمل يجب أن يكون 3 أحرف على الأقل'], 400);
}

if (strlen($businessDescription) < 10) {
    jsonResponse(['error' => 'وصف العمل يجب أن يكون 10 أحرف على الأقل'], 400);
}

if ($businessPhone && !validatePhone($businessPhone)) {
    jsonResponse(['error' => 'رقم هاتف العمل غير صالح'], 400);
}

$pdo = getDBConnection();
if (!$pdo) {
    jsonResponse(['error' => 'خطأ في الاتصال بقاعدة البيانات'], 500);
}

try {
    // التحقق من عدم وجود طلب سابق
    $stmt = $pdo->prepare("
        SELECT id FROM provider_requests 
        WHERE user_id = ? AND status = 'pending'
    ");
    $stmt->execute([$token->user_id]);
    if ($stmt->fetch()) {
        jsonResponse(['error' => 'لديك طلب انضمام قيد المراجعة بالفعل'], 400);
    }
    
    // إنشاء طلب الانضمام
    $stmt = $pdo->prepare("
        INSERT INTO provider_requests (user_id, business_name, business_description, business_phone, business_address, business_license) 
        VALUES (?, ?, ?, ?, ?, ?)
    ");
    $stmt->execute([
        $token->user_id,
        $businessName,
        $businessDescription,
        $businessPhone,
        $businessAddress,
        $businessLicense
    ]);
    
    $requestId = $pdo->lastInsertId();
    
    // إنشاء إشعار للمديرين
    $stmt = $pdo->prepare("
        INSERT INTO notifications (user_id, title, message, type) 
        SELECT id, 'طلب انضمام جديد', ?, 'system'
        FROM users 
        WHERE user_type = 'admin'
    ");
    $stmt->execute(['طلب انضمام جديد من: ' . $businessName]);
    
    jsonResponse([
        'success' => true,
        'message' => 'تم إرسال طلب الانضمام بنجاح',
        'request_id' => $requestId
    ]);
    
} catch (PDOException $e) {
    error_log("Join provider error: " . $e->getMessage());
    jsonResponse(['error' => 'خطأ في إرسال طلب الانضمام'], 500);
}
?> 