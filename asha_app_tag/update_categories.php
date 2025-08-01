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
    
    // حذف الفئات القديمة
    $stmt = $pdo->prepare("DELETE FROM categories WHERE id > 0");
    $stmt->execute();
    $results['categories_deleted'] = $stmt->rowCount();
    
    // إعادة تعيين auto increment
    $stmt = $pdo->prepare("ALTER TABLE categories AUTO_INCREMENT = 1");
    $stmt->execute();
    
    // إضافة الفئات الجديدة
    $categories = [
        ['قاعات الأفراح', 'قاعات احتفالات وأفراح', 'celebration', '#8e24aa'],
        ['التصوير', 'خدمات التصوير الاحترافي للمناسبات', 'camera_alt', '#ff9800'],
        ['الديكور', 'خدمات تزيين المناسبات', 'local_florist', '#4caf50'],
        ['الجاتوهات', 'جاتوهات وحلويات للمناسبات', 'cake', '#e91e63'],
        ['الموسيقى', 'خدمات الموسيقى والعزف', 'music_note', '#2196f3'],
        ['الفساتين', 'فساتين وأزياء المناسبات', 'checkroom', '#9c27b0']
    ];
    
    $stmt = $pdo->prepare("INSERT INTO categories (name, description, icon, color, is_active, created_at) VALUES (?, ?, ?, ?, 1, NOW())");
    
    foreach ($categories as $category) {
        $stmt->execute($category);
    }
    
    $results['categories_added'] = count($categories);
    
    // حذف الخدمات القديمة
    $stmt = $pdo->prepare("DELETE FROM services WHERE id > 0");
    $stmt->execute();
    $results['services_deleted'] = $stmt->rowCount();
    
    // إعادة تعيين auto increment للخدمات
    $stmt = $pdo->prepare("ALTER TABLE services AUTO_INCREMENT = 1");
    $stmt->execute();
    
    // إضافة خدمات تجريبية
    $services = [
        // خدمات فاطمة علي (قاعات الأفراح)
        [2, 1, 'قاعة أفراح فاخرة', 'قاعة أفراح فاخرة تتسع لـ 200 شخص', 2000.00, 4.8],
        [2, 1, 'قاعة احتفالات صغيرة', 'قاعة احتفالات صغيرة للمناسبات العائلية', 1000.00, 4.7],
        
        // خدمات أحمد محمد (التصوير)
        [1, 2, 'تصوير احترافي للمناسبات', 'تصوير احترافي عالي الجودة لجميع المناسبات', 500.00, 4.5],
        [1, 2, 'تصوير فيديو للمناسبات', 'تصوير فيديو احترافي مع مونتاج', 800.00, 4.6],
        
        // خدمات سارة أحمد (الديكور)
        [4, 3, 'تزيين قاعات الأفراح', 'تزيين احترافي لقاعات الأفراح', 300.00, 4.0],
        [4, 3, 'تزيين مناسبات عائلية', 'تزيين بسيط للمناسبات العائلية', 150.00, 4.2],
        
        // خدمات علي محمود (الجاتوهات)
        [5, 4, 'جاتوهات عيد الميلاد', 'جاتوهات احترافية لعيد الميلاد', 200.00, 4.7],
        [5, 4, 'جاتوهات الأفراح', 'جاتوهات فاخرة لحفلات الأفراح', 300.00, 4.6],
        
        // خدمات محمد حسن (الموسيقى)
        [3, 5, 'عزف موسيقي للمناسبات', 'عزف موسيقي احترافي لجميع المناسبات', 600.00, 4.2],
        [3, 5, 'دجاجي وطرب', 'دجاجي وطرب تقليدي للمناسبات', 400.00, 4.1],
        
        // خدمات نورا سعيد (الفساتين)
        [6, 6, 'تأجير فساتين العروس', 'تأجير فساتين عروس فاخرة', 500.00, 4.9],
        [6, 6, 'تأجير بدلات الرجال', 'تأجير بدلات رسمية للرجال', 200.00, 4.8],
        
        // خدمات خالد عبدالله (التصوير)
        [7, 2, 'تصوير بسيط للمناسبات', 'تصوير بسيط للمناسبات العائلية', 200.00, 3.8],
        
        // خدمات ليلى محمد (الموسيقى)
        [8, 5, 'عزف البيانو', 'عزف البيانو للمناسبات الرومانسية', 700.00, 4.6],
        [8, 5, 'غناء عربي', 'غناء عربي تقليدي للمناسبات', 500.00, 4.5],
        
        // خدمات عمر يوسف (الديكور)
        [9, 3, 'تزيين حدائق', 'تزيين احترافي للحدائق والمناطق الخارجية', 400.00, 4.3],
        
        // خدمات رنا أحمد (الجاتوهات)
        [10, 4, 'جاتوهات غربية', 'جاتوهات غربية متنوعة', 250.00, 4.4],
        [10, 4, 'جاتوهات عربية', 'جاتوهات عربية تقليدية', 180.00, 4.3]
    ];
    
    $stmt = $pdo->prepare("INSERT INTO services (provider_id, category_id, title, description, price, rating, is_active, created_at) VALUES (?, ?, ?, ?, ?, ?, 1, NOW())");
    
    foreach ($services as $service) {
        $stmt->execute($service);
    }
    
    $results['services_added'] = count($services);
    
    // جلب الإحصائيات النهائية
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM categories WHERE is_active = 1");
    $totalCategories = $stmt->fetch(PDO::FETCH_ASSOC)['count'];
    
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM services WHERE is_active = 1");
    $totalServices = $stmt->fetch(PDO::FETCH_ASSOC)['count'];
    
    echo json_encode([
        'success' => true,
        'message' => 'تم تحديث الفئات والخدمات بنجاح',
        'data' => [
            'results' => $results,
            'statistics' => [
                'total_categories' => (int)$totalCategories,
                'total_services' => (int)$totalServices
            ]
        ]
    ], JSON_UNESCAPED_UNICODE);
    
} catch (Exception $e) {
    // التراجع عن المعاملة في حالة الخطأ
    if (isset($pdo) && $pdo->inTransaction()) {
        $pdo->rollBack();
    }
    
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'خطأ في تحديث البيانات: ' . $e->getMessage(),
        'data' => []
    ], JSON_UNESCAPED_UNICODE);
}
?> 