<?php
require_once 'config.php';
require_once 'database.php';

echo "<h1>إضافة الجداول الجديدة لقاعدة البيانات</h1>\n";

try {
    $pdo = new PDO("mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=utf8mb4", DB_USER, DB_PASS);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    echo "<h2>1. إنشاء جدول طلبات الانضمام (provider_requests)</h2>\n";
    
    $sql = "CREATE TABLE IF NOT EXISTS provider_requests (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        business_name VARCHAR(255) NOT NULL,
        business_description TEXT,
        business_phone VARCHAR(20),
        business_address TEXT,
        business_license VARCHAR(500),
        service_category VARCHAR(100),
        status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
        admin_notes TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    )";
    
    $pdo->exec($sql);
    echo "✅ تم إنشاء جدول provider_requests بنجاح\n";
    
    echo "<h2>2. إنشاء جدول طلبات تحديث الملف الشخصي (profile_update_requests)</h2>\n";
    
    $sql = "CREATE TABLE IF NOT EXISTS profile_update_requests (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        name VARCHAR(255) NOT NULL,
        email VARCHAR(255) NOT NULL,
        phone VARCHAR(20) NOT NULL,
        bio TEXT,
        website VARCHAR(255),
        address TEXT,
        city VARCHAR(100),
        latitude DECIMAL(10,8),
        longitude DECIMAL(11,8),
        status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
        admin_notes TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    )";
    
    $pdo->exec($sql);
    echo "✅ تم إنشاء جدول profile_update_requests بنجاح\n";
    
    echo "<h2>3. إنشاء جدول الرسائل (messages)</h2>\n";
    
    $sql = "CREATE TABLE IF NOT EXISTS messages (
        id INT AUTO_INCREMENT PRIMARY KEY,
        sender_id INT NOT NULL,
        receiver_id INT NOT NULL,
        message TEXT NOT NULL,
        is_read BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (receiver_id) REFERENCES users(id) ON DELETE CASCADE
    )";
    
    $pdo->exec($sql);
    echo "✅ تم إنشاء جدول messages بنجاح\n";
    
    echo "<h2>4. إنشاء جدول تقارير الإحصائيات (provider_stats_reports)</h2>\n";
    
    $sql = "CREATE TABLE IF NOT EXISTS provider_stats_reports (
        id INT AUTO_INCREMENT PRIMARY KEY,
        provider_id INT NOT NULL,
        report_date DATE NOT NULL,
        services_count INT DEFAULT 0,
        bookings_count INT DEFAULT 0,
        ads_count INT DEFAULT 0,
        avg_rating DECIMAL(3,2) DEFAULT 0.00,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (provider_id) REFERENCES users(id) ON DELETE CASCADE,
        UNIQUE KEY unique_report (provider_id, report_date)
    )";
    
    $pdo->exec($sql);
    echo "✅ تم إنشاء جدول provider_stats_reports بنجاح\n";
    
    echo "<h2>5. إدراج بيانات افتراضية لجدول طلبات الانضمام</h2>\n";
    
    $sql = "INSERT INTO provider_requests (user_id, business_name, business_description, business_phone, business_address, business_license, service_category, status, admin_notes) VALUES
    (1, 'شركة النظافة المتقدمة', 'شركة متخصصة في خدمات التنظيف الشامل للمنازل والمكاتب', '+966501234567', 'شارع الملك فهد، الرياض', 'LIC-2024-001', 'تنظيف', 'approved', 'تم الموافقة على الطلب - شركة معروفة'),
    (2, 'مؤسسة الكهرباء الحديثة', 'مؤسسة متخصصة في أعمال الكهرباء والصيانة', '+966502345678', 'شارع التحلية، جدة', 'LIC-2024-002', 'كهرباء', 'pending', 'في انتظار مراجعة الوثائق'),
    (3, 'شركة السباكة المثالية', 'شركة متخصصة في أعمال السباكة وإصلاح التسريبات', '+966503456789', 'شارع العليا، الرياض', 'LIC-2024-003', 'سباكة', 'rejected', 'تم رفض الطلب - وثائق غير مكتملة'),
    (4, 'استوديو التصميم الإبداعي', 'استوديو متخصص في التصميم الداخلي والديكور', '+966504567890', 'شارع التحلية، جدة', 'LIC-2024-004', 'تصميم', 'approved', 'تم الموافقة - أعمال ممتازة'),
    (5, 'ورشة الحدادة التقليدية', 'ورشة متخصصة في أعمال الحدادة والحديد المشغول', '+966505678901', 'شارع الملك عبدالله، الدمام', 'LIC-2024-005', 'حدادة', 'pending', 'في انتظار مراجعة العينات'),
    (6, 'شركة الأمن والحماية', 'شركة متخصصة في خدمات الأمن والحماية', '+966506789012', 'شارع الملك فهد، الرياض', 'LIC-2024-006', 'أمن', 'approved', 'تم الموافقة - شركة معتمدة'),
    (7, 'مؤسسة النجارة الفنية', 'مؤسسة متخصصة في أعمال النجارة والأثاث', '+966507890123', 'شارع التحلية، جدة', 'LIC-2024-007', 'نجارة', 'pending', 'في انتظار مراجعة الأعمال السابقة'),
    (8, 'شركة التكييف المركزية', 'شركة متخصصة في تركيب وصيانة أجهزة التكييف', '+966508901234', 'شارع العليا، الرياض', 'LIC-2024-008', 'تكييف', 'approved', 'تم الموافقة - خبرة ممتازة'),
    (9, 'شركة البناء المتقن', 'شركة متخصصة في أعمال البناء والتشييد', '+966509012345', 'شارع الملك عبدالله، الدمام', 'LIC-2024-009', 'بناء', 'rejected', 'تم رفض الطلب - عدم توفر التراخيص المطلوبة'),
    (10, 'استوديو التصوير الاحترافي', 'استوديو متخصص في التصوير الاحترافي للمناسبات', '+966500123456', 'شارع التحلية، جدة', 'LIC-2024-010', 'تصوير', 'pending', 'في انتظار مراجعة الأعمال السابقة')";
    
    $pdo->exec($sql);
    echo "✅ تم إدراج 10 طلبات انضمام افتراضية\n";
    
    echo "<h2>6. إدراج بيانات افتراضية لجدول طلبات تحديث الملف الشخصي</h2>\n";
    
    $sql = "INSERT INTO profile_update_requests (user_id, name, email, phone, bio, website, address, city, latitude, longitude, status, admin_notes) VALUES
    (1, 'أحمد محمد علي', 'ahmed.mohamed@example.com', '+966501234567', 'مزود خدمات تنظيف محترف مع خبرة 10 سنوات', 'www.cleaningpro.com', 'شارع الملك فهد، الرياض', 'الرياض', 24.7136, 46.6753, 'approved', 'تم الموافقة على التحديث'),
    (2, 'فاطمة أحمد حسن', 'fatima.ahmed@example.com', '+966502345678', 'مصممة ديكورات محترفة مع شهادة من جامعة الملك سعود', 'www.designstudio.com', 'شارع التحلية، جدة', 'جدة', 21.4858, 39.1925, 'pending', 'في انتظار مراجعة الوثائق'),
    (3, 'علي حسن محمد', 'ali.hassan@example.com', '+966503456789', 'كهربائي محترف مع خبرة 15 سنة في المجال', 'www.electricpro.com', 'شارع العليا، الرياض', 'الرياض', 24.7136, 46.6753, 'rejected', 'تم رفض الطلب - معلومات غير صحيحة'),
    (4, 'سارة محمد أحمد', 'sara.mohamed@example.com', '+966504567890', 'مصممة جرافيك محترفة مع خبرة في التصميم الرقمي', 'www.graphicdesign.com', 'شارع التحلية، جدة', 'جدة', 21.4858, 39.1925, 'approved', 'تم الموافقة على التحديث'),
    (5, 'محمد علي حسن', 'mohamed.ali@example.com', '+966505678901', 'سباك محترف مع خبرة في إصلاح جميع أنواع المشاكل', 'www.plumbingpro.com', 'شارع الملك عبدالله، الدمام', 'الدمام', 26.4207, 50.0888, 'pending', 'في انتظار مراجعة الوثائق'),
    (6, 'نورا أحمد محمد', 'nora.ahmed@example.com', '+966506789012', 'مصممة أزياء محترفة مع خبرة في التصميم التقليدي', 'www.fashiondesign.com', 'شارع الملك فهد، الرياض', 'الرياض', 24.7136, 46.6753, 'approved', 'تم الموافقة على التحديث'),
    (7, 'حسن محمد علي', 'hassan.mohamed@example.com', '+966507890123', 'نجار محترف مع خبرة في صناعة الأثاث التقليدي', 'www.carpentrypro.com', 'شارع التحلية، جدة', 'جدة', 21.4858, 39.1925, 'pending', 'في انتظار مراجعة الأعمال السابقة'),
    (8, 'ليلى أحمد حسن', 'layla.ahmed@example.com', '+966508901234', 'مصممة ديكورات محترفة مع خبرة في التصميم العصري', 'www.moderninterior.com', 'شارع العليا، الرياض', 'الرياض', 24.7136, 46.6753, 'approved', 'تم الموافقة على التحديث'),
    (9, 'عمر محمد أحمد', 'omar.mohamed@example.com', '+966509012345', 'حداد محترف مع خبرة في الحدادة التقليدية', 'www.blacksmithpro.com', 'شارع الملك عبدالله، الدمام', 'الدمام', 26.4207, 50.0888, 'rejected', 'تم رفض الطلب - معلومات غير صحيحة'),
    (10, 'رنا علي محمد', 'rana.ali@example.com', '+966500123456', 'مصممة جرافيك محترفة مع خبرة في التصميم الإبداعي', 'www.creativegraphic.com', 'شارع التحلية، جدة', 'جدة', 21.4858, 39.1925, 'pending', 'في انتظار مراجعة الأعمال السابقة')";
    
    $pdo->exec($sql);
    echo "✅ تم إدراج 10 طلبات تحديث ملف شخصي افتراضية\n";
    
    echo "<h2>7. إدراج بيانات افتراضية لجدول الرسائل</h2>\n";
    
    $sql = "INSERT INTO messages (sender_id, receiver_id, message, is_read, created_at) VALUES
    (1, 2, 'مرحباً، أريد استفسار عن خدمات التنظيف لديكم', FALSE, '2024-01-15 10:30:00'),
    (2, 1, 'أهلاً وسهلاً، نقدم خدمات تنظيف شاملة للمنازل والمكاتب', TRUE, '2024-01-15 11:00:00'),
    (1, 2, 'ما هي الأسعار؟', FALSE, '2024-01-15 11:15:00'),
    (2, 1, 'تبدأ الأسعار من 200 ريال للتنظيف الشامل', TRUE, '2024-01-15 11:30:00'),
    (3, 4, 'مرحباً، أريد استفسار عن خدمات التصميم', FALSE, '2024-01-16 09:00:00'),
    (4, 3, 'أهلاً وسهلاً، نقدم خدمات التصميم الداخلي والديكور', TRUE, '2024-01-16 09:30:00'),
    (3, 4, 'هل يمكنكم عمل تصميم لمكتب صغير؟', FALSE, '2024-01-16 10:00:00'),
    (4, 3, 'نعم، نقدم خدمات تصميم المكاتب بأسعار مناسبة', TRUE, '2024-01-16 10:30:00'),
    (5, 6, 'مرحباً، أريد استفسار عن خدمات الكهرباء', FALSE, '2024-01-17 14:00:00'),
    (6, 5, 'أهلاً وسهلاً، نقدم خدمات الكهرباء والصيانة', TRUE, '2024-01-17 14:30:00'),
    (5, 6, 'هل تصلحون الأعطال في نفس اليوم؟', FALSE, '2024-01-17 15:00:00'),
    (6, 5, 'نعم، نصلح معظم الأعطال في نفس اليوم', TRUE, '2024-01-17 15:30:00'),
    (7, 8, 'مرحباً، أريد استفسار عن خدمات السباكة', FALSE, '2024-01-18 16:00:00'),
    (8, 7, 'أهلاً وسهلاً، نقدم خدمات السباكة وإصلاح التسريبات', TRUE, '2024-01-18 16:30:00'),
    (7, 8, 'هل تصلحون تسريبات المياه؟', FALSE, '2024-01-18 17:00:00'),
    (8, 7, 'نعم، نصلح جميع أنواع تسريبات المياه', TRUE, '2024-01-18 17:30:00'),
    (9, 10, 'مرحباً، أريد استفسار عن خدمات الحدادة', FALSE, '2024-01-19 08:00:00'),
    (10, 9, 'أهلاً وسهلاً، نقدم خدمات الحدادة والحديد المشغول', TRUE, '2024-01-19 08:30:00'),
    (9, 10, 'هل تصنعون أبواب حديد؟', FALSE, '2024-01-19 09:00:00'),
    (10, 9, 'نعم، نصنع جميع أنواع الأبواب الحديدية', TRUE, '2024-01-19 09:30:00')";
    
    $pdo->exec($sql);
    echo "✅ تم إدراج 20 رسالة افتراضية\n";
    
    echo "<h2>8. إدراج بيانات افتراضية لجدول تقارير الإحصائيات</h2>\n";
    
    $sql = "INSERT INTO provider_stats_reports (provider_id, report_date, services_count, bookings_count, ads_count, avg_rating, created_at) VALUES
    (1, '2024-01-01', 5, 12, 3, 4.5, '2024-01-01 00:00:00'),
    (1, '2024-01-02', 5, 8, 3, 4.6, '2024-01-02 00:00:00'),
    (1, '2024-01-03', 5, 15, 3, 4.4, '2024-01-03 00:00:00'),
    (2, '2024-01-01', 3, 6, 2, 4.8, '2024-01-01 00:00:00'),
    (2, '2024-01-02', 3, 9, 2, 4.7, '2024-01-02 00:00:00'),
    (2, '2024-01-03', 3, 11, 2, 4.9, '2024-01-03 00:00:00'),
    (3, '2024-01-01', 4, 7, 1, 4.3, '2024-01-01 00:00:00'),
    (3, '2024-01-02', 4, 10, 1, 4.5, '2024-01-02 00:00:00'),
    (3, '2024-01-03', 4, 13, 1, 4.4, '2024-01-03 00:00:00'),
    (4, '2024-01-01', 2, 4, 1, 4.9, '2024-01-01 00:00:00'),
    (4, '2024-01-02', 2, 6, 1, 4.8, '2024-01-02 00:00:00'),
    (4, '2024-01-03', 2, 8, 1, 4.7, '2024-01-03 00:00:00'),
    (5, '2024-01-01', 3, 5, 2, 4.2, '2024-01-01 00:00:00'),
    (5, '2024-01-02', 3, 7, 2, 4.3, '2024-01-02 00:00:00'),
    (5, '2024-01-03', 3, 9, 2, 4.4, '2024-01-03 00:00:00'),
    (6, '2024-01-01', 2, 3, 1, 4.6, '2024-01-01 00:00:00'),
    (6, '2024-01-02', 2, 5, 1, 4.7, '2024-01-02 00:00:00'),
    (6, '2024-01-03', 2, 7, 1, 4.5, '2024-01-03 00:00:00'),
    (7, '2024-01-01', 4, 6, 2, 4.1, '2024-01-01 00:00:00'),
    (7, '2024-01-02', 4, 8, 2, 4.2, '2024-01-02 00:00:00'),
    (7, '2024-01-03', 4, 10, 2, 4.3, '2024-01-03 00:00:00'),
    (8, '2024-01-01', 3, 4, 1, 4.4, '2024-01-01 00:00:00'),
    (8, '2024-01-02', 3, 6, 1, 4.5, '2024-01-02 00:00:00'),
    (8, '2024-01-03', 3, 8, 1, 4.6, '2024-01-03 00:00:00')";
    
    $pdo->exec($sql);
    echo "✅ تم إدراج 24 تقرير إحصائيات افتراضي\n";
    
    echo "<h2>9. التحقق من إحصائيات الجداول الجديدة</h2>\n";
    
    // إحصائيات provider_requests
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM provider_requests");
    $providerRequestsCount = $stmt->fetch(PDO::FETCH_ASSOC)['count'];
    echo "📊 عدد طلبات الانضمام: $providerRequestsCount\n";
    
    // إحصائيات profile_update_requests
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM profile_update_requests");
    $profileRequestsCount = $stmt->fetch(PDO::FETCH_ASSOC)['count'];
    echo "📊 عدد طلبات تحديث الملف الشخصي: $profileRequestsCount\n";
    
    // إحصائيات messages
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM messages");
    $messagesCount = $stmt->fetch(PDO::FETCH_ASSOC)['count'];
    echo "📊 عدد الرسائل: $messagesCount\n";
    
    // إحصائيات provider_stats_reports
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM provider_stats_reports");
    $statsReportsCount = $stmt->fetch(PDO::FETCH_ASSOC)['count'];
    echo "📊 عدد تقارير الإحصائيات: $statsReportsCount\n";
    
    echo "<h2>✅ تم إنجاز جميع المهام بنجاح!</h2>\n";
    echo "<p>تم إنشاء 4 جداول جديدة مع البيانات الافتراضية:</p>\n";
    echo "<ul>\n";
    echo "<li>provider_requests - طلبات الانضمام</li>\n";
    echo "<li>profile_update_requests - طلبات تحديث الملف الشخصي</li>\n";
    echo "<li>messages - الرسائل</li>\n";
    echo "<li>provider_stats_reports - تقارير الإحصائيات</li>\n";
    echo "</ul>\n";
    
} catch (PDOException $e) {
    echo "<h2>❌ خطأ في قاعدة البيانات</h2>\n";
    echo "<p>الخطأ: " . $e->getMessage() . "</p>\n";
} catch (Exception $e) {
    echo "<h2>❌ خطأ عام</h2>\n";
    echo "<p>الخطأ: " . $e->getMessage() . "</p>\n";
}
?> 