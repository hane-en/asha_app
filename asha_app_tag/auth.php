<?php
/**
 * فئة المصادقة والتفويض لتطبيق Asha App
 * تحتوي على جميع وظائف تسجيل الدخول والخروج والتحقق
 */

require_once 'config.php';
require_once 'database.php';

class Auth {
    private $db;

    public function __construct() {
        $this->db = new Database();
        $this->db->connect();
    }

    /**
     * تسجيل مستخدم جديد
     */
    public function register($data) {
        // التحقق من صحة البيانات
        if (!$this->validateRegistrationData($data)) {
            return false;
        }

        // التحقق من عدم وجود المستخدم مسبقاً
        if ($this->userExists($data['email'], $data['phone'])) {
            errorResponse('المستخدم موجود مسبقاً');
        }

        // تشفير كلمة المرور
        $data['password'] = hashPassword($data['password']);
        
        // توليد كود التحقق
        $data['verification_code'] = generateVerificationCode();
        
        // إدراج المستخدم الجديد
        $userId = $this->db->insert('users', $data);
        
        if ($userId) {
            // إرسال كود التحقق
            $this->sendVerificationCode($data['email'], $data['verification_code']);
            
            return [
                'user_id' => $userId,
                'message' => 'تم إنشاء الحساب بنجاح. يرجى التحقق من بريدك الإلكتروني'
            ];
        }
        
        return false;
    }

    /**
     * تسجيل الدخول
     */
    public function login($email, $password, $userType = null) {
        // البحث عن المستخدم
        $whereClause = 'email = :email AND is_active = 1';
        $params = ['email' => $email];
        
        if ($userType) {
            $whereClause .= ' AND user_type = :user_type';
            $params['user_type'] = $userType;
        }
        
        $user = $this->db->selectOne("SELECT * FROM users WHERE {$whereClause}", $params);
        
        if (!$user) {
            errorResponse('بيانات الدخول غير صحيحة');
        }

        // التحقق من كلمة المرور
        if (!verifyPassword($password, $user['password'])) {
            errorResponse('بيانات الدخول غير صحيحة');
        }

        // التحقق من تفعيل الحساب
        if (!$user['is_verified']) {
            errorResponse('يرجى تفعيل حسابك أولاً');
        }

        // تحديث آخر تسجيل دخول
        $this->updateLastLogin($user['id']);

        // إنشاء JWT token
        $token = $this->generateJWT($user);

        return [
            'user' => $this->sanitizeUserData($user),
            'token' => $token
        ];
    }

    /**
     * تسجيل الخروج
     */
    public function logout($userId) {
        // يمكن إضافة منطق إضافي هنا مثل إلغاء الرموز المميزة
        return true;
    }

    /**
     * التحقق من الحساب
     */
    public function verifyAccount($email, $code) {
        $user = $this->db->selectOne(
            "SELECT * FROM users WHERE email = :email AND verification_code = :code",
            ['email' => $email, 'code' => $code]
        );

        if (!$user) {
            errorResponse('كود التحقق غير صحيح');
        }

        // تفعيل الحساب
        $updated = $this->db->update(
            'users',
            ['is_verified' => 1, 'verification_code' => null],
            'id = :id',
            ['id' => $user['id']]
        );

        if ($updated) {
            return ['message' => 'تم تفعيل الحساب بنجاح'];
        }

        return false;
    }

    /**
     * إعادة إرسال كود التحقق
     */
    public function resendVerificationCode($email) {
        $user = $this->db->selectOne(
            "SELECT * FROM users WHERE email = :email",
            ['email' => $email]
        );

        if (!$user) {
            errorResponse('المستخدم غير موجود');
        }

        if ($user['is_verified']) {
            errorResponse('الحساب مفعل مسبقاً');
        }

        // توليد كود جديد
        $newCode = generateVerificationCode();
        
        $updated = $this->db->update(
            'users',
            ['verification_code' => $newCode],
            'id = :id',
            ['id' => $user['id']]
        );

        if ($updated) {
            $this->sendVerificationCode($email, $newCode);
            return ['message' => 'تم إرسال كود التحقق الجديد'];
        }

        return false;
    }

    /**
     * نسيان كلمة المرور
     */
    public function forgotPassword($email) {
        $user = $this->db->selectOne(
            "SELECT * FROM users WHERE email = :email",
            ['email' => $email]
        );

        if (!$user) {
            errorResponse('البريد الإلكتروني غير مسجل');
        }

        // توليد كود إعادة التعيين
        $resetCode = generateVerificationCode();
        
        $updated = $this->db->update(
            'users',
            ['verification_code' => $resetCode],
            'id = :id',
            ['id' => $user['id']]
        );

        if ($updated) {
            $this->sendPasswordResetCode($email, $resetCode);
            return ['message' => 'تم إرسال كود إعادة تعيين كلمة المرور'];
        }

        return false;
    }

    /**
     * إعادة تعيين كلمة المرور
     */
    public function resetPassword($email, $code, $newPassword) {
        $user = $this->db->selectOne(
            "SELECT * FROM users WHERE email = :email AND verification_code = :code",
            ['email' => $email, 'code' => $code]
        );

        if (!$user) {
            errorResponse('كود إعادة التعيين غير صحيح');
        }

        // تحديث كلمة المرور
        $updated = $this->db->update(
            'users',
            [
                'password' => hashPassword($newPassword),
                'verification_code' => null
            ],
            'id = :id',
            ['id' => $user['id']]
        );

        if ($updated) {
            return ['message' => 'تم تغيير كلمة المرور بنجاح'];
        }

        return false;
    }

    /**
     * التحقق من صحة الرمز المميز JWT
     */
    public function validateToken($token) {
        try {
            // هنا يجب استخدام مكتبة JWT للتحقق من الرمز
            // للبساطة، سنستخدم طريقة أساسية
            $tokenParts = explode('.', $token);
            if (count($tokenParts) !== 3) {
                return false;
            }

            $payload = json_decode(base64_decode($tokenParts[1]), true);
            
            if (!$payload || $payload['exp'] < time()) {
                return false;
            }

            return $payload;
        } catch (Exception $e) {
            return false;
        }
    }

    /**
     * الحصول على المستخدم الحالي من الرمز المميز
     */
    public function getCurrentUser($token) {
        $payload = $this->validateToken($token);
        
        if (!$payload) {
            return false;
        }

        $user = $this->db->selectOne(
            "SELECT * FROM users WHERE id = :id AND is_active = 1",
            ['id' => $payload['user_id']]
        );

        return $user ? $this->sanitizeUserData($user) : false;
    }

    /**
     * التحقق من الصلاحيات
     */
    public function hasPermission($userType, $requiredType) {
        $permissions = [
            'admin' => ['admin', 'provider', 'user'],
            'provider' => ['provider', 'user'],
            'user' => ['user']
        ];

        return in_array($requiredType, $permissions[$userType] ?? []);
    }

    /**
     * التحقق من صحة بيانات التسجيل
     */
    private function validateRegistrationData($data) {
        if (empty($data['name']) || empty($data['email']) || empty($data['phone']) || empty($data['password'])) {
            errorResponse('جميع الحقول مطلوبة');
        }

        if (!validateEmail($data['email'])) {
            errorResponse('البريد الإلكتروني غير صحيح');
        }

        if (!validatePhone($data['phone'])) {
            errorResponse('رقم الهاتف غير صحيح');
        }

        if (strlen($data['password']) < 6) {
            errorResponse('كلمة المرور يجب أن تكون 6 أحرف على الأقل');
        }

        return true;
    }

    /**
     * التحقق من وجود المستخدم
     */
    private function userExists($email, $phone) {
        return $this->db->exists(
            'users',
            'email = :email OR phone = :phone',
            ['email' => $email, 'phone' => $phone]
        );
    }

    /**
     * تحديث آخر تسجيل دخول
     */
    private function updateLastLogin($userId) {
        $this->db->update(
            'users',
            ['last_login_at' => date('Y-m-d H:i:s')],
            'id = :id',
            ['id' => $userId]
        );
    }

    /**
     * إنشاء JWT token
     */
    private function generateJWT($user) {
        $header = json_encode(['typ' => 'JWT', 'alg' => JWT_ALGORITHM]);
        $payload = json_encode([
            'user_id' => $user['id'],
            'email' => $user['email'],
            'user_type' => $user['user_type'],
            'exp' => time() + JWT_EXPIRATION
        ]);

        $headerEncoded = base64_encode($header);
        $payloadEncoded = base64_encode($payload);
        
        $signature = hash_hmac('sha256', $headerEncoded . '.' . $payloadEncoded, JWT_SECRET, true);
        $signatureEncoded = base64_encode($signature);

        return $headerEncoded . '.' . $payloadEncoded . '.' . $signatureEncoded;
    }

    /**
     * تنظيف بيانات المستخدم
     */
    private function sanitizeUserData($user) {
        unset($user['password']);
        unset($user['verification_code']);
        return $user;
    }

    /**
     * إرسال كود التحقق عبر البريد الإلكتروني
     */
    private function sendVerificationCode($email, $code) {
        // هنا يجب إضافة منطق إرسال البريد الإلكتروني
        // للبساطة، سنقوم بتسجيل الكود في ملف
        logError("Verification code for {$email}: {$code}");
        return true;
    }

    /**
     * إرسال كود إعادة تعيين كلمة المرور
     */
    private function sendPasswordResetCode($email, $code) {
        // هنا يجب إضافة منطق إرسال البريد الإلكتروني
        logError("Password reset code for {$email}: {$code}");
        return true;
    }
}

?>

