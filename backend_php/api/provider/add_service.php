<?php
require_once '../../config/config.php';
require_once '../../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse(['error' => 'Method not allowed'], 405);
}

$token = verifyToken();
if ($token->user_type !== 'provider') {
    jsonResponse(['error' => 'فقط مزودي الخدمات يمكنهم إضافة خدمات'], 403);
}

$input = json_decode(file_get_contents('php://input'), true);

// التحقق من البيانات المطلوبة
if (!isset($input['category_id']) || !isset($input['title']) || !isset($input['price'])) {
    jsonResponse(['error' => 'جميع الحقول مطلوبة'], 400);
}

$categoryId = (int)$input['category_id'];
$title = validateInput($input['title']);
$description = isset($input['description']) ? validateInput($input['description']) : '';
$price = (float)$input['price'];
$duration = isset($input['duration']) ? (int)$input['duration'] : null;
$images = isset($input['images']) ? $input['images'] : [];

// التحقق من صحة البيانات
if (strlen($title) < 3) {
    jsonResponse(['error' => 'عنوان الخدمة يجب أن يكون 3 أحرف على الأقل'], 400);
}

if ($price <= 0) {
    jsonResponse(['error' => 'السعر يجب أن يكون أكبر من صفر'], 400);
}

$pdo = getDBConnection();
if (!$pdo) {
    jsonResponse(['error' => 'خطأ في الاتصال بقاعدة البيانات'], 500);
}

try {
    // التحقق من وجود الفئة
    $stmt = $pdo->prepare("SELECT id FROM categories WHERE id = ? AND is_active = 1");
    $stmt->execute([$categoryId]);
    if (!$stmt->fetch()) {
        jsonResponse(['error' => 'الفئة غير موجودة'], 404);
    }
    
    // التحقق من عدم وجود خدمة بنفس العنوان لنفس المزود
    $stmt = $pdo->prepare("SELECT id FROM services WHERE provider_id = ? AND title = ?");
    $stmt->execute([$token->user_id, $title]);
    if ($stmt->fetch()) {
        jsonResponse(['success' => false, 'message' => 'هذه الخدمة موجودة بالفعل ولا يمكن تكرارها.'], 400);
    }
    
    // إضافة الخدمة
    $stmt = $pdo->prepare("
        INSERT INTO services (provider_id, category_id, title, description, price, duration, images) 
        VALUES (?, ?, ?, ?, ?, ?, ?)
    ");
    $stmt->execute([
        $token->user_id,
        $categoryId,
        $title,
        $description,
        $price,
        $duration,
        json_encode($images)
    ]);
    
    $serviceId = $pdo->lastInsertId();
    
    jsonResponse([
        'success' => true,
        'message' => 'تم إضافة الخدمة بنجاح',
        'service_id' => $serviceId
    ]);
    
} catch (PDOException $e) {
    error_log("Add service error: " . $e->getMessage());
    jsonResponse(['error' => 'خطأ في إضافة الخدمة'], 500);
}
?> 