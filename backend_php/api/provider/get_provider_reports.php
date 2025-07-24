<?php
header('Content-Type: application/json; charset=utf-8');
require_once '../../config/database.php';

$pdo = getDBConnection();
if (!$pdo) {
    echo json_encode(['success' => false, 'message' => 'فشل الاتصال بقاعدة البيانات']);
    exit;
}

$provider_id = isset($_GET['provider_id']) ? intval($_GET['provider_id']) : 0;
$from = isset($_GET['from']) ? $_GET['from'] : date('Y-m-d', strtotime('-30 days'));
$to = isset($_GET['to']) ? $_GET['to'] : date('Y-m-d');
if ($provider_id <= 0) {
    echo json_encode(['success' => false, 'message' => 'معرف المزود غير صحيح']);
    exit;
}

$stmt = $pdo->prepare('SELECT report_date, services_count, bookings_count, ads_count, avg_rating FROM provider_stats_reports WHERE provider_id = ? AND report_date BETWEEN ? AND ? ORDER BY report_date ASC');
$stmt->execute([$provider_id, $from, $to]);
$reports = $stmt->fetchAll();

echo json_encode([
    'success' => true,
    'reports' => $reports
]); 