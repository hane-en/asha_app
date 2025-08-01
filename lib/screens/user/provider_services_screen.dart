import 'package:flutter/material.dart';
import '../../services/unified_data_service.dart';
import '../../utils/constants.dart';
import '../../routes/route_names.dart';

class ProviderServicesScreen extends StatefulWidget {
  final int providerId;
  final String providerName;

  const ProviderServicesScreen({
    Key? key,
    required this.providerId,
    required this.providerName,
  }) : super(key: key);

  @override
  State<ProviderServicesScreen> createState() => _ProviderServicesScreenState();
}

class _ProviderServicesScreenState extends State<ProviderServicesScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _data;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProviderServices();
  }

  Future<void> _loadProviderServices() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await UnifiedDataService.getProviderServices(
        widget.providerId,
      );

      if (response['success']) {
        setState(() {
          _data = response['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response['message'] ?? 'فشل في تحميل البيانات';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'خطأ في الاتصال: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'خدمات ${widget.providerName}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadProviderServices,
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            )
          : _data == null ||
                _data!['provider'] == null ||
                _data!['statistics'] == null
          ? const Center(child: Text('لا توجد بيانات'))
          : RefreshIndicator(
              onRefresh: _loadProviderServices,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // معلومات المزود
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // صورة المزود
                            CircleAvatar(
                              radius: 40,
                              backgroundImage:
                                  _data!['provider']['profile_image'] != null &&
                                      _data!['provider']['profile_image']
                                          .toString()
                                          .isNotEmpty
                                  ? NetworkImage(
                                      _data!['provider']['profile_image'],
                                    )
                                  : null,
                              child: _data!['provider']['profile_image'] == null
                                  ? Text(
                                      (_data!['provider']['name'] ?? 'م')[0],
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),

                            const SizedBox(width: 16),

                            // معلومات المزود
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        _data!['provider']['name'] ??
                                            'مزود غير محدد',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (_data!['provider']['is_verified'] ==
                                          1)
                                        const Padding(
                                          padding: EdgeInsets.only(left: 8),
                                          child: Icon(
                                            Icons.verified,
                                            color: Colors.blue,
                                            size: 20,
                                          ),
                                        ),
                                    ],
                                  ),

                                  const SizedBox(height: 4),

                                  if (_data!['provider']['phone'] != null &&
                                      _data!['provider']['phone']
                                          .toString()
                                          .isNotEmpty)
                                    Text(
                                      'الهاتف: ${_data!['provider']['phone']}',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),

                                  const SizedBox(height: 4),

                                  if (_data!['statistics']['overall_rating'] !=
                                      null)
                                    Row(
                                      children: [
                                        ...List.generate(5, (index) {
                                          final rating =
                                              _data!['statistics']['overall_rating'] ??
                                              0.0;
                                          return Icon(
                                            index < rating
                                                ? Icons.star
                                                : Icons.star_border,
                                            color: Colors.orange,
                                            size: 16,
                                          );
                                        }),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${_data!['statistics']['overall_rating'] ?? 0.0}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // إحصائيات المزود
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              'الخدمات',
                              '${_data!['statistics']['total_services'] ?? 0}',
                              Icons.work,
                            ),
                            _buildStatItem(
                              'الحجوزات',
                              '${_data!['statistics']['total_bookings'] ?? 0}',
                              Icons.calendar_today,
                            ),
                            if (_data!['statistics']['avg_service_price'] !=
                                null)
                              _buildStatItem(
                                'متوسط السعر',
                                '${_data!['statistics']['avg_service_price'] ?? 0} ريال',
                                Icons.attach_money,
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // قائمة الخدمات
                    if (_data!['services'] != null &&
                        (_data!['services'] as List).isNotEmpty) ...[
                      const Text(
                        'الخدمات المتاحة',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      ...(_data!['services'] as List).map((service) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                RouteNames.offerDetails,
                                arguments: {
                                  'offer_id': service['id'],
                                  'offer_title': service['name'],
                                },
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // صورة الخدمة
                                  if (service['image'] != null &&
                                      service['image'].toString().isNotEmpty)
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                          image: NetworkImage(service['image']),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )
                                  else
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.grey[200],
                                      ),
                                      child: const Icon(
                                        Icons.work,
                                        size: 32,
                                        color: Colors.grey,
                                      ),
                                    ),

                                  const SizedBox(width: 16),

                                  // معلومات الخدمة
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          service['name'] ?? 'خدمة غير محددة',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        const SizedBox(height: 4),

                                        if (service['category_name'] != null &&
                                            service['category_name']
                                                .toString()
                                                .isNotEmpty)
                                          Text(
                                            service['category_name'],
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                          ),

                                        const SizedBox(height: 4),

                                        if (service['avg_rating'] != null &&
                                            service['avg_rating'] > 0)
                                          Row(
                                            children: [
                                              ...List.generate(5, (index) {
                                                final rating =
                                                    service['avg_rating'] ??
                                                    0.0;
                                                return Icon(
                                                  index < rating
                                                      ? Icons.star
                                                      : Icons.star_border,
                                                  color: Colors.orange,
                                                  size: 14,
                                                );
                                              }),
                                              const SizedBox(width: 8),
                                              Text(
                                                '${service['avg_rating'] ?? 0.0} (${service['reviews_count'] ?? 0} تقييم)',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),

                                  // السعر
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${service['price'] ?? 0} ريال',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pushNamed(
                                            context,
                                            RouteNames.booking,
                                            arguments: {
                                              'id': service['id'] ?? 0,
                                              'title':
                                                  service['name'] ??
                                                  'خدمة غير محددة',
                                              'price': service['price'] ?? 0,
                                              'provider_name':
                                                  _data!['provider']['name'] ??
                                                  'مزود غير محدد',
                                              'description':
                                                  service['description'] ?? '',
                                            },
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: primaryColor,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                        ),
                                        child: const Text('حجز'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ] else ...[
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.work_outline,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'لا توجد خدمات متاحة',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: primaryColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
