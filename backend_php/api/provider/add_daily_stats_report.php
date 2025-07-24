<?php
header('Content-Type: application/json; charset=utf-8');
require_once '../../config/database.php';

$pdo = getDBConnection();
if (!$pdo) {
    echo json_encode(['success' => false, 'message' => 'فشل الاتصال بقاعدة البيانات']);
    exit;
}

$provider_id = isset($_GET['provider_id']) ? intval($_GET['provider_id']) : 0;
$report_date = isset($_GET['date']) ? $_GET['date'] : date('Y-m-d');
if ($provider_id <= 0) {
    echo json_encode(['success' => false, 'message' => 'معرف المزود غير صحيح']);
    exit;
}

// حساب الإحصائيات من الجداول الأساسية
$stmt = $pdo->prepare('SELECT COUNT(*) FROM services WHERE provider_id = ?');
$stmt->execute([$provider_id]);
$services_count = $stmt->fetchColumn();

$stmt = $pdo->prepare('SELECT COUNT(*) FROM bookings WHERE provider_id = ?');
$stmt->execute([$provider_id]);
$bookings_count = $stmt->fetchColumn();

$stmt = $pdo->prepare('SELECT COUNT(*) FROM ads WHERE provider_id = ?');
$stmt->execute([$provider_id]);
$ads_count = $stmt->fetchColumn();

$stmt = $pdo->prepare('SELECT AVG(rating) FROM reviews WHERE service_id IN (SELECT id FROM services WHERE provider_id = ?)');
$stmt->execute([$provider_id]);
$avg_rating = round(floatval($stmt->fetchColumn()), 2);

// إدراج التقرير أو تحديثه إذا كان موجوداً
$stmt = $pdo->prepare('INSERT INTO provider_stats_reports (provider_id, report_date, services_count, bookings_count, ads_count, avg_rating) VALUES (?, ?, ?, ?, ?, ?) ON DUPLICATE KEY UPDATE services_count = VALUES(services_count), bookings_count = VALUES(bookings_count), ads_count = VALUES(ads_count), avg_rating = VALUES(avg_rating)');
$success = $stmt->execute([$provider_id, $report_date, $services_count, $bookings_count, $ads_count, $avg_rating]);

if ($success) {
    echo json_encode(['success' => true, 'message' => 'تم إضافة التقرير اليومي بنجاح']);
} else {
    echo json_encode(['success' => false, 'message' => 'فشل في إضافة التقرير']);
} 