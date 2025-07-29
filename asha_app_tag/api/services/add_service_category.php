<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

require_once '../../config.php';
require_once '../../database.php';

// التحقق من نوع الطلب
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
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
    
    // التحقق من البيانات المطلوبة
    $required_fields = ['service_id', 'name', 'price'];
    foreach ($required_fields as $field) {
        if (!isset($input[$field]) || empty($input[$field])) {
            http_response_code(400);
            echo json_encode([
                'success' => false,
                'message' => "الحقل '$field' مطلوب",
                'data' => null
            ], JSON_UNESCAPED_UNICODE);
            exit();
        }
    }
    
    // التحقق من وجود الخدمة
    $service_id = intval($input['service_id']);
    $stmt = $pdo->prepare("SELECT id FROM services WHERE id = ? AND is_active = 1");
    $stmt->execute([$service_id]);
    
    if (!$stmt->fetch()) {
        http_response_code(404);
        echo json_encode([
            'success' => false,
            'message' => 'الخدمة غير موجودة',
            'data' => null
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }
    
    // إعداد البيانات للإدخال
    $data = [
        'service_id' => $service_id,
        'name' => trim($input['name']),
        'description' => isset($input['description']) ? trim($input['description']) : '',
        'price' => floatval($input['price']),
        'image' => isset($input['image']) ? trim($input['image']) : '',
        'size' => isset($input['size']) ? trim($input['size']) : '',
        'dimensions' => isset($input['dimensions']) ? trim($input['dimensions']) : '',
        'location' => isset($input['location']) ? trim($input['location']) : '',
        'quantity' => isset($input['quantity']) ? intval($input['quantity']) : 1,
        'duration' => isset($input['duration']) ? trim($input['duration']) : '',
        'materials' => isset($input['materials']) ? trim($input['materials']) : '',
        'additional_features' => isset($input['additional_features']) ? trim($input['additional_features']) : '',
        'is_active' => isset($input['is_active']) ? intval($input['is_active']) : 1
    ];
    
    // إدراج فئة الخدمة الجديدة
    $query = "
        INSERT INTO service_categories (
            service_id, name, description, price, image, size, dimensions, 
            location, quantity, duration, materials, additional_features, is_active, created_at
        ) VALUES (
            :service_id, :name, :description, :price, :image, :size, :dimensions,
            :location, :quantity, :duration, :materials, :additional_features, :is_active, NOW()
        )
    ";
    
    $stmt = $pdo->prepare($query);
    $stmt->execute($data);
    
    $category_id = $pdo->lastInsertId();
    
    // جلب البيانات المدرجة
    $query = "
        SELECT 
            sc.*,
            s.title as service_title,
            u.name as provider_name
        FROM service_categories sc
        INNER JOIN services s ON sc.service_id = s.id
        INNER JOIN users u ON s.provider_id = u.id
        WHERE sc.id = ?
    ";
    
    $stmt = $pdo->prepare($query);
    $stmt->execute([$category_id]);
    $category = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($category) {
        $response_data = [
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
            'updated_at' => $category['updated_at'],
            'service_title' => $category['service_title'],
            'provider_name' => $category['provider_name']
        ];
        
        echo json_encode([
            'success' => true,
            'message' => 'تم إضافة فئة الخدمة بنجاح',
            'data' => $response_data
        ], JSON_UNESCAPED_UNICODE);
    } else {
        throw new Exception('فشل في جلب البيانات المدرجة');
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