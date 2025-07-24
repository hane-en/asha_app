<?php
require_once '../../config/config.php';
require_once '../../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse(['error' => 'Method not allowed'], 405);
}

$input = json_decode(file_get_contents('php://input'), true);

if (!isset($input['name'])) {
    jsonResponse(['error' => 'اسم الفئة مطلوب'], 400);
}

$name = validateInput($input['name']);
$description = isset($input['description']) ? validateInput($input['description']) : '';
$image = isset($input['image']) ? validateInput($input['image']) : null;

$pdo = getDBConnection();
if (!$pdo) {
    jsonResponse(['error' => 'خطأ في الاتصال بقاعدة البيانات'], 500);
}

try {
    // تحقق من عدم وجود الفئة مسبقاً
    $stmt = $pdo->prepare("SELECT id FROM categories WHERE name = ?");
    $stmt->execute([$name]);
    if ($stmt->fetch()) {
        jsonResponse(['success' => false, 'message' => 'اسم الفئة موجود بالفعل ولا يمكن تكراره.'], 400);
    }

    // إضافة الفئة
    $stmt = $pdo->prepare("INSERT INTO categories (name, description, image) VALUES (?, ?, ?)");
    $stmt->execute([$name, $description, $image]);
    $categoryId = $pdo->lastInsertId();

    jsonResponse([
        'success' => true,
        'message' => 'تمت إضافة الفئة بنجاح',
        'category_id' => $categoryId
    ]);
} catch (PDOException $e) {
    error_log("Add category error: " . $e->getMessage());
    jsonResponse(['error' => 'خطأ في إضافة الفئة'], 500);
}
?> 