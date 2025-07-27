<?php
/**
 * نموذج الحجز - Booking Model
 * يحتوي على جميع العمليات المتعلقة بالحجوزات
 */

require_once '../config.php';
require_once '../database.php';

class Booking {
    private $db;
    private $table = 'bookings';

    public function __construct() {
        $this->db = new Database();
        $this->db->connect();
    }

    /**
     * إنشاء حجز جديد
     */
    public function create($data) {
        return $this->db->insert($this->table, $data);
    }

    /**
     * الحصول على حجز بالمعرف
     */
    public function getById($id) {
        $query = "
            SELECT 
                b.*,
                s.title as service_title,
                s.images as service_images,
                s.location as service_location,
                u.name as user_name,
                u.phone as user_phone,
                u.email as user_email,
                p.name as provider_name,
                p.phone as provider_phone,
                p.email as provider_email,
                c.name as category_name
            FROM {$this->table} b
            LEFT JOIN services s ON b.service_id = s.id
            LEFT JOIN users u ON b.user_id = u.id
            LEFT JOIN users p ON b.provider_id = p.id
            LEFT JOIN categories c ON s.category_id = c.id
            WHERE b.id = :id
        ";

        return $this->db->selectOne($query, ['id' => $id]);
    }

    /**
     * تحديث حجز
     */
    public function update($id, $data) {
        return $this->db->update($this->table, $data, 'id = :id', ['id' => $id]);
    }

    /**
     * حذف حجز
     */
    public function delete($id) {
        return $this->db->delete($this->table, 'id = :id', ['id' => $id]);
    }

    /**
     * الحصول على حجوزات المستخدم
     */
    public function getByUser($userId, $status = null, $page = 1, $limit = PAGINATION_LIMIT) {
        $whereClause = 'b.user_id = :user_id';
        $params = ['user_id' => $userId];

        if ($status) {
            $whereClause .= ' AND b.status = :status';
            $params['status'] = $status;
        }

        $query = "
            SELECT 
                b.*,
                s.title as service_title,
                s.images as service_images,
                s.location as service_location,
                p.name as provider_name,
                p.phone as provider_phone,
                p.profile_image as provider_image,
                c.name as category_name
            FROM {$this->table} b
            LEFT JOIN services s ON b.service_id = s.id
            LEFT JOIN users p ON b.provider_id = p.id
            LEFT JOIN categories c ON s.category_id = c.id
            WHERE {$whereClause}
            ORDER BY b.created_at DESC
        ";

        return $this->db->selectWithPagination($query, $params, $page, $limit);
    }

    /**
     * الحصول على حجوزات مزود الخدمة
     */
    public function getByProvider($providerId, $status = null, $page = 1, $limit = PAGINATION_LIMIT) {
        $whereClause = 'b.provider_id = :provider_id';
        $params = ['provider_id' => $providerId];

        if ($status) {
            $whereClause .= ' AND b.status = :status';
            $params['status'] = $status;
        }

        $query = "
            SELECT 
                b.*,
                s.title as service_title,
                s.images as service_images,
                s.location as service_location,
                u.name as user_name,
                u.phone as user_phone,
                u.profile_image as user_image,
                c.name as category_name
            FROM {$this->table} b
            LEFT JOIN services s ON b.service_id = s.id
            LEFT JOIN users u ON b.user_id = u.id
            LEFT JOIN categories c ON s.category_id = c.id
            WHERE {$whereClause}
            ORDER BY b.created_at DESC
        ";

        return $this->db->selectWithPagination($query, $params, $page, $limit);
    }

    /**
     * الحصول على حجوزات خدمة معينة
     */
    public function getByService($serviceId, $status = null) {
        $whereClause = 'b.service_id = :service_id';
        $params = ['service_id' => $serviceId];

        if ($status) {
            $whereClause .= ' AND b.status = :status';
            $params['status'] = $status;
        }

        $query = "
            SELECT 
                b.*,
                u.name as user_name,
                u.phone as user_phone,
                u.email as user_email
            FROM {$this->table} b
            LEFT JOIN users u ON b.user_id = u.id
            WHERE {$whereClause}
            ORDER BY b.booking_date ASC, b.booking_time ASC
        ";

        return $this->db->select($query, $params);
    }

    /**
     * التحقق من توفر الموعد
     */
    public function isTimeSlotAvailable($serviceId, $bookingDate, $bookingTime, $excludeBookingId = null) {
        $whereClause = 'service_id = :service_id AND booking_date = :booking_date AND booking_time = :booking_time AND status IN ("pending", "confirmed")';
        $params = [
            'service_id' => $serviceId,
            'booking_date' => $bookingDate,
            'booking_time' => $bookingTime
        ];

        if ($excludeBookingId) {
            $whereClause .= ' AND id != :exclude_id';
            $params['exclude_id'] = $excludeBookingId;
        }

        return !$this->db->exists($this->table, $whereClause, $params);
    }

    /**
     * تأكيد الحجز
     */
    public function confirm($id) {
        return $this->db->update(
            $this->table,
            ['status' => 'confirmed'],
            'id = :id',
            ['id' => $id]
        );
    }

    /**
     * إلغاء الحجز
     */
    public function cancel($id, $reason = null) {
        $data = ['status' => 'cancelled'];
        if ($reason) {
            $data['notes'] = $reason;
        }

        return $this->db->update($this->table, $data, 'id = :id', ['id' => $id]);
    }

    /**
     * إكمال الحجز
     */
    public function complete($id) {
        return $this->db->update(
            $this->table,
            ['status' => 'completed'],
            'id = :id',
            ['id' => $id]
        );
    }

    /**
     * تحديث حالة الدفع
     */
    public function updatePaymentStatus($id, $status, $method = null) {
        $data = ['payment_status' => $status];
        if ($method) {
            $data['payment_method'] = $method;
        }

        return $this->db->update($this->table, $data, 'id = :id', ['id' => $id]);
    }

    /**
     * الحصول على الحجوزات القادمة
     */
    public function getUpcoming($userId = null, $providerId = null, $limit = 10) {
        $whereConditions = ['b.status IN ("pending", "confirmed")', 'CONCAT(b.booking_date, " ", b.booking_time) > NOW()'];
        $params = [];

        if ($userId) {
            $whereConditions[] = 'b.user_id = :user_id';
            $params['user_id'] = $userId;
        }

        if ($providerId) {
            $whereConditions[] = 'b.provider_id = :provider_id';
            $params['provider_id'] = $providerId;
        }

        $whereClause = implode(' AND ', $whereConditions);

        $query = "
            SELECT 
                b.*,
                s.title as service_title,
                s.images as service_images,
                u.name as user_name,
                p.name as provider_name
            FROM {$this->table} b
            LEFT JOIN services s ON b.service_id = s.id
            LEFT JOIN users u ON b.user_id = u.id
            LEFT JOIN users p ON b.provider_id = p.id
            WHERE {$whereClause}
            ORDER BY b.booking_date ASC, b.booking_time ASC
            LIMIT {$limit}
        ";

        return $this->db->select($query, $params);
    }

    /**
     * الحصول على الحجوزات المنتهية
     */
    public function getPast($userId = null, $providerId = null, $limit = 10) {
        $whereConditions = ['CONCAT(b.booking_date, " ", b.booking_time) < NOW()'];
        $params = [];

        if ($userId) {
            $whereConditions[] = 'b.user_id = :user_id';
            $params['user_id'] = $userId;
        }

        if ($providerId) {
            $whereConditions[] = 'b.provider_id = :provider_id';
            $params['provider_id'] = $providerId;
        }

        $whereClause = implode(' AND ', $whereConditions);

        $query = "
            SELECT 
                b.*,
                s.title as service_title,
                s.images as service_images,
                u.name as user_name,
                p.name as provider_name
            FROM {$this->table} b
            LEFT JOIN services s ON b.service_id = s.id
            LEFT JOIN users u ON b.user_id = u.id
            LEFT JOIN users p ON b.provider_id = p.id
            WHERE {$whereClause}
            ORDER BY b.booking_date DESC, b.booking_time DESC
            LIMIT {$limit}
        ";

        return $this->db->select($query, $params);
    }

    /**
     * الحصول على إحصائيات الحجوزات
     */
    public function getStats($providerId = null) {
        $stats = [];
        $whereClause = '1=1';
        $params = [];

        if ($providerId) {
            $whereClause = 'provider_id = :provider_id';
            $params['provider_id'] = $providerId;
        }

        // العدد الإجمالي للحجوزات
        $stats['total_bookings'] = $this->db->getTotalCount($this->table, $whereClause, $params);

        // الحجوزات المؤكدة
        $confirmedWhere = $whereClause . ' AND status = "confirmed"';
        $stats['confirmed_bookings'] = $this->db->getTotalCount($this->table, $confirmedWhere, $params);

        // الحجوزات المكتملة
        $completedWhere = $whereClause . ' AND status = "completed"';
        $stats['completed_bookings'] = $this->db->getTotalCount($this->table, $completedWhere, $params);

        // الحجوزات الملغية
        $cancelledWhere = $whereClause . ' AND status = "cancelled"';
        $stats['cancelled_bookings'] = $this->db->getTotalCount($this->table, $cancelledWhere, $params);

        // الحجوزات اليوم
        $todayWhere = $whereClause . ' AND DATE(created_at) = CURDATE()';
        $stats['today_bookings'] = $this->db->getTotalCount($this->table, $todayWhere, $params);

        // إجمالي الإيرادات
        $revenueQuery = "SELECT SUM(total_price) as total_revenue FROM {$this->table} WHERE {$whereClause} AND payment_status = 'paid'";
        $revenueResult = $this->db->selectOne($revenueQuery, $params);
        $stats['total_revenue'] = $revenueResult['total_revenue'] ? (float)$revenueResult['total_revenue'] : 0;

        return $stats;
    }

    /**
     * الحصول على تقرير الحجوزات الشهري
     */
    public function getMonthlyReport($year, $providerId = null) {
        $whereClause = 'YEAR(created_at) = :year';
        $params = ['year' => $year];

        if ($providerId) {
            $whereClause .= ' AND provider_id = :provider_id';
            $params['provider_id'] = $providerId;
        }

        $query = "
            SELECT 
                MONTH(created_at) as month,
                COUNT(*) as bookings_count,
                SUM(CASE WHEN payment_status = 'paid' THEN total_price ELSE 0 END) as revenue
            FROM {$this->table}
            WHERE {$whereClause}
            GROUP BY MONTH(created_at)
            ORDER BY month ASC
        ";

        return $this->db->select($query, $params);
    }

    /**
     * تنظيف بيانات الحجز للعرض
     */
    public function sanitizeForDisplay($booking) {
        if (!$booking) return null;

        // تحويل JSON إلى array
        if (isset($booking['service_images'])) {
            $booking['service_images'] = json_decode($booking['service_images'], true) ?: [];
        }

        // تحويل الأرقام
        $booking['total_price'] = (float)$booking['total_price'];

        // إضافة معلومات إضافية
        $bookingDateTime = $booking['booking_date'] . ' ' . $booking['booking_time'];
        $booking['is_past'] = strtotime($bookingDateTime) < time();
        $booking['can_cancel'] = $booking['status'] === 'pending' && !$booking['is_past'];
        $booking['can_review'] = $booking['status'] === 'completed' && !$booking['is_past'];

        return $booking;
    }
}

?>

