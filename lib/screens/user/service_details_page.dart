import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../models/service_model.dart';
import '../../widgets/service_reviews_widget.dart';

class ServiceDetailsPage extends StatelessWidget {
  final Service service;

  const ServiceDetailsPage({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'تفاصيل الخدمة',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة الخدمة
            if (service.images.isNotEmpty)
              Container(
                width: double.infinity,
                height: 250,
                child: Image.network(
                  service.images.first,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 250,
                      color: AppColors.primaryColor.withOpacity(0.1),
                      child: const Icon(
                        Icons.image,
                        size: 80,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 250,
                color: AppColors.primaryColor.withOpacity(0.1),
                child: const Icon(Icons.image, size: 80, color: Colors.grey),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // عنوان الخدمة
                  Text(
                    service.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // السعر
                  Row(
                    children: [
                      Icon(
                        Icons.attach_money,
                        color: AppColors.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${service.price} ريال',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // الوصف
                  if (service.description != null &&
                      service.description!.isNotEmpty) ...[
                    const Text(
                      'الوصف',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      service.description!,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // معلومات إضافية
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'معلومات الخدمة',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // الفئة
                          if (service.categoryName != null) ...[
                            Row(
                              children: [
                                const Icon(Icons.category, color: Colors.grey),
                                const SizedBox(width: 8),
                                const Text('الفئة: '),
                                Text(
                                  service.categoryName!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],

                          // المزود
                          if (service.providerName != null) ...[
                            Row(
                              children: [
                                const Icon(Icons.person, color: Colors.grey),
                                const SizedBox(width: 8),
                                const Text('المزود: '),
                                Text(
                                  service.providerName!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],

                          // الحالة
                          Row(
                            children: [
                              Icon(
                                service.isActive
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: service.isActive
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              const SizedBox(width: 8),
                              const Text('الحالة: '),
                              Text(
                                service.isActive ? 'متاح' : 'غير متاح',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: service.isActive
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // أزرار الإجراءات
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // إضافة للمفضلة
                          },
                          icon: const Icon(Icons.favorite_border),
                          label: const Text('إضافة للمفضلة'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // الحجز
                          },
                          icon: const Icon(Icons.book_online),
                          label: const Text('حجز الآن'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // قسم التقييمات والتعليقات
            ServiceReviewsWidget(
              serviceId: service.id,
              serviceTitle: service.title,
            ),
          ],
        ),
      ),
    );
  }
}
