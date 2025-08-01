-- =====================================================
-- إنشاء جدول التقييمات (Reviews)
-- =====================================================

USE asha_app_events;

-- إنشاء جدول التقييمات
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
);

-- إضافة بيانات تجريبية للتقييمات
INSERT INTO reviews (user_id, service_id, provider_id, rating, comment) VALUES
(1, 1, 2, 5, 'خدمة ممتازة وجودة عالية'),
(1, 2, 3, 4, 'خدمة جيدة وسعر معقول'),
(2, 1, 2, 5, 'أفضل خدمة تصوير'),
(2, 3, 4, 4, 'خدمة احترافية'),
(3, 2, 3, 3, 'خدمة مقبولة');

-- التحقق من إنشاء الجدول
SELECT 'جدول التقييمات تم إنشاؤه بنجاح' as status;
SELECT COUNT(*) as reviews_count FROM reviews; 