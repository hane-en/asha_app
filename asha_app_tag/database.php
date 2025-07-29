<?php
/**
 * فئة إدارة قاعدة البيانات لتطبيق Asha App
 * تحتوي على جميع العمليات الأساسية للتعامل مع قاعدة البيانات
 */

require_once 'config.php';

class Database {
    private $host = DB_HOST;
    private $db_name = DB_NAME;
    private $username = DB_USER;
    private $password = DB_PASS;
    private $charset = DB_CHARSET;
    private $conn;

    /**
     * الاتصال بقاعدة البيانات
     */
    public function connect() {
        $this->conn = null;
        
        try {
            $dsn = "mysql:host=" . $this->host . ";dbname=" . $this->db_name . ";charset=" . $this->charset;
            $this->conn = new PDO($dsn, $this->username, $this->password);
            $this->conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            $this->conn->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
        } catch(PDOException $e) {
            logError("Database connection error: " . $e->getMessage());
            errorResponse("خطأ في الاتصال بقاعدة البيانات", 500);
        }
        
        return $this->conn;
    }

    /**
     * تنفيذ استعلام SELECT
     */
    public function select($query, $params = []) {
        try {
            $stmt = $this->conn->prepare($query);
            $stmt->execute($params);
            return $stmt->fetchAll();
        } catch(PDOException $e) {
            logError("Select query error: " . $e->getMessage() . " Query: " . $query);
            return false;
        }
    }

    /**
     * تنفيذ استعلام SELECT لسجل واحد
     */
    public function selectOne($query, $params = []) {
        try {
            $stmt = $this->conn->prepare($query);
            $stmt->execute($params);
            return $stmt->fetch();
        } catch(PDOException $e) {
            logError("Select one query error: " . $e->getMessage() . " Query: " . $query);
            return false;
        }
    }

    /**
     * تنفيذ استعلام INSERT
     */
    public function insert($table, $data) {
        try {
            $columns = implode(',', array_keys($data));
            $placeholders = ':' . implode(', :', array_keys($data));
            
            $query = "INSERT INTO {$table} ({$columns}) VALUES ({$placeholders})";
            $stmt = $this->conn->prepare($query);
            
            if ($stmt->execute($data)) {
                return $this->conn->lastInsertId();
            }
            return false;
        } catch(PDOException $e) {
            logError("Insert query error: " . $e->getMessage() . " Table: " . $table);
            return false;
        }
    }

    /**
     * تنفيذ استعلام UPDATE
     */
    public function update($table, $data, $where, $whereParams = []) {
        try {
            $setClause = [];
            foreach ($data as $key => $value) {
                $setClause[] = "{$key} = :{$key}";
            }
            $setClause = implode(', ', $setClause);
            
            $query = "UPDATE {$table} SET {$setClause} WHERE {$where}";
            $stmt = $this->conn->prepare($query);
            
            $params = array_merge($data, $whereParams);
            return $stmt->execute($params);
        } catch(PDOException $e) {
            logError("Update query error: " . $e->getMessage() . " Table: " . $table);
            return false;
        }
    }

    /**
     * تنفيذ استعلام DELETE
     */
    public function delete($table, $where, $params = []) {
        try {
            $query = "DELETE FROM {$table} WHERE {$where}";
            $stmt = $this->conn->prepare($query);
            return $stmt->execute($params);
        } catch(PDOException $e) {
            logError("Delete query error: " . $e->getMessage() . " Table: " . $table);
            return false;
        }
    }

    /**
     * تنفيذ استعلام مخصص
     */
    public function query($query, $params = []) {
        try {
            $stmt = $this->conn->prepare($query);
            return $stmt->execute($params);
        } catch(PDOException $e) {
            logError("Custom query error: " . $e->getMessage() . " Query: " . $query);
            return false;
        }
    }

    /**
     * تنفيذ استعلام UPDATE أو DELETE أو INSERT
     */
    public function execute($query, $params = []) {
        try {
            $stmt = $this->conn->prepare($query);
            return $stmt->execute($params);
        } catch(PDOException $e) {
            logError("Execute query error: " . $e->getMessage() . " Query: " . $query);
            return false;
        }
    }

    /**
     * بدء معاملة
     */
    public function beginTransaction() {
        return $this->conn->beginTransaction();
    }

    /**
     * تأكيد المعاملة
     */
    public function commit() {
        return $this->conn->commit();
    }

    /**
     * إلغاء المعاملة
     */
    public function rollback() {
        return $this->conn->rollback();
    }

    /**
     * الحصول على عدد الصفوف المتأثرة
     */
    public function rowCount() {
        return $this->conn->rowCount();
    }

    /**
     * إغلاق الاتصال
     */
    public function close() {
        $this->conn = null;
    }

    /**
     * التحقق من وجود جدول
     */
    public function tableExists($table) {
        $query = "SHOW TABLES LIKE :table";
        $result = $this->selectOne($query, ['table' => $table]);
        return $result !== false;
    }

    /**
     * الحصول على بنية الجدول
     */
    public function getTableStructure($table) {
        $query = "DESCRIBE {$table}";
        return $this->select($query);
    }

    /**
     * تنفيذ استعلام مع ترقيم الصفحات
     */
    public function selectWithPagination($query, $params = [], $page = 1, $limit = PAGINATION_LIMIT) {
        $offset = ($page - 1) * $limit;
        $query .= " LIMIT {$limit} OFFSET {$offset}";
        
        return $this->select($query, $params);
    }

    /**
     * الحصول على العدد الإجمالي للسجلات
     */
    public function getTotalCount($table, $where = '1=1', $params = []) {
        $query = "SELECT COUNT(*) as total FROM {$table} WHERE {$where}";
        $result = $this->selectOne($query, $params);
        return $result ? $result['total'] : 0;
    }

    /**
     * البحث في جدول
     */
    public function search($table, $columns, $searchTerm, $additionalWhere = '', $params = []) {
        $searchConditions = [];
        foreach ($columns as $column) {
            $searchConditions[] = "{$column} LIKE :search";
        }
        
        $whereClause = '(' . implode(' OR ', $searchConditions) . ')';
        if ($additionalWhere) {
            $whereClause .= " AND {$additionalWhere}";
        }
        
        $query = "SELECT * FROM {$table} WHERE {$whereClause}";
        $params['search'] = "%{$searchTerm}%";
        
        return $this->select($query, $params);
    }

    /**
     * الحصول على السجلات الأحدث
     */
    public function getLatest($table, $limit = 10, $orderBy = 'created_at') {
        $query = "SELECT * FROM {$table} ORDER BY {$orderBy} DESC LIMIT {$limit}";
        return $this->select($query);
    }

    /**
     * التحقق من وجود سجل
     */
    public function exists($table, $where, $params = []) {
        $query = "SELECT COUNT(*) as count FROM {$table} WHERE {$where}";
        $result = $this->selectOne($query, $params);
        return $result && $result['count'] > 0;
    }
}

// إنشاء مثيل من قاعدة البيانات
$database = new Database();
$db = $database->connect();

?>

