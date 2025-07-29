<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, PUT, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

require_once '../../config.php';
require_once '../../database.php';

// التحقق من نوع الطلب
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST' && $_SERVER['REQUEST_METHOD'] !== 'PUT') {
    http_response_code(405);
    echo json_encode([
        'success' => false,
        'message' => 'طريقة الطلب غير مسموحة',
        'data' => null
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // قراءة البيانات المرسلة
    $input = json_decode(file_get_contents('php://input'), true);
    
    // التحقق من وجود معرف فئة الخدمة
    if (!isset($input['id']) || empty($input['id'])) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'معرف فئة الخدمة مطلوب',
            'data' => null
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }
    
    $category_id = intval($input['id']);
    
    // التحقق من وجود فئة الخدمة
    $stmt = $pdo->prepare("
        SELECT 
            sc.*,
            s.provider_id,
            s.title as service_title,
            u.name as provider_name
        FROM service_categories sc
        INNER JOIN services s ON sc.service_id = s.id
        INNER JOIN users u ON s.provider_id = u.id
        WHERE sc.id = ?
    ");
    $stmt->execute([$category_id]);
    $category = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$category) {
        http_response_code(404);
        echo json_encode([
            'success' => false,
            'message' => 'فئة الخدمة غير موجودة',
            'data' => null
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }
    
    // التحقق من أن المزود يملك هذه الفئة (اختياري - يمكن إزالة هذا التحقق)
    if (isset($input['provider_id']) && $category['provider_id'] != $input['provider_id']) {
        http_response_code(403);
        echo json_encode([
            'success' => false,
            'message' => 'غير مصرح لك بتعديل هذه الفئة',
            'data' => null
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }
    
    // تجهيز البيانات للتحديث
    $updateData = [];
    $params = [];
    
    // الحقول المطلوبة
    if (isset($input['name'])) {
        $updateData[] = 'name = ?';
        $params[] = $input['name'];
    }
    
    if (isset($input['description'])) {
        $updateData[] = 'description = ?';
        $params[] = $input['description'];
    }
    
    if (isset($input['price'])) {
        $updateData[] = 'price = ?';
        $params[] = floatval($input['price']);
    }
    
    if (isset($input['image'])) {
        $updateData[] = 'image = ?';
        $params[] = $input['image'];
    }
    
    // الحقول الاختيارية
    if (isset($input['size'])) {
        $updateData[] = 'size = ?';
        $params[] = $input['size'];
    }
    
    if (isset($input['dimensions'])) {
        $updateData[] = 'dimensions = ?';
        $params[] = $input['dimensions'];
    }
    
    if (isset($input['location'])) {
        $updateData[] = 'location = ?';
        $params[] = $input['location'];
    }
    
    if (isset($input['quantity'])) {
        $updateData[] = 'quantity = ?';
        $params[] = intval($input['quantity']);
    }
    
    if (isset($input['duration'])) {
        $updateData[] = 'duration = ?';
        $params[] = $input['duration'];
    }
    
    if (isset($input['materials'])) {
        $updateData[] = 'materials = ?';
        $params[] = $input['materials'];
    }
    
    if (isset($input['additional_features'])) {
        $updateData[] = 'additional_features = ?';
        $params[] = $input['additional_features'];
    }
    
    if (isset($input['is_active'])) {
        $updateData[] = 'is_active = ?';
        $params[] = boolval($input['is_active']);
    }
    
    // إضافة معرف الفئة وتاريخ التحديث
    $params[] = $category_id;
    $updateData[] = 'updated_at = NOW()';
    
    if (empty($updateData)) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'لا توجد بيانات للتحديث',
            'data' => null
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }
    
    // تحديث فئة الخدمة
    $query = "UPDATE service_categories SET " . implode(', ', $updateData) . " WHERE id = ?";
    $stmt = $pdo->prepare($query);
    $result = $stmt->execute($params);
    
    if ($result) {
        // جلب البيانات المحدثة
        $stmt = $pdo->prepare("
            SELECT 
                sc.*,
                s.title as service_title,
                u.name as provider_name
            FROM service_categories sc
            INNER JOIN services s ON sc.service_id = s.id
            INNER JOIN users u ON s.provider_id = u.id
            WHERE sc.id = ?
        ");
        $stmt->execute([$category_id]);
        $updatedCategory = $stmt->fetch(PDO::FETCH_ASSOC);
        
        echo json_encode([
            'success' => true,
            'message' => 'تم تحديث فئة الخدمة بنجاح',
            'data' => $updatedCategory
        ], JSON_UNESCAPED_UNICODE);
    } else {
        throw new Exception('فشل في تحديث فئة الخدمة');
    }
    
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
?> 