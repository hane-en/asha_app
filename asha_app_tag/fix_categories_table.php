<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// التعامل مع طلبات OPTIONS
if (isset($_SERVER['REQUEST_METHOD']) && $_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once 'api/config/database.php';

try {
    $db = new Database();
    $pdo = $db->getConnection();
    
    if (!$pdo) {
        throw new Exception('فشل في الاتصال بقاعدة البيانات');
    }
    
    $results = [];
    
    // إضافة عمود icon إذا لم يكن موجوداً
    try {
        $stmt = $pdo->prepare("ALTER TABLE categories ADD COLUMN icon VARCHAR(50) DEFAULT 'category' AFTER description");
        $stmt->execute();
        $results['icon_column'] = 'تم إضافة عمود icon بنجاح';
    } catch (PDOException $e) {
        if (strpos($e->getMessage(), 'Duplicate column name') !== false) {
            $results['icon_column'] = 'عمود icon موجود بالفعل';
        } else {
            $results['icon_column'] = 'خطأ في إضافة عمود icon: ' . $e->getMessage();
        }
    }
    
    // إضافة عمود color إذا لم يكن موجوداً
    try {
        $stmt = $pdo->prepare("ALTER TABLE categories ADD COLUMN color VARCHAR(10) DEFAULT '#8e24aa' AFTER icon");
        $stmt->execute();
        $results['color_column'] = 'تم إضافة عمود color بنجاح';
    } catch (PDOException $e) {
        if (strpos($e->getMessage(), 'Duplicate column name') !== false) {
            $results['color_column'] = 'عمود color موجود بالفعل';
        } else {
            $results['color_column'] = 'خطأ في إضافة عمود color: ' . $e->getMessage();
        }
    }
    
    // تحديث البيانات الموجودة بالقيم الافتراضية
    try {
        $stmt = $pdo->prepare("UPDATE categories SET icon = 'category', color = '#8e24aa' WHERE icon IS NULL OR color IS NULL");
        $stmt->execute();
        $results['update_data'] = 'تم تحديث البيانات الموجودة بنجاح';
    } catch (PDOException $e) {
        $results['update_data'] = 'خطأ في تحديث البيانات: ' . $e->getMessage();
    }
    
    // عرض هيكل الجدول الحالي
    try {
        $stmt = $pdo->query("DESCRIBE categories");
        $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
        $results['table_structure'] = $columns;
    } catch (PDOException $e) {
        $results['table_structure'] = 'خطأ في جلب هيكل الجدول: ' . $e->getMessage();
    }
    
    echo json_encode([
        'success' => true,
        'message' => 'تم إصلاح جدول الفئات بنجاح',
        'data' => $results
    ], JSON_UNESCAPED_UNICODE);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'خطأ في إصلاح جدول الفئات: ' . $e->getMessage(),
        'data' => []
    ], JSON_UNESCAPED_UNICODE);
}
?> 