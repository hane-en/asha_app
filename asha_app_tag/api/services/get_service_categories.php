<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

require_once '../../config.php';
require_once '../../database.php';

// التحقق من نوع الطلب
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // التحقق من وجود معرف الخدمة
    if (!isset($_GET['service_id']) || empty($_GET['service_id'])) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'معرف الخدمة مطلوب',
            'data' => null
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }
    
    $service_id = intval($_GET['service_id']);
    
    // استعلام للحصول على فئات الخدمة
    $query = "
        SELECT 
            sc.id,
            sc.service_id,
            sc.name,
            sc.description,
            sc.price,
            sc.image,
            sc.size,
            sc.dimensions,
            sc.location,
            sc.quantity,
            sc.duration,
            sc.materials,
            sc.additional_features,
            sc.is_active,
            sc.created_at,
            sc.updated_at,
            s.title as service_title,
            s.description as service_description,
            s.price as service_price,
            s.images as service_images,
            s.city as service_city,
            u.name as provider_name,
            u.phone as provider_phone,
            c.name as category_name
        FROM service_categories sc
        INNER JOIN services s ON sc.service_id = s.id
        INNER JOIN users u ON s.provider_id = u.id
        INNER JOIN categories c ON s.category_id = c.id
        WHERE sc.service_id = :service_id 
        AND sc.is_active = 1 
        AND s.is_active = 1
        ORDER BY sc.price ASC
    ";
    
    $stmt = $pdo->prepare($query);
    $stmt->bindParam(':service_id', $service_id, PDO::PARAM_INT);
    $stmt->execute();
    
    $categories = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    if (empty($categories)) {
        echo json_encode([
            'success' => true,
            'message' => 'لا توجد فئات خدمة لهذه الخدمة',
            'data' => [],
            'service_info' => null
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }
    
    // معلومات الخدمة الأساسية
    $service_info = [
        'id' => $categories[0]['service_id'],
        'title' => $categories[0]['service_title'],
        'description' => $categories[0]['service_description'],
        'price' => $categories[0]['service_price'],
        'images' => json_decode($categories[0]['service_images'], true),
        'city' => $categories[0]['service_city'],
        'provider_name' => $categories[0]['provider_name'],
        'provider_phone' => $categories[0]['provider_phone'],
        'category_name' => $categories[0]['category_name']
    ];
    
    // تنظيف البيانات
    $cleaned_categories = [];
    foreach ($categories as $category) {
        $cleaned_categories[] = [
            'id' => intval($category['id']),
            'service_id' => intval($category['service_id']),
            'name' => $category['name'],
            'description' => $category['description'],
            'price' => floatval($category['price']),
            'image' => $category['image'],
            'size' => $category['size'],
            'dimensions' => $category['dimensions'],
            'location' => $category['location'],
            'quantity' => intval($category['quantity']),
            'duration' => $category['duration'],
            'materials' => $category['materials'],
            'additional_features' => $category['additional_features'],
            'is_active' => boolval($category['is_active']),
            'created_at' => $category['created_at'],
            'updated_at' => $category['updated_at']
        ];
    }
    
    echo json_encode([
        'success' => true,
        'message' => 'تم جلب فئات الخدمة بنجاح',
        'data' => $cleaned_categories,
        'service_info' => $service_info,
        'total_categories' => count($cleaned_categories)
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