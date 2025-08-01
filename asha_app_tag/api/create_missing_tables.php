<?php
/**
 * إنشاء الجداول المفقودة في قاعدة البيانات
 */

require_once 'config.php';
require_once 'database.php';

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

try {
    $database = new Database();
    $conn = $database->connect();
    
    if (!$conn) {
        throw new Exception('فشل في الاتصال بقاعدة البيانات');
    }
    
    $results = [];
    
    // إنشاء جدول التقييمات
    $reviewsTable = "
    CREATE TABLE IF NOT EXISTS reviews (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        service_id INT NOT NULL,
        provider_id INT NOT NULL,
        rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
        comment TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE,
        FOREIGN KEY (provider_id) REFERENCES users(id) ON DELETE CASCADE,
        INDEX idx_user_id (user_id),
        INDEX idx_service_id (service_id),
        INDEX idx_provider_id (provider_id),
        INDEX idx_rating (rating)
    )";
    
    if ($database->query($reviewsTable)) {
        $results['reviews'] = 'تم إنشاء جدول التقييمات بنجاح';
    } else {
        $results['reviews'] = 'فشل في إنشاء جدول التقييمات';
    }
    
    // إنشاء جدول المفضلات
    $favoritesTable = "
    CREATE TABLE IF NOT EXISTS favorites (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        service_id INT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE,
        UNIQUE KEY unique_user_service (user_id, service_id),
        INDEX idx_user_id (user_id),
        INDEX idx_service_id (service_id)
    )";
    
    if ($database->query($favoritesTable)) {
        $results['favorites'] = 'تم إنشاء جدول المفضلات بنجاح';
    } else {
        $results['favorites'] = 'فشل في إنشاء جدول المفضلات';
    }
    
    // إنشاء جدول التعليقات
    $commentsTable = "
    CREATE TABLE IF NOT EXISTS comments (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        service_id INT NOT NULL,
        comment TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE,
        INDEX idx_user_id (user_id),
        INDEX idx_service_id (service_id)
    )";
    
    if ($database->query($commentsTable)) {
        $results['comments'] = 'تم إنشاء جدول التعليقات بنجاح';
    } else {
        $results['comments'] = 'فشل في إنشاء جدول التعليقات';
    }
    
    // إنشاء جدول الإشعارات
    $notificationsTable = "
    CREATE TABLE IF NOT EXISTS notifications (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        title VARCHAR(255) NOT NULL,
        message TEXT,
        type ENUM('booking', 'service', 'review', 'promotion', 'reminder') DEFAULT 'booking',
        is_read BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        INDEX idx_user_id (user_id),
        INDEX idx_is_read (is_read),
        INDEX idx_type (type)
    )";
    
    if ($database->query($notificationsTable)) {
        $results['notifications'] = 'تم إنشاء جدول الإشعارات بنجاح';
    } else {
        $results['notifications'] = 'فشل في إنشاء جدول الإشعارات';
    }
    
    // إنشاء جدول الرسائل
    $messagesTable = "
    CREATE TABLE IF NOT EXISTS messages (
        id INT AUTO_INCREMENT PRIMARY KEY,
        sender_id INT NOT NULL,
        receiver_id INT NOT NULL,
        message TEXT NOT NULL,
        is_read BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (receiver_id) REFERENCES users(id) ON DELETE CASCADE,
        INDEX idx_sender_id (sender_id),
        INDEX idx_receiver_id (receiver_id),
        INDEX idx_is_read (is_read)
    )";
    
    if ($database->query($messagesTable)) {
        $results['messages'] = 'تم إنشاء جدول الرسائل بنجاح';
    } else {
        $results['messages'] = 'فشل في إنشاء جدول الرسائل';
    }
    
    // إنشاء جدول طلبات مزودي الخدمات
    $providerRequestsTable = "
    CREATE TABLE IF NOT EXISTS provider_requests (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        category_id INT NOT NULL,
        request_type ENUM('registration', 'category_change', 'verification') DEFAULT 'registration',
        status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
        notes TEXT,
        admin_notes TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE,
        INDEX idx_user_id (user_id),
        INDEX idx_status (status)
    )";
    
    if ($database->query($providerRequestsTable)) {
        $results['provider_requests'] = 'تم إنشاء جدول طلبات مزودي الخدمات بنجاح';
    } else {
        $results['provider_requests'] = 'فشل في إنشاء جدول طلبات مزودي الخدمات';
    }
    
    // إنشاء جدول طلبات تحديث الملف الشخصي
    $profileUpdateRequestsTable = "
    CREATE TABLE IF NOT EXISTS profile_update_requests (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        request_type ENUM('name', 'email', 'phone', 'address', 'other') DEFAULT 'other',
        old_value TEXT,
        new_value TEXT,
        status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
        admin_notes TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        INDEX idx_user_id (user_id),
        INDEX idx_status (status)
    )";
    
    if ($database->query($profileUpdateRequestsTable)) {
        $results['profile_update_requests'] = 'تم إنشاء جدول طلبات تحديث الملف الشخصي بنجاح';
    } else {
        $results['profile_update_requests'] = 'فشل في إنشاء جدول طلبات تحديث الملف الشخصي';
    }
    
    // إنشاء جدول تقارير إحصائيات مزودي الخدمات
    $providerStatsReportsTable = "
    CREATE TABLE IF NOT EXISTS provider_stats_reports (
        id INT AUTO_INCREMENT PRIMARY KEY,
        provider_id INT NOT NULL,
        report_date DATE NOT NULL,
        total_services INT DEFAULT 0,
        total_bookings INT DEFAULT 0,
        total_reviews INT DEFAULT 0,
        avg_rating DECIMAL(3,2) DEFAULT 0.00,
        total_revenue DECIMAL(10,2) DEFAULT 0.00,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (provider_id) REFERENCES users(id) ON DELETE CASCADE,
        INDEX idx_provider_id (provider_id),
        INDEX idx_report_date (report_date)
    )";
    
    if ($database->query($providerStatsReportsTable)) {
        $results['provider_stats_reports'] = 'تم إنشاء جدول تقارير إحصائيات مزودي الخدمات بنجاح';
    } else {
        $results['provider_stats_reports'] = 'فشل في إنشاء جدول تقارير إحصائيات مزودي الخدمات';
    }
    
    successResponse($results, 'تم إنشاء جميع الجداول المفقودة بنجاح');
    
} catch (Exception $e) {
    logError("Create missing tables error: " . $e->getMessage());
    errorResponse('فشل في إنشاء الجداول المفقودة: ' . $e->getMessage(), 500);
}
?> 