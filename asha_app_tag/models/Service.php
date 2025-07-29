<?php
/**
 * نموذج الخدمة - Service Model
 * يحتوي على جميع العمليات المتعلقة بالخدمات
 */

require_once '../config.php';
require_once '../database.php';

class Service {
    private $db;
    private $table = 'services';

    public function __construct() {
        $this->db = new Database();
        $this->db->connect();
    }

    /**
     * إنشاء خدمة جديدة
     */
    public function create($data) {
        return $this->db->insert($this->table, $data);
    }

    /**
     * الحصول على خدمة بالمعرف
     */
    public function getById($id) {
        $query = "
            SELECT 
                s.*,
                c.name as category_name,
                u.name as provider_name,
                u.email as provider_email,
                u.phone as provider_phone,
                u.rating as provider_rating,
                u.profile_image as provider_image
            FROM {$this->table} s
            LEFT JOIN categories c ON s.category_id = c.id
            LEFT JOIN users u ON s.provider_id = u.id
            WHERE s.id = :id
        ";

        return $this->db->selectOne($query, ['id' => $id]);
    }

    /**
     * تحديث خدمة
     */
    public function update($id, $data) {
        return $this->db->update($this->table, $data, 'id = :id', ['id' => $id]);
    }

    /**
     * حذف خدمة
     */
    public function delete($id) {
        return $this->db->delete($this->table, 'id = :id', ['id' => $id]);
    }

    /**
     * الحصول على خدمات مزود معين
     */
    public function getByProvider($providerId, $page = 1, $limit = PAGINATION_LIMIT) {
        $query = "
            SELECT 
                s.*,
                c.name as category_name,
                (SELECT COUNT(*) FROM bookings b WHERE b.service_id = s.id) as total_bookings,
                (SELECT COUNT(*) FROM favorites f WHERE f.service_id = s.id) as total_favorites,
                (SELECT AVG(rating) FROM reviews r WHERE r.service_id = s.id) as avg_rating,
                (SELECT COUNT(*) FROM reviews r WHERE r.service_id = s.id) as reviews_count
            FROM {$this->table} s
            LEFT JOIN categories c ON s.category_id = c.id
            WHERE s.provider_id = :provider_id
            ORDER BY s.created_at DESC
        ";

        return $this->db->selectWithPagination($query, ['provider_id' => $providerId], $page, $limit);
    }

    /**
     * الحصول على الخدمات بالفئة
     */
    public function getByCategory($categoryId, $page = 1, $limit = PAGINATION_LIMIT) {
        $query = "
            SELECT 
                s.*,
                c.name as category_name,
                u.name as provider_name,
                u.rating as provider_rating,
                u.profile_image as provider_image
            FROM {$this->table} s
            LEFT JOIN categories c ON s.category_id = c.id
            LEFT JOIN users u ON s.provider_id = u.id
            WHERE s.category_id = :category_id AND s.is_active = 1 AND s.is_verified = 1
            ORDER BY s.created_at DESC
        ";

        return $this->db->selectWithPagination($query, ['category_id' => $categoryId], $page, $limit);
    }

    /**
     * البحث في الخدمات
     */
    public function search($searchTerm, $filters = []) {
        $whereConditions = ['s.is_active = 1', 's.is_verified = 1'];
        $params = [];

        // البحث النصي
        if ($searchTerm) {
            $whereConditions[] = '(s.title LIKE :search OR s.description LIKE :search OR s.tags LIKE :search)';
            $params['search'] = "%{$searchTerm}%";
        }

        // فلتر الفئة
        if (isset($filters['category_id']) && $filters['category_id']) {
            $whereConditions[] = 's.category_id = :category_id';
            $params['category_id'] = $filters['category_id'];
        }

        // فلتر المدينة
        if (isset($filters['city']) && $filters['city']) {
            $whereConditions[] = 's.city = :city';
            $params['city'] = $filters['city'];
        }

        // فلتر السعر
        if (isset($filters['min_price']) && $filters['min_price']) {
            $whereConditions[] = 's.price >= :min_price';
            $params['min_price'] = $filters['min_price'];
        }

        if (isset($filters['max_price']) && $filters['max_price']) {
            $whereConditions[] = 's.price <= :max_price';
            $params['max_price'] = $filters['max_price'];
        }

        // فلتر التقييم
        if (isset($filters['min_rating']) && $filters['min_rating']) {
            $whereConditions[] = 's.rating >= :min_rating';
            $params['min_rating'] = $filters['min_rating'];
        }

        // فلتر المميزة
        if (isset($filters['is_featured']) && $filters['is_featured']) {
            $whereConditions[] = 's.is_featured = 1';
        }

        $whereClause = implode(' AND ', $whereConditions);

        $query = "
            SELECT 
                s.*,
                c.name as category_name,
                u.name as provider_name,
                u.rating as provider_rating,
                u.profile_image as provider_image
            FROM {$this->table} s
            LEFT JOIN categories c ON s.category_id = c.id
            LEFT JOIN users u ON s.provider_id = u.id
            WHERE {$whereClause}
            ORDER BY s.is_featured DESC, s.rating DESC, s.created_at DESC
        ";

        return $this->db->select($query, $params);
    }

    /**
     * الحصول على الخدمات المميزة
     */
    public function getFeatured($limit = 10) {
        $query = "
            SELECT 
                s.*,
                c.name as category_name,
                u.name as provider_name,
                u.rating as provider_rating,
                u.profile_image as provider_image
            FROM {$this->table} s
            LEFT JOIN categories c ON s.category_id = c.id
            LEFT JOIN users u ON s.provider_id = u.id
            WHERE s.is_featured = 1 AND s.is_active = 1 AND s.is_verified = 1
            ORDER BY s.created_at DESC
            LIMIT {$limit}
        ";

        return $this->db->select($query);
    }

    /**
     * الحصول على أحدث الخدمات
     */
    public function getLatest($limit = 10) {
        $query = "
            SELECT 
                s.*,
                c.name as category_name,
                u.name as provider_name,
                u.rating as provider_rating,
                u.profile_image as provider_image
            FROM {$this->table} s
            LEFT JOIN categories c ON s.category_id = c.id
            LEFT JOIN users u ON s.provider_id = u.id
            WHERE s.is_active = 1 AND s.is_verified = 1
            ORDER BY s.created_at DESC
            LIMIT {$limit}
        ";

        return $this->db->select($query);
    }

    /**
     * الحصول على الخدمات الأعلى تقييماً
     */
    public function getTopRated($limit = 10) {
        $query = "
            SELECT 
                s.*,
                c.name as category_name,
                u.name as provider_name,
                u.rating as provider_rating,
                u.profile_image as provider_image
            FROM {$this->table} s
            LEFT JOIN categories c ON s.category_id = c.id
            LEFT JOIN users u ON s.provider_id = u.id
            WHERE s.is_active = 1 AND s.is_verified = 1 AND s.rating > 0
            ORDER BY s.rating DESC, s.total_ratings DESC
            LIMIT {$limit}
        ";

        return $this->db->select($query);
    }

    /**
     * الحصول على الخدمات القريبة
     */
    public function getNearby($latitude, $longitude, $radius = 50, $limit = 20) {
        $query = "
            SELECT 
                s.*,
                c.name as category_name,
                u.name as provider_name,
                u.rating as provider_rating,
                u.profile_image as provider_image,
                (6371 * acos(cos(radians(:lat)) * cos(radians(s.latitude)) * 
                cos(radians(s.longitude) - radians(:lng)) + sin(radians(:lat)) * 
                sin(radians(s.latitude)))) AS distance
            FROM {$this->table} s
            LEFT JOIN categories c ON s.category_id = c.id
            LEFT JOIN users u ON s.provider_id = u.id
            WHERE s.is_active = 1 AND s.is_verified = 1 
            AND s.latitude IS NOT NULL AND s.longitude IS NOT NULL
            HAVING distance < :radius
            ORDER BY distance ASC
            LIMIT {$limit}
        ";

        return $this->db->select($query, [
            'lat' => $latitude,
            'lng' => $longitude,
            'radius' => $radius
        ]);
    }

    /**
     * تحديث التقييم
     */
    public function updateRating($serviceId) {
        $query = "
            UPDATE {$this->table} s
            SET 
                rating = (
                    SELECT AVG(rating) 
                    FROM reviews r 
                    WHERE r.service_id = s.id
                ),
                total_ratings = (
                    SELECT COUNT(*) 
                    FROM reviews r 
                    WHERE r.service_id = s.id
                )
            WHERE s.id = :service_id
        ";

        return $this->db->query($query, ['service_id' => $serviceId]);
    }

    /**
     * تحديث عداد الحجوزات
     */
    public function updateBookingCount($serviceId) {
        $query = "
            UPDATE {$this->table} s
            SET booking_count = (
                SELECT COUNT(*) 
                FROM bookings b 
                WHERE b.service_id = s.id
            )
            WHERE s.id = :service_id
        ";

        return $this->db->query($query, ['service_id' => $serviceId]);
    }

    /**
     * تحديث عداد المفضلة
     */
    public function updateFavoriteCount($serviceId) {
        $query = "
            UPDATE {$this->table} s
            SET favorite_count = (
                SELECT COUNT(*) 
                FROM favorites f 
                WHERE f.service_id = s.id
            )
            WHERE s.id = :service_id
        ";

        return $this->db->query($query, ['service_id' => $serviceId]);
    }

    /**
     * الموافقة على الخدمة
     */
    public function approve($id) {
        return $this->db->update(
            $this->table,
            ['is_verified' => 1],
            'id = :id',
            ['id' => $id]
        );
    }

    /**
     * رفض الخدمة
     */
    public function reject($id) {
        return $this->db->update(
            $this->table,
            ['is_verified' => 0, 'is_active' => 0],
            'id = :id',
            ['id' => $id]
        );
    }

    /**
     * تمييز الخدمة
     */
    public function feature($id) {
        return $this->db->update(
            $this->table,
            ['is_featured' => 1],
            'id = :id',
            ['id' => $id]
        );
    }

    /**
     * إلغاء تمييز الخدمة
     */
    public function unfeature($id) {
        return $this->db->update(
            $this->table,
            ['is_featured' => 0],
            'id = :id',
            ['id' => $id]
        );
    }

    /**
     * الحصول على إحصائيات الخدمات
     */
    public function getStats() {
        $stats = [];

        // العدد الإجمالي للخدمات
        $stats['total_services'] = $this->db->getTotalCount($this->table);

        // الخدمات النشطة
        $stats['active_services'] = $this->db->getTotalCount($this->table, 'is_active = 1');

        // الخدمات المعتمدة
        $stats['verified_services'] = $this->db->getTotalCount($this->table, 'is_verified = 1');

        // الخدمات المميزة
        $stats['featured_services'] = $this->db->getTotalCount($this->table, 'is_featured = 1');

        // الخدمات المضافة اليوم
        $stats['today_services'] = $this->db->getTotalCount(
            $this->table,
            'DATE(created_at) = CURDATE()'
        );

        return $stats;
    }

    /**
     * تنظيف بيانات الخدمة للعرض
     */
    public function sanitizeForDisplay($service) {
        if (!$service) return null;

        // تحويل JSON إلى array
        if (isset($service['images'])) {
            $service['images'] = json_decode($service['images'], true) ?: [];
        }
        if (isset($service['specifications'])) {
            $service['specifications'] = json_decode($service['specifications'], true) ?: [];
        }
        if (isset($service['tags'])) {
            $service['tags'] = json_decode($service['tags'], true) ?: [];
        }
        if (isset($service['payment_terms'])) {
            $service['payment_terms'] = json_decode($service['payment_terms'], true) ?: [];
        }
        if (isset($service['availability'])) {
            $service['availability'] = json_decode($service['availability'], true) ?: [];
        }

        // تحويل الأرقام
        $service['price'] = (float)$service['price'];
        $service['original_price'] = $service['original_price'] ? (float)$service['original_price'] : null;
        $service['rating'] = (float)$service['rating'];
        $service['deposit_amount'] = $service['deposit_amount'] ? (float)$service['deposit_amount'] : null;

        // تحويل القيم المنطقية
        $service['is_active'] = (bool)$service['is_active'];
        $service['is_verified'] = (bool)$service['is_verified'];
        $service['is_featured'] = (bool)$service['is_featured'];
        $service['deposit_required'] = (bool)$service['deposit_required'];

        return $service;
    }
}

?>

