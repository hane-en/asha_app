<?php
require_once '../../config.php';

header('Content-Type: application/json; charset=utf-8');
setupCORS();

if ($_SERVER['REQUEST_METHOD'] !== 'PUT') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit;
}

try {
    $input = json_decode(file_get_contents('php://input'), true);
    
    $serviceId = (int)($input['id'] ?? 0);
    $title = sanitizeInput($input['title'] ?? '');
    $description = sanitizeInput($input['description'] ?? '');
    $price = (float)($input['price'] ?? 0);
    $categoryId = (int)($input['category_id'] ?? 0);
    $location = sanitizeInput($input['location'] ?? '');
    $contactPhone = sanitizeInput($input['contact_phone'] ?? '');
    $contactEmail = sanitizeInput($input['contact_email'] ?? '');
    $isActive = (int)($input['is_active'] ?? 1);
    
    if ($serviceId <= 0) {
        echo json_encode(['success' => false, 'message' => 'معرف الخدمة مطلوب']);
        exit;
    }
    
    $pdo = getDatabaseConnection();
    
    // التحقق من وجود الخدمة
    $stmt = $pdo->prepare("SELECT id, provider_id FROM services WHERE id = ?");
    $stmt->execute([$serviceId]);
    $existingService = $stmt->fetch();
    
    if (!$existingService) {
        echo json_encode(['success' => false, 'message' => 'الخدمة غير موجودة']);
        exit;
    }
    
    // التحقق من وجود الفئة إذا تم تغييرها
    if ($categoryId > 0) {
        $stmt = $pdo->prepare("SELECT id FROM categories WHERE id = ? AND is_active = 1");
        $stmt->execute([$categoryId]);
        if (!$stmt->fetch()) {
            echo json_encode(['success' => false, 'message' => 'الفئة غير موجودة']);
            exit;
        }
    }
    
    // بناء استعلام التحديث
    $updateFields = [];
    $params = [];
    
    if (!empty($title)) {
        $updateFields[] = "title = ?";
        $params[] = $title;
    }
    
    if (!empty($description)) {
        $updateFields[] = "description = ?";
        $params[] = $description;
    }
    
    if ($price > 0) {
        $updateFields[] = "price = ?";
        $params[] = $price;
    }
    
    if ($categoryId > 0) {
        $updateFields[] = "category_id = ?";
        $params[] = $categoryId;
    }
    
    if (!empty($location)) {
        $updateFields[] = "location = ?";
        $params[] = $location;
    }
    
    if (!empty($contactPhone)) {
        $updateFields[] = "contact_phone = ?";
        $params[] = $contactPhone;
    }
    
    if (!empty($contactEmail)) {
        $updateFields[] = "contact_email = ?";
        $params[] = $contactEmail;
    }
    
    $updateFields[] = "is_active = ?";
    $params[] = $isActive;
    
    $updateFields[] = "updated_at = NOW()";
    $params[] = $serviceId;
    
    if (empty($updateFields)) {
        echo json_encode(['success' => false, 'message' => 'لا توجد بيانات للتحديث']);
        exit;
    }
    
    $query = "UPDATE services SET " . implode(', ', $updateFields) . " WHERE id = ?";
    $stmt = $pdo->prepare($query);
    $stmt->execute($params);
    
    // جلب الخدمة المحدثة
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
        'message' => 'تم تحديث الخدمة بنجاح',
        'data' => [
            'service' => $service
        ]
    ]);
    
} catch (Exception $e) {
    logError('Update service error: ' . $e->getMessage());
    echo json_encode(['success' => false, 'message' => 'خطأ في الخادم']);
}
?> 