<?php
/**
 * صفحة اختبار نظيفة للتحقق من API
 */

require_once '../config.php';
require_once '../database.php';

// إعداد CORS
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json; charset=utf-8');

try {
    $database = new Database();
    $database->connect();
    
    // محاكاة get_all.php
    $page = 1;
    $limit = 20;
    $offset = ($page - 1) * $limit;
    
    $query = "
        SELECT 
            s.*,
            c.name as category_name,
            u.name as provider_name
        FROM services s
        LEFT JOIN categories c ON s.category_id = c.id
        LEFT JOIN users u ON s.provider_id = u.id
        ORDER BY s.created_at DESC
        LIMIT $limit OFFSET $offset
    ";
    
    $services = $database->select($query);
    
    // معالجة البيانات
    if (is_array($services)) {
        foreach ($services as &$service) {
            // تحويل الأرقام الأساسية
            $service['id'] = (int)($service['id'] ?? 0);
            $service['price'] = (float)($service['price'] ?? 0);
            $service['category_id'] = (int)($service['category_id'] ?? 0);
            $service['provider_id'] = (int)($service['provider_id'] ?? 0);
            
            // تحويل القيم المنطقية
            $service['is_active'] = (bool)($service['is_active'] ?? false);
            $service['is_verified'] = (bool)($service['is_verified'] ?? false);
            
            // تحويل JSON strings إلى arrays
            $service['images'] = json_decode($service['images'], true) ?: [];
            $service['specifications'] = json_decode($service['specifications'], true) ?: [];
            $service['tags'] = json_decode($service['tags'], true) ?: [];
            $service['payment_terms'] = json_decode($service['payment_terms'], true) ?: [];
            $service['availability'] = json_decode($service['availability'], true) ?: [];
            
            // التأكد من وجود النصوص الأساسية
            $service['title'] = $service['title'] ?? '';
            $service['description'] = $service['description'] ?? '';
            $service['category_name'] = $service['category_name'] ?? '';
            $service['provider_name'] = $service['provider_name'] ?? '';
        }
    } else {
        $services = [];
    }
    
    // الحصول على العدد الإجمالي
    $countQuery = "SELECT COUNT(*) as total FROM services";
    $totalResult = $database->selectOne($countQuery);
    $total = $totalResult ? $totalResult['total'] : 0;
    
    $response = [
        'success' => true,
        'message' => 'تم جلب الخدمات بنجاح',
        'timestamp' => date('Y-m-d H:i:s'),
        'data' => [
            'services' => $services,
            'pagination' => [
                'current_page' => $page,
                'total_pages' => ceil($total / $limit),
                'total_items' => $total,
                'items_per_page' => $limit
            ]
        ]
    ];
    
    echo json_encode($response, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    
} catch (Exception $e) {
    $response = [
        'success' => false,
        'message' => 'خطأ: ' . $e->getMessage(),
        'timestamp' => date('Y-m-d H:i:s'),
        'data' => []
    ];
    
    echo json_encode($response, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
}
?> 