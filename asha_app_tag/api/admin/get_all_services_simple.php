<?php
// إيقاف عرض الأخطاء لمنع ظهور warnings في JSON
error_reporting(0);
ini_set('display_errors', 0);

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

require_once '../../config.php';
require_once '../../database.php';

// التحقق من نوع الطلب
if (isset($_SERVER['REQUEST_METHOD']) && $_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

try {
    $pdo = new PDO("mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=utf8mb4", DB_USER, DB_PASS);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // جلب الخدمات مع فئاتها - مبسط
    $query = "
        SELECT 
            s.id,
            s.title,
            s.description,
            s.price,
            s.images,
            s.city,
            s.is_active,
            s.is_verified,
            s.created_at,
            COALESCE(u.name, 'غير محدد') as provider_name,
            COALESCE(c.name, 'غير محدد') as category_name
        FROM services s
        LEFT JOIN users u ON s.provider_id = u.id
        LEFT JOIN categories c ON s.category_id = c.id
        WHERE s.is_active = 1
        ORDER BY s.id ASC
    ";
    
    $stmt = $pdo->prepare($query);
    $stmt->execute();
    $services = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // جلب فئات الخدمات لكل خدمة
    $services_with_categories = [];
    
    foreach ($services as $service) {
        // جلب فئات الخدمة لهذه الخدمة
        $categories_query = "
            SELECT 
                id,
                name,
                description,
                price,
                image,
                size,
                dimensions,
                location,
                quantity,
                duration,
                materials,
                additional_features,
                is_active,
                created_at
            FROM service_categories
            WHERE service_id = ?
            ORDER BY id ASC
        ";
        
        $stmt = $pdo->prepare($categories_query);
        $stmt->execute([$service['id']]);
        $categories = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        // تنظيم البيانات
        $service_data = [
            'id' => intval($service['id']),
            'title' => $service['title'],
            'description' => $service['description'],
            'price' => floatval($service['price']),
            'images' => json_decode($service['images'], true) ?: [],
            'city' => $service['city'],
            'is_active' => boolval($service['is_active']),
            'is_verified' => boolval($service['is_verified']),
            'created_at' => $service['created_at'],
            'provider_name' => $service['provider_name'],
            'category_name' => $service['category_name'],
            'service_categories' => []
        ];
        
        // إضافة فئات الخدمة
        foreach ($categories as $category) {
            $service_data['service_categories'][] = [
                'id' => intval($category['id']),
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
                'created_at' => $category['created_at']
            ];
        }
        
        $services_with_categories[] = $service_data;
    }
    
    // إحصائيات
    $total_services = count($services_with_categories);
    $total_categories = 0;
    $active_services = 0;
    $verified_services = 0;
    
    foreach ($services_with_categories as $service) {
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
        'data' => $services_with_categories,
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