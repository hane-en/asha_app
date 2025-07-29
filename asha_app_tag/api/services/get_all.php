<?php
/**
 * API endpoint لجلب جميع الخدمات
 * يدعم التصفية والترتيب والترقيم
 */

// إيقاف عرض الأخطاء لمنع ظهور warnings في JSON
error_reporting(0);
ini_set('display_errors', 0);

require_once '../../config.php';
require_once '../../database.php';
require_once '../../middleware.php';

// التحقق من طريقة الطلب
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    errorResponse('طريقة الطلب غير مدعومة', 405);
}

// الحصول على المعاملات
$page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
$limit = isset($_GET['limit']) ? (int)$_GET['limit'] : PAGINATION_LIMIT;
$category_id = isset($_GET['category_id']) ? (int)$_GET['category_id'] : null;
$city = isset($_GET['city']) ? sanitizeInput($_GET['city']) : null;
$search = isset($_GET['search']) ? sanitizeInput($_GET['search']) : null;
$min_price = isset($_GET['min_price']) ? (float)$_GET['min_price'] : null;
$max_price = isset($_GET['max_price']) ? (float)$_GET['max_price'] : null;
$is_featured = isset($_GET['is_featured']) ? (bool)$_GET['is_featured'] : null;
$sort_by = isset($_GET['sort_by']) ? sanitizeInput($_GET['sort_by']) : 'created_at';
$sort_order = isset($_GET['sort_order']) ? sanitizeInput($_GET['sort_order']) : 'DESC';

try {
    $database = new Database();
    $database->connect();

    // فحص حالة جدول services
    $checkQuery = "SELECT COUNT(*) as total FROM services";
    $totalServices = $database->selectOne($checkQuery);
    error_log("Total services in database: " . $totalServices['total']);
    
    $activeServices = $database->selectOne("SELECT COUNT(*) as total FROM services WHERE is_active = 1");
    error_log("Active services in database: " . $activeServices['total']);

    // بناء الاستعلام
    $whereConditions = []; // إزالة جميع الشروط مؤقتاً
    $params = [];

    if ($category_id) {
        $whereConditions[] = 's.category_id = :category_id';
        $params['category_id'] = $category_id;
    }

    if ($city) {
        $whereConditions[] = 's.city = :city';
        $params['city'] = $city;
    }

    if ($search) {
        $whereConditions[] = '(s.title LIKE :search OR s.description LIKE :search OR s.tags LIKE :search)';
        $params['search'] = "%{$search}%";
    }

    if ($min_price !== null) {
        $whereConditions[] = 's.price >= :min_price';
        $params['min_price'] = $min_price;
    }

    if ($max_price !== null) {
        $whereConditions[] = 's.price <= :max_price';
        $params['max_price'] = $max_price;
    }

    if ($is_featured !== null) {
        $whereConditions[] = 's.is_featured = :is_featured';
        $params['is_featured'] = $is_featured ? 1 : 0;
    }

    $whereClause = implode(' AND ', $whereConditions);

    // إضافة debugging
    error_log("Services query WHERE clause: " . $whereClause);
    error_log("Services query params: " . json_encode($params));

    // الاستعلام الرئيسي - مبسط للاختبار
    $query = "
        SELECT 
            s.*,
            COALESCE(c.name, 'غير محدد') as category_name,
            COALESCE(u.name, 'غير محدد') as provider_name
        FROM services s
        LEFT JOIN categories c ON s.category_id = c.id
        LEFT JOIN users u ON s.provider_id = u.id
    ";
    
    // إضافة WHERE clause إذا كانت موجودة
    if (!empty($whereConditions)) {
        $query .= " WHERE " . $whereClause;
    }
    
    $query .= " ORDER BY s.created_at DESC LIMIT ? OFFSET ?";

    $offset = ($page - 1) * $limit;

    // إضافة debugging للـ parameters
    error_log("Page: " . $page);
    error_log("Limit: " . $limit);
    error_log("Offset: " . $offset);
    error_log("Where conditions: " . json_encode($whereConditions));
    error_log("Where clause: " . $whereClause);

    // إضافة debugging للاستعلام
    error_log("Full query: " . $query);

    // استخدام الاستعلام مباشرة بدون parameters للـ LIMIT و OFFSET
    $finalQuery = str_replace(['LIMIT ? OFFSET ?'], ["LIMIT $limit OFFSET $offset"], $query);
    error_log("Final query: " . $finalQuery);

    // إضافة شروط WHERE للخدمات النشطة فقط
    if (empty($whereConditions)) {
        $finalQuery = str_replace('FROM services s', 'FROM services s WHERE s.is_active = 1', $finalQuery);
    } else {
        $finalQuery = str_replace('FROM services s', 'FROM services s WHERE s.is_active = 1', $finalQuery);
    }

    // استخدام الاستعلام بدون parameters إذا لم تكن هناك شروط WHERE
    if (empty($whereConditions)) {
        $services = $database->select($finalQuery);
    } else {
        // استخدام الاستعلام مع parameters إذا كانت هناك شروط WHERE
        $services = $database->select($finalQuery, $params);
    }
    
    // إضافة debugging
    error_log("Services result type: " . gettype($services));
    error_log("Services count: " . (is_array($services) ? count($services) : 'not array'));
    
    // التأكد من أن النتيجة صحيحة
    if ($services === false || !is_array($services)) {
        error_log("Database select returned false or invalid result - trying simple query");
        // محاولة استعلام بسيط
        $simpleQuery = "SELECT * FROM services WHERE is_active = 1 LIMIT 10";
        $services = $database->select($simpleQuery);
        
        if ($services === false || !is_array($services)) {
            error_log("Simple query also failed");
            $services = [];
        } else {
            error_log("Simple query succeeded with " . count($services) . " results");
        }
    } elseif (is_array($services) && count($services) > 0) {
        error_log("First service: " . json_encode($services[0]));
    } else {
        error_log("No services returned from query");
    }

    // الحصول على العدد الإجمالي
    $countQuery = "
        SELECT COUNT(*) as total
        FROM services s
    ";
    
    // إضافة شروط WHERE إذا كانت موجودة
    if (!empty($whereConditions)) {
        $countQuery .= " WHERE " . implode(' AND ', $whereConditions);
    }
    
    $totalResult = $database->selectOne($countQuery);
    
    // فحص النتيجة
    if ($totalResult && isset($totalResult['total'])) {
        $total = $totalResult['total'];
    } else {
        $total = 0;
        error_log("Count query failed or returned invalid result: " . json_encode($totalResult));
    }

    // معالجة البيانات - مبسطة
    if (is_array($services)) {
        foreach ($services as &$service) {
            // تحويل الأرقام الأساسية فقط
            $service['id'] = (int)($service['id'] ?? 0);
            $service['price'] = (float)($service['price'] ?? 0);
            $service['category_id'] = (int)($service['category_id'] ?? 0);
            $service['provider_id'] = (int)($service['provider_id'] ?? 0);
            
            // تحويل القيم المنطقية
            $service['is_active'] = (bool)($service['is_active'] ?? false);
            $service['is_verified'] = (bool)($service['is_verified'] ?? false);
            
            // تحويل JSON strings إلى arrays
            $service['images'] = json_decode($service['images'] ?? '[]', true) ?: [];
            $service['specifications'] = json_decode($service['specifications'] ?? '[]', true) ?: [];
            $service['tags'] = json_decode($service['tags'] ?? '[]', true) ?: [];
            $service['payment_terms'] = json_decode($service['payment_terms'] ?? '[]', true) ?: [];
            $service['availability'] = json_decode($service['availability'] ?? '[]', true) ?: [];
            
            // التأكد من وجود النصوص الأساسية
            $service['title'] = $service['title'] ?? '';
            $service['description'] = $service['description'] ?? '';
            $service['category_name'] = $service['category_name'] ?? '';
            $service['provider_name'] = $service['provider_name'] ?? '';
        }
    } else {
        $services = [];
    }

    $response = [
        'success' => true,
        'message' => 'تم جلب الخدمات بنجاح',
        'timestamp' => date('Y-m-d H:i:s'),
        'data' => [
            'services' => $services,
            'pagination' => [
                'current_page' => $page,
                'total_pages' => ceil($total / $limit),
                'total_items' => (int)$total,
                'items_per_page' => $limit
            ]
        ]
    ];

    // إرسال الاستجابة
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($response, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    exit; // إيقاف التنفيذ بعد إرسال JSON

} catch (Exception $e) {
    logError("Get services error: " . $e->getMessage());
    errorResponse('حدث خطأ أثناء جلب الخدمات', 500);
}

?>

