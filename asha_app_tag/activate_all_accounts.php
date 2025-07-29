<?php
/**
 * تفعيل جميع الحسابات الموجودة
 * تشغيل هذا الملف لحل مشكلة "يرجى تفعيل حسابك"
 */

require_once 'config.php';
require_once 'database.php';

try {
    $database = new Database();
    $database->connect();
    
    echo "<h2>تفعيل الحسابات</h2>";
    
    // تفعيل جميع الحسابات الموجودة
    $result = $database->update(
        'users',
        ['is_verified' => 1],
        'is_verified = 0'
    );
    
    if ($result) {
        echo "<p style='color: green;'>✅ تم تفعيل جميع الحسابات بنجاح!</p>";
    } else {
        echo "<p style='color: orange;'>⚠️ لا توجد حسابات تحتاج للتفعيل</p>";
    }
    
    // عرض الحسابات المفعلة
    $users = $database->select("SELECT id, name, email, user_type, is_verified FROM users WHERE is_verified = 1");
    
    echo "<h3>الحسابات المفعلة:</h3>";
    echo "<table border='1' style='border-collapse: collapse; width: 100%;'>";
    echo "<tr><th>ID</th><th>الاسم</th><th>البريد الإلكتروني</th><th>النوع</th><th>مفعل</th></tr>";
    
    foreach ($users as $user) {
        echo "<tr>";
        echo "<td>{$user['id']}</td>";
        echo "<td>{$user['name']}</td>";
        echo "<td>{$user['email']}</td>";
        echo "<td>{$user['user_type']}</td>";
        echo "<td>" . ($user['is_verified'] ? '✅' : '❌') . "</td>";
        echo "</tr>";
    }
    echo "</table>";
    
    // إضافة بيانات تجريبية إذا لم تكن موجودة
    $testUsers = [
        [
            'name' => 'مدير النظام',
            'email' => 'admin@asha.com',
            'phone' => '777777777',
            'password' => password_hash('password', PASSWORD_DEFAULT),
            'user_type' => 'admin',
            'is_verified' => 1,
            'is_active' => 1
        ],
        [
            'name' => 'أحمد المصور',
            'email' => 'ahmed@test.com',
            'phone' => '777777778',
            'password' => password_hash('password', PASSWORD_DEFAULT),
            'user_type' => 'provider',
            'is_verified' => 1,
            'is_active' => 1
        ],
        [
            'name' => 'فاطمة المزينة',
            'email' => 'fatima@test.com',
            'phone' => '777777779',
            'password' => password_hash('password', PASSWORD_DEFAULT),
            'user_type' => 'provider',
            'is_verified' => 1,
            'is_active' => 1
        ],
        [
            'name' => 'محمد أحمد',
            'email' => 'mohammed@test.com',
            'phone' => '777777780',
            'password' => password_hash('password', PASSWORD_DEFAULT),
            'user_type' => 'user',
            'is_verified' => 1,
            'is_active' => 1
        ]
    ];
    
    foreach ($testUsers as $userData) {
        $existingUser = $database->selectOne(
            "SELECT id FROM users WHERE email = :email",
            ['email' => $userData['email']]
        );
        
        if (!$existingUser) {
            $userId = $database->insert('users', $userData);
            if ($userId) {
                echo "<p style='color: blue;'>✅ تم إضافة المستخدم: {$userData['name']}</p>";
            }
        }
    }
    
    // إضافة فئات الخدمات
    $categories = [
        ['name' => 'التصوير', 'description' => 'خدمات التصوير الاحترافي للمناسبات'],
        ['name' => 'التجميل', 'description' => 'خدمات التجميل والمكياج للمناسبات'],
        ['name' => 'الضيافة', 'description' => 'خدمات الضيافة والطعام للمناسبات'],
        ['name' => 'الموسيقى', 'description' => 'خدمات الموسيقى والترفيه للمناسبات'],
        ['name' => 'الزهور', 'description' => 'خدمات تنسيق الزهور والديكور'],
        ['name' => 'الملابس', 'description' => 'خدمات تأجير وبيع الملابس للمناسبات']
    ];
    
    foreach ($categories as $categoryData) {
        $existingCategory = $database->selectOne(
            "SELECT id FROM categories WHERE name = :name",
            ['name' => $categoryData['name']]
        );
        
        if (!$existingCategory) {
            $categoryId = $database->insert('categories', $categoryData);
            if ($categoryId) {
                echo "<p style='color: blue;'>✅ تم إضافة الفئة: {$categoryData['name']}</p>";
            }
        }
    }
    
    echo "<h3>بيانات تسجيل الدخول:</h3>";
    echo "<ul>";
    echo "<li><strong>مدير النظام:</strong> admin@asha.com / password</li>";
    echo "<li><strong>مزود خدمة:</strong> ahmed@test.com / password</li>";
    echo "<li><strong>مزود خدمة:</strong> fatima@test.com / password</li>";
    echo "<li><strong>مستخدم عادي:</strong> mohammed@test.com / password</li>";
    echo "</ul>";
    
    echo "<p style='color: green; font-weight: bold;'>🎉 تم حل مشكلة تفعيل الحسابات بنجاح!</p>";
    
} catch (Exception $e) {
    echo "<p style='color: red;'>❌ خطأ: " . $e->getMessage() . "</p>";
}
?> 