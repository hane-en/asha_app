<?php
/**
 * إضافة الحقول المفقودة إلى جدول المستخدمين
 */

require_once 'config.php';
require_once 'database.php';

try {
    $db = new Database();
    $db->connect();
    echo "✅ الاتصال بقاعدة البيانات نجح<br>";
    
    // إضافة الحقول المفقودة
    $alterQueries = [
        "ALTER TABLE users ADD COLUMN IF NOT EXISTS verification_code VARCHAR(10) NULL",
        "ALTER TABLE users ADD COLUMN IF NOT EXISTS reset_code VARCHAR(10) NULL",
        "ALTER TABLE users ADD COLUMN IF NOT EXISTS last_login_at TIMESTAMP NULL",
        "ALTER TABLE users ADD COLUMN IF NOT EXISTS website VARCHAR(255) NULL",
        "ALTER TABLE users ADD COLUMN IF NOT EXISTS latitude DECIMAL(10,8) NULL",
        "ALTER TABLE users ADD COLUMN IF NOT EXISTS longitude DECIMAL(11,8) NULL",
        "ALTER TABLE users ADD COLUMN IF NOT EXISTS user_category VARCHAR(100) NULL",
        "ALTER TABLE users ADD COLUMN IF NOT EXISTS is_yemeni_account BOOLEAN DEFAULT FALSE"
    ];
    
    foreach ($alterQueries as $query) {
        if ($db->execute($query)) {
            echo "✅ تم تنفيذ: " . substr($query, 0, 50) . "...<br>";
        } else {
            echo "❌ فشل في تنفيذ: " . substr($query, 0, 50) . "...<br>";
        }
    }
    
    echo "<h3>✅ تم تحديث جدول المستخدمين بنجاح!</h3>";
    
} catch (Exception $e) {
    echo "❌ خطأ: " . $e->getMessage() . "<br>";
}
?> 