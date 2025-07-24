<?php
require_once '../../config/config.php';
require_once '../../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    jsonResponse(['error' => 'Method not allowed'], 405);
}

if (!isset($_GET['category'])) {
    jsonResponse(['error' => 'اسم الفئة مطلوب'], 400);
}

$category = validateInput($_GET['category']);

$pdo = getDBConnection();
if (!$pdo) {
    jsonResponse(['error' => 'خطأ في الاتصال بقاعدة البيانات'], 500);
}

try {
    // البحث عن الفئة
    $stmt = $pdo->prepare("SELECT id FROM categories WHERE name = ? AND is_active = 1");
    $stmt->execute([$category]);
    $categoryData = $stmt->fetch();
    
    if (!$categoryData) {
        jsonResponse(['error' => 'الفئة غير موجودة'], 404);
    }
    
    $categoryId = $categoryData['id'];
    
    // جلب الخدمات في هذه الفئة
    $stmt = $pdo->prepare("
        SELECT s.*, c.name as category_name, u.name as provider_name, u.phone as provider_phone
        FROM services s 
        JOIN categories c ON s.category_id = c.id 
        JOIN users u ON s.provider_id = u.id 
        WHERE s.category_id = ? AND s.is_active = 1
        ORDER BY s.created_at DESC
    ");
    $stmt->execute([$categoryId]);
    $services = $stmt->fetchAll();
    
    jsonResponse([
        'success' => true,
        'data' => $services,
        'category' => $category,
        'count' => count($services)
    ]);
    
} catch (PDOException $e) {
    error_log("Get services by category error: " . $e->getMessage());
    jsonResponse(['error' => 'خطأ في جلب الخدمات'], 500);
}
?> 