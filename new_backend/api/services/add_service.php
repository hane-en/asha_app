<?php
require_once '../../config.php';

header('Content-Type: application/json; charset=utf-8');
setupCORS();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit;
}

try {
    $input = json_decode(file_get_contents('php://input'), true);
    
    $title = sanitizeInput($input['title'] ?? '');
    $description = sanitizeInput($input['description'] ?? '');
    $price = (float)($input['price'] ?? 0);
    $categoryId = (int)($input['category_id'] ?? 0);
    $providerId = (int)($input['provider_id'] ?? 0);
    $location = sanitizeInput($input['location'] ?? '');
    $contactPhone = sanitizeInput($input['contact_phone'] ?? '');
    $contactEmail = sanitizeInput($input['contact_email'] ?? '');
    $serviceImages = $input['images'] ?? [];
    
    // التحقق من البيانات المطلوبة
    if (empty($title) || empty($description) || $price <= 0 || $categoryId <= 0 || $providerId <= 0) {
        echo json_encode(['success' => false, 'message' => 'جميع الحقول المطلوبة يجب ملؤها']);
        exit;
    }
    
    $pdo = getDatabaseConnection();
    
    // التحقق من وجود الفئة
    $stmt = $pdo->prepare("SELECT id FROM categories WHERE id = ? AND is_active = 1");
    $stmt->execute([$categoryId]);
    if (!$stmt->fetch()) {
        echo json_encode(['success' => false, 'message' => 'الفئة غير موجودة']);
        exit;
    }
    
    // التحقق من وجود مزود الخدمة
    $stmt = $pdo->prepare("SELECT id FROM users WHERE id = ? AND user_type = 'provider' AND is_active = 1");
    $stmt->execute([$providerId]);
    if (!$stmt->fetch()) {
        echo json_encode(['success' => false, 'message' => 'مزود الخدمة غير موجود']);
        exit;
    }
    
    // إدراج الخدمة الجديدة
    $stmt = $pdo->prepare("INSERT INTO services (title, description, price, category_id, provider_id, location, contact_phone, contact_email, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW())");
    $stmt->execute([$title, $description, $price, $categoryId, $providerId, $location, $contactPhone, $contactEmail]);
    
    $serviceId = $pdo->lastInsertId();
    
    // إدراج صور الخدمة إذا وجدت
    if (!empty($serviceImages)) {
        $imageStmt = $pdo->prepare("INSERT INTO service_images (service_id, image_url, sort_order) VALUES (?, ?, ?)");
        foreach ($serviceImages as $index => $imageUrl) {
            $imageStmt->execute([$serviceId, $imageUrl, $index + 1]);
        }
    }
    
    // جلب الخدمة المضافة مع التفاصيل
    $query = "SELECT s.*, c.name as category_name, u.name as provider_name
              FROM services s 
              LEFT JOIN categories c ON s.category_id = c.id
              LEFT JOIN users u ON s.provider_id = u.id
              WHERE s.id = ?";
    
    $stmt = $pdo->prepare($query);
    $stmt->execute([$serviceId]);
    $service = $stmt->fetch(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'success' => true,
        'message' => 'تم إضافة الخدمة بنجاح',
        'data' => [
            'service' => $service
        ]
    ]);
    
} catch (Exception $e) {
    logError('Add service error: ' . $e->getMessage());
    echo json_encode(['success' => false, 'message' => 'خطأ في الخادم']);
}
?> 