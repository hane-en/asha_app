<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

require_once '../config/database.php';

try {
    // التحقق من وجود عمود profile_image
    $checkColumnQuery = "SHOW COLUMNS FROM users LIKE 'profile_image'";
    $stmt = $pdo->prepare($checkColumnQuery);
    $stmt->execute();
    $columnExists = $stmt->rowCount() > 0;
    
    if (!$columnExists) {
        // إضافة عمود profile_image
        $addColumnQuery = "ALTER TABLE users ADD COLUMN profile_image VARCHAR(255) DEFAULT NULL AFTER website";
        $pdo->exec($addColumnQuery);
        
        // إضافة عمود cover_image أيضاً
        $addCoverColumnQuery = "ALTER TABLE users ADD COLUMN cover_image VARCHAR(255) DEFAULT NULL AFTER profile_image";
        $pdo->exec($addCoverColumnQuery);
        
        // تحديث البيانات الموجودة
        $updateQuery = "UPDATE users SET profile_image = 'default_avatar.jpg' WHERE profile_image IS NULL";
        $pdo->exec($updateQuery);
        
        echo json_encode([
            'success' => true,
            'message' => 'تم إضافة أعمدة الصور بنجاح',
            'added_columns' => ['profile_image', 'cover_image']
        ]);
    } else {
        echo json_encode([
            'success' => true,
            'message' => 'أعمدة الصور موجودة بالفعل',
            'columns_exist' => true
        ]);
    }
    
} catch (PDOException $e) {
    echo json_encode([
        'success' => false,
        'message' => 'خطأ في إصلاح قاعدة البيانات: ' . $e->getMessage(),
        'error_code' => $e->getCode()
    ]);
}
?> 