<?php
/**
 * نموذج المستخدم - User Model
 * يحتوي على جميع العمليات المتعلقة بالمستخدمين
 */

require_once '../config.php';
require_once '../database.php';

class User {
    private $db;
    private $table = 'users';

    public function __construct() {
        $this->db = new Database();
        $this->db->connect();
    }

    /**
     * إنشاء مستخدم جديد
     */
    public function create($data) {
        return $this->db->insert($this->table, $data);
    }

    /**
     * الحصول على مستخدم بالمعرف
     */
    public function getById($id) {
        return $this->db->selectOne(
            "SELECT * FROM {$this->table} WHERE id = :id",
            ['id' => $id]
        );
    }

    /**
     * الحصول على مستخدم بالبريد الإلكتروني
     */
    public function getByEmail($email) {
        return $this->db->selectOne(
            "SELECT * FROM {$this->table} WHERE email = :email",
            ['email' => $email]
        );
    }

    /**
     * الحصول على مستخدم برقم الهاتف
     */
    public function getByPhone($phone) {
        return $this->db->selectOne(
            "SELECT * FROM {$this->table} WHERE phone = :phone",
            ['phone' => $phone]
        );
    }

    /**
     * تحديث بيانات المستخدم
     */
    public function update($id, $data) {
        return $this->db->update($this->table, $data, 'id = :id', ['id' => $id]);
    }

    /**
     * حذف مستخدم
     */
    public function delete($id) {
        return $this->db->delete($this->table, 'id = :id', ['id' => $id]);
    }

    /**
     * الحصول على جميع المستخدمين
     */
    public function getAll($page = 1, $limit = PAGINATION_LIMIT, $userType = null) {
        $whereClause = '1=1';
        $params = [];

        if ($userType) {
            $whereClause .= ' AND user_type = :user_type';
            $params['user_type'] = $userType;
        }

        $query = "SELECT * FROM {$this->table} WHERE {$whereClause} ORDER BY created_at DESC";
        return $this->db->selectWithPagination($query, $params, $page, $limit);
    }

    /**
     * البحث في المستخدمين
     */
    public function search($searchTerm, $userType = null) {
        $whereClause = '(name LIKE :search OR email LIKE :search OR phone LIKE :search)';
        $params = ['search' => "%{$searchTerm}%"];

        if ($userType) {
            $whereClause .= ' AND user_type = :user_type';
            $params['user_type'] = $userType;
        }

        $query = "SELECT * FROM {$this->table} WHERE {$whereClause} ORDER BY name ASC";
        return $this->db->select($query, $params);
    }

    /**
     * التحقق من وجود المستخدم
     */
    public function exists($email, $phone) {
        return $this->db->exists(
            $this->table,
            'email = :email OR phone = :phone',
            ['email' => $email, 'phone' => $phone]
        );
    }

    /**
     * تفعيل الحساب
     */
    public function activate($id) {
        return $this->db->update(
            $this->table,
            ['is_verified' => 1, 'verification_code' => null],
            'id = :id',
            ['id' => $id]
        );
    }

    /**
     * إلغاء تفعيل الحساب
     */
    public function deactivate($id) {
        return $this->db->update(
            $this->table,
            ['is_active' => 0],
            'id = :id',
            ['id' => $id]
        );
    }

    /**
     * تحديث كلمة المرور
     */
    public function updatePassword($id, $newPassword) {
        return $this->db->update(
            $this->table,
            ['password' => hashPassword($newPassword)],
            'id = :id',
            ['id' => $id]
        );
    }

    /**
     * تحديث كود التحقق
     */
    public function updateVerificationCode($id, $code) {
        return $this->db->update(
            $this->table,
            ['verification_code' => $code],
            'id = :id',
            ['id' => $id]
        );
    }

    /**
     * تحديث آخر تسجيل دخول
     */
    public function updateLastLogin($id) {
        return $this->db->update(
            $this->table,
            ['last_login_at' => date('Y-m-d H:i:s')],
            'id = :id',
            ['id' => $id]
        );
    }

    /**
     * الحصول على إحصائيات المستخدمين
     */
    public function getStats() {
        $stats = [];

        // العدد الإجمالي للمستخدمين
        $stats['total_users'] = $this->db->getTotalCount($this->table);

        // المستخدمين النشطين
        $stats['active_users'] = $this->db->getTotalCount($this->table, 'is_active = 1');

        // المستخدمين المفعلين
        $stats['verified_users'] = $this->db->getTotalCount($this->table, 'is_verified = 1');

        // مزودي الخدمات
        $stats['providers'] = $this->db->getTotalCount($this->table, 'user_type = "provider"');

        // المستخدمين العاديين
        $stats['regular_users'] = $this->db->getTotalCount($this->table, 'user_type = "user"');

        // المسجلين اليوم
        $stats['today_registrations'] = $this->db->getTotalCount(
            $this->table,
            'DATE(created_at) = CURDATE()'
        );

        // المسجلين هذا الشهر
        $stats['month_registrations'] = $this->db->getTotalCount(
            $this->table,
            'MONTH(created_at) = MONTH(CURDATE()) AND YEAR(created_at) = YEAR(CURDATE())'
        );

        return $stats;
    }

    /**
     * الحصول على أفضل مزودي الخدمات
     */
    public function getTopProviders($limit = 10) {
        $query = "
            SELECT 
                u.*,
                COUNT(s.id) as services_count,
                AVG(s.rating) as avg_service_rating,
                COUNT(b.id) as bookings_count
            FROM {$this->table} u
            LEFT JOIN services s ON u.id = s.provider_id AND s.is_active = 1
            LEFT JOIN bookings b ON u.id = b.provider_id
            WHERE u.user_type = 'provider' AND u.is_active = 1 AND u.is_verified = 1
            GROUP BY u.id
            ORDER BY u.rating DESC, services_count DESC
            LIMIT {$limit}
        ";

        return $this->db->select($query);
    }

    /**
     * تحديث التقييم
     */
    public function updateRating($userId) {
        // حساب متوسط التقييم من الخدمات
        $query = "
            UPDATE {$this->table} u
            SET 
                rating = (
                    SELECT AVG(s.rating) 
                    FROM services s 
                    WHERE s.provider_id = u.id AND s.is_active = 1
                ),
                review_count = (
                    SELECT COUNT(r.id)
                    FROM reviews r
                    LEFT JOIN services s ON r.service_id = s.id
                    WHERE s.provider_id = u.id
                )
            WHERE u.id = :user_id
        ";

        return $this->db->query($query, ['user_id' => $userId]);
    }

    /**
     * تنظيف بيانات المستخدم للعرض
     */
    public function sanitizeForDisplay($user) {
        if (!$user) return null;

        unset($user['password']);
        unset($user['verification_code']);
        
        // تحويل JSON إلى array
        if (isset($user['preferences'])) {
            $user['preferences'] = json_decode($user['preferences'], true) ?: [];
        }
        if (isset($user['social_media'])) {
            $user['social_media'] = json_decode($user['social_media'], true) ?: [];
        }

        // تحويل القيم المنطقية
        $user['is_verified'] = (bool)$user['is_verified'];
        $user['is_active'] = (bool)$user['is_active'];
        $user['is_yemeni_account'] = (bool)$user['is_yemeni_account'];

        // تحويل الأرقام
        $user['rating'] = (float)$user['rating'];
        $user['review_count'] = (int)$user['review_count'];

        return $user;
    }
}

?>

