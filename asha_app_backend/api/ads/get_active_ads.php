
<?php
/**
 * API endpoint لجلب الإعلانات النشطة
 * GET /api/ads/get_active_ads.php
 */

require_once '../../config.php';
require_once '../../database.php';

// التحقق من طريقة الطلب
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    errorResponse('طريقة الطلب غير مدعومة', 405);
}

try {
    $database = new Database();
    $database->connect();

    // جلب الإعلانات النشطة التي لم تنته صلاحيتها بعد
    $query = "SELECT * FROM ads WHERE is_active = 1 AND (end_date IS NULL OR end_date >= CURDATE()) ORDER BY created_at DESC";
    $ads = $database->select($query);

    // معالجة البيانات (تحويل JSON إلى array إذا كان هناك حقل JSON)
    foreach ($ads as &$ad) {
        if (isset($ad['images'])) {
            $ad['images'] = json_decode($ad['images'], true) ?: [];
        }
        // يمكنك إضافة المزيد من المعالجة هنا إذا كانت هناك حقول أخرى تحتاج إلى تحويل
    }

    successResponse($ads, 'تم جلب الإعلانات النشطة بنجاح');

} catch (Exception $e) {
    logError("Get active ads error: " . $e->getMessage());
    errorResponse('حدث خطأ أثناء جلب الإعلانات', 500);
}

?>