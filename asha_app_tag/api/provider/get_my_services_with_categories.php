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
    
    // التحقق من وجود معرف المزود
    if (!isset($_GET['provider_id']) || empty($_GET['provider_id'])) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'معرف المزود مطلوب',
            'data' => null
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }
    
    $provider_id = intval($_GET['provider_id']);
    
    // جلب خدمات المزود مع فئاتها
    $query = "
        SELECT 
            s.id as service_id,
            s.title as service_title,
            s.description as service_description,
            s.price as service_price,
            s.images as service_images,
            s.city as service_city,
            s.is_active as service_is_active,
            s.is_verified as service_is_verified,
            s.created_at as service_created_at,
            c.id as category_id,
            c.name as category_name,
            sc.id as service_category_id,
            sc.name as service_category_name,
            sc.description as service_category_description,
            sc.price as service_category_price,
            sc.image as service_category_image,
            sc.size as service_category_size,
            sc.dimensions as service_category_dimensions,
            sc.location as service_category_location,
            sc.quantity as service_category_quantity,
            sc.duration as service_category_duration,
            sc.materials as service_category_materials,
            sc.additional_features as service_category_additional_features,
            sc.is_active as service_category_is_active,
            sc.created_at as service_category_created_at
        FROM services s
        INNER JOIN categories c ON s.category_id = c.id
        LEFT JOIN service_categories sc ON s.id = sc.service_id
        WHERE s.provider_id = ?
        ORDER BY s.id ASC, sc.price ASC
    ";
    
    $stmt = $pdo->prepare($query);
    $stmt->execute([$provider_id]);
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // تنظيم البيانات
    $services = [];
    $current_service_id = null;
    $current_service = null;
    
    foreach ($results as $row) {
        $service_id = $row['service_id'];
        
        // إذا كانت خدمة جديدة
        if ($service_id !== $current_service_id) {
            if ($current_service !== null) {
                $services[] = $current_service;
            }
            
            $current_service = [
                'id' => intval($service_id),
                'title' => $row['service_title'],
                'description' => $row['service_description'],
                'price' => floatval($row['service_price']),
                'images' => json_decode($row['service_images'], true) ?: [],
                'city' => $row['service_city'],
                'is_active' => boolval($row['service_is_active']),
                'is_verified' => boolval($row['service_is_verified']),
                'created_at' => $row['service_created_at'],
                'category' => [
                    'id' => intval($row['category_id']),
                    'name' => $row['category_name']
                ],
                'service_categories' => []
            ];
            
            $current_service_id = $service_id;
        }
        
        // إضافة فئة الخدمة إذا كانت موجودة
        if ($row['service_category_id'] !== null) {
            $current_service['service_categories'][] = [
                'id' => intval($row['service_category_id']),
                'name' => $row['service_category_name'],
                'description' => $row['service_category_description'],
                'price' => floatval($row['service_category_price']),
                'image' => $row['service_category_image'],
                'size' => $row['service_category_size'],
                'dimensions' => $row['service_category_dimensions'],
                'location' => $row['service_category_location'],
                'quantity' => intval($row['service_category_quantity']),
                'duration' => $row['service_category_duration'],
                'materials' => $row['service_category_materials'],
                'additional_features' => $row['service_category_additional_features'],
                'is_active' => boolval($row['service_category_is_active']),
                'created_at' => $row['service_category_created_at']
            ];
        }
    }
    
    // إضافة آخر خدمة
    if ($current_service !== null) {
        $services[] = $current_service;
    }
    
    // إحصائيات
    $total_services = count($services);
    $total_categories = 0;
    $active_services = 0;
    $verified_services = 0;
    
    foreach ($services as $service) {
        $total_categories += count($service['service_categories']);
        if ($service['is_active']) $active_services++;
        if ($service['is_verified']) $verified_services++;
    }
    
    $stats = [
        'total_services' => $total_services,
        'total_categories' => $total_categories,
        'active_services' => $active_services,
        'verified_services' => $verified_services,
        'average_categories_per_service' => $total_services > 0 ? round($total_categories / $total_services, 2) : 0
    ];
    
    echo json_encode([
        'success' => true,
        'message' => 'تم جلب الخدمات وفئاتها بنجاح',
        'data' => $services,
        'stats' => $stats
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