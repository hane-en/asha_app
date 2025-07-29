<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

require_once '../../config.php';
require_once '../../database.php';

// التحقق من نوع الطلب
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
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
    
    // التحقق من وجود معرف فئة الخدمة
    if (!isset($_GET['id']) || empty($_GET['id'])) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'معرف فئة الخدمة مطلوب',
            'data' => null
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }
    
    $category_id = intval($_GET['id']);
    
    // جلب فئة الخدمة مع تفاصيل الخدمة والمزود
    $query = "
        SELECT 
            sc.id, sc.service_id, sc.name, sc.description, sc.price, sc.image, sc.size, sc.dimensions,
            sc.location, sc.quantity, sc.duration, sc.materials, sc.additional_features, sc.is_active,
            sc.created_at, sc.updated_at,
            s.title as service_title, s.description as service_description, s.price as service_price,
            s.images as service_images, s.city as service_city,
            u.id as provider_id, u.name as provider_name, u.phone as provider_phone,
            c.name as category_name
        FROM service_categories sc
        INNER JOIN services s ON sc.service_id = s.id
        INNER JOIN users u ON s.provider_id = u.id
        INNER JOIN categories c ON s.category_id = c.id
        WHERE sc.id = ?
    ";
    
    $stmt = $pdo->prepare($query);
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
    
    // تحويل البيانات الرقمية
    $category['id'] = intval($category['id']);
    $category['service_id'] = intval($category['service_id']);
    $category['price'] = floatval($category['price']);
    $category['quantity'] = intval($category['quantity']);
    $category['is_active'] = boolval($category['is_active']);
    $category['provider_id'] = intval($category['provider_id']);
    
    // تحويل صور الخدمة إلى مصفوفة
    if ($category['service_images']) {
        $category['service_images'] = json_decode($category['service_images'], true) ?: [];
    } else {
        $category['service_images'] = [];
    }
    
    echo json_encode([
        'success' => true,
        'message' => 'تم جلب فئة الخدمة بنجاح',
        'data' => $category
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
?> 