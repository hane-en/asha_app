<?php
/**
 * ملف اختبار لـ API الفئات
 * GET /test_categories_api.php
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');

require_once 'config.php';
require_once 'database.php';

$result = [
    'success' => false,
    'message' => '',
    'data' => [],
    'debug' => []
];

try {
    $database = new Database();
    $database->connect();
    
    $result['debug']['database_connected'] = true;
    
    // اختبار وجود جدول الفئات
    $tables = $database->select("SHOW TABLES LIKE 'categories'");
    $result['debug']['categories_table_exists'] = count($tables) > 0;
    
    if (count($tables) == 0) {
        throw new Exception('جدول الفئات غير موجود');
    }
    
    // اختبار عدد الفئات
    $count = $database->selectOne("SELECT COUNT(*) as count FROM categories");
    $result['debug']['total_categories'] = $count['count'];
    
    // اختبار الفئات النشطة
    $active_categories = $database->select("SELECT COUNT(*) as count FROM categories WHERE is_active = 1");
    $result['debug']['active_categories'] = $active_categories[0]['count'];
    
    // جلب جميع الفئات النشطة
    $categories = $database->select("SELECT id, name, description, image, is_active, created_at FROM categories WHERE is_active = 1 ORDER BY name ASC");
    
    if ($categories === false) {
        throw new Exception('خطأ في جلب الفئات');
    }
    
    // تحويل البيانات
    $formattedCategories = [];
    foreach ($categories as $category) {
        $formattedCategories[] = [
            'id' => (int)$category['id'],
            'title' => $category['name'],
            'name' => $category['name'],
            'description' => $category['description'],
            'image' => $category['image'],
            'is_active' => (bool)$category['is_active'],
            'created_at' => $category['created_at']
        ];
    }
    
    $result['success'] = true;
    $result['message'] = 'تم اختبار API الفئات بنجاح';
    $result['data'] = $formattedCategories;
    $result['count'] = count($formattedCategories);
    
} catch (Exception $e) {
    $result['success'] = false;
    $result['message'] = 'خطأ في اختبار API الفئات: ' . $e->getMessage();
    $result['debug']['error'] = $e->getMessage();
}

echo json_encode($result, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
?> 