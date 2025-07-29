<?php
/**
 * API endpoint لجلب جميع الفئات النشطة
 * GET /api/services/get_categories.php
 */

require_once '../../config.php';
require_once '../../database.php';

// إعداد CORS
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');

// معالجة preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// التحقق من طريقة الطلب
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    errorResponse('طريقة الطلب غير مدعومة', 405);
}

try {
    $database = new Database();
    $database->connect();
    
    // جلب جميع الفئات النشطة
    $query = "SELECT id, name, description, image, is_active, created_at 
              FROM categories 
              WHERE is_active = 1 
              ORDER BY name ASC";
    
    $categories = $database->select($query);
    
    if ($categories === false) {
        throw new Exception('خطأ في جلب الفئات من قاعدة البيانات');
    }
    
    // معالجة البيانات
    foreach ($categories as &$category) {
        // تحويل الأرقام
        $category['id'] = (int)$category['id'];
        
        // تحويل القيم المنطقية
        $category['is_active'] = (bool)$category['is_active'];
        
        // تحويل التواريخ
        if ($category['created_at']) {
            $category['created_at'] = date('Y-m-d H:i:s', strtotime($category['created_at']));
        }
    }
    
    successResponse($categories, 'تم جلب الفئات بنجاح');
    
} catch (Exception $e) {
    logError("Get categories error: " . $e->getMessage());
    errorResponse('حدث خطأ أثناء جلب الفئات', 500);
}
?> 