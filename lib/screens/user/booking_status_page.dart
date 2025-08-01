import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../../models/booking_model.dart';
import '../../routes/route_names.dart';
import '../../routes/route_arguments.dart';
import '../../utils/helpers.dart';

class BookingStatusPage extends StatefulWidget {
  const BookingStatusPage({super.key, required this.userId});
  final int userId;

  @override
  _BookingStatusPageState createState() => _BookingStatusPageState();
}

class _BookingStatusPageState extends State<BookingStatusPage> with TickerProviderStateMixin {
  List<Map<String, dynamic>> bookings = [];
  bool isLoading = false;
  String? error;
  String? selectedStatus;
  String searchQuery = '';

  // الحالات المتاحة للحجوزات
  final Map<String, String> statusOptions = {
    'pending': 'قيد المراجعة',
    'confirmed': 'مؤكد',
    'completed': 'مكتمل',
    'rejected': 'مرفوض',
    'cancelled': 'ملغي',
  };

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    loadBookings();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> loadBookings() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId != null) {
        // المستخدم مسجل دخول - جلب الطلبات من الخادم
        try {
          final results = await ApiService.getUserBookings(
            userId,
            status: selectedStatus,
          );

          if (results['success'] && results['data'] != null) {
            final data = results['data'] as List;
            setState(() {
              bookings = data.cast<Map<String, dynamic>>();
              isLoading = false;
            });
            _animationController.forward();
          } else {
            setState(() {
              bookings = [];
              isLoading = false;
              error = results['message'] ?? 'فشل في تحميل الطلبات';
            });
          }
        } catch (e) {
          setState(() {
            bookings = [];
            isLoading = false;
            error = 'خطأ في الاتصال: $e';
          });
        }
      } else {
        // المستخدم غير مسجل دخول - عرض بيانات تجريبية
        final demoBookings = [
          {
            'id': 1,
            'service_id': 1,
            'booking_date': '2025-08-15',
            'booking_time': '18:00',
            'notes': 'حفلة زفاف - 100 ضيف',
            'status': 'confirmed',
            'created_at': '2025-07-30 21:07:36',
            'service_name': 'قاعة الزين',
            'provider_name': 'قاعة الزين',
            'price': 500000.0,
            'service_image': 'hall1.jpg',
          },
          {
            'id': 2,
            'service_id': 2,
            'booking_date': '2025-08-20',
            'booking_time': '19:00',
            'notes': 'تصوير حفل زفاف',
            'status': 'pending',
            'created_at': '2025-07-30 21:07:36',
            'service_name': 'أضواء فوتو',
            'provider_name': 'أضواء فوتو',
            'price': 500000.0,
            'service_image': 'photo1.jpg',
          },
          {
            'id': 3,
            'service_id': 3,
            'booking_date': '2025-08-25',
            'booking_time': '20:00',
            'notes': 'حلويات للحفل',
            'status': 'completed',
            'created_at': '2025-07-30 21:07:36',
            'service_name': 'سونا كيك',
            'provider_name': 'سونا كيك',
            'price': 4000.0,
            'service_image': 'cake1.jpg',
          },
        ];

        setState(() {
          bookings = demoBookings;
          isLoading = false;
        });
        _animationController.forward();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white),
                const SizedBox(width: 8),
                const Text('عرض بيانات تجريبية للطلبات'),
              ],
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        bookings = [];
        isLoading = false;
        error = 'خطأ في تحميل الطلبات: $e';
      });
    }
  }

  List<Map<String, dynamic>> get filteredBookings {
    return bookings.where((booking) {
      final matchesSearch = searchQuery.isEmpty ||
          booking['service_name'].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
          booking['provider_name'].toString().toLowerCase().contains(searchQuery.toLowerCase());
      
      final matchesStatus = selectedStatus == null ||
          booking['status'] == selectedStatus;
      
      return matchesSearch && matchesStatus;
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'confirmed':
        return Icons.check_circle;
      case 'completed':
        return Icons.done_all;
      case 'rejected':
        return Icons.cancel;
      case 'cancelled':
        return Icons.block;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'طلباتي',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadBookings,
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط البحث والفلترة
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // حقل البحث
                TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'البحث في الطلبات...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // فلتر الحالات
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: statusOptions.length + 1, // +1 للكل
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        // خيار "الكل"
                        final isSelected = selectedStatus == null;
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: const Text('الكل'),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                selectedStatus = null;
                              });
                            },
                            backgroundColor: Colors.grey.shade100,
                            selectedColor: Colors.purple.shade100,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.purple.shade700 : Colors.grey.shade700,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        );
                      }
                      
                      final statusEntry = statusOptions.entries.elementAt(index - 1);
                      final statusKey = statusEntry.key;
                      final statusLabel = statusEntry.value;
                      final isSelected = selectedStatus == statusKey;
                      
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(statusLabel),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              selectedStatus = selected ? statusKey : null;
                            });
                          },
                          backgroundColor: Colors.grey.shade100,
                          selectedColor: _getStatusColor(statusKey).withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: isSelected ? _getStatusColor(statusKey) : Colors.grey.shade700,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // إحصائيات سريعة
          if (bookings.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.bookmark, color: Colors.purple.shade600, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${filteredBookings.length} طلب',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'إجمالي: ${bookings.length}',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

          // قائمة الطلبات
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : error != null
                    ? _buildErrorWidget()
                    : filteredBookings.isEmpty
                        ? _buildEmptyWidget()
                        : _buildBookingsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsList() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredBookings.length,
        itemBuilder: (context, index) {
          final booking = filteredBookings[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: _buildBookingCard(booking),
          );
        },
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final status = booking['status'] as String;
    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);
    final statusLabel = statusOptions[status] ?? 'غير محدد';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // صورة الخدمة
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade200,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: booking['service_image'] != null
                        ? Image.network(
                            booking['service_image'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade300,
                                child: const Icon(
                                  Icons.image,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey.shade300,
                            child: const Icon(
                              Icons.image,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // تفاصيل الطلب
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking['service_name'] ?? 'خدمة غير محددة',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 4),
                      
                      Text(
                        booking['provider_name'] ?? 'مزود غير محدد',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // حالة الطلب
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: statusColor, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // تفاصيل إضافية
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.grey.shade600, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${booking['booking_date']}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                Icon(Icons.access_time, color: Colors.grey.shade600, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${booking['booking_time']}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                
                const Spacer(),
                
                Text(
                  '${booking['price']?.toStringAsFixed(0) ?? '0'} ريال',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            
            if (booking['notes'] != null && booking['notes'].toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.note, color: Colors.grey.shade600, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        booking['notes'],
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 12),
            
            // أزرار الإجراءات
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // عرض تفاصيل الطلب
                      _showBookingDetails(booking);
                    },
                    icon: const Icon(Icons.info_outline, size: 16),
                    label: const Text('التفاصيل'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.purple.shade600,
                      side: BorderSide(color: Colors.purple.shade600),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                if (status == 'confirmed')
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // إلغاء الطلب
                        _cancelBooking(booking);
                      },
                      icon: const Icon(Icons.cancel, size: 16),
                      label: const Text('إلغاء'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد طلبات',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ بحجز الخدمات التي تحتاجها',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, RouteNames.userHome);
            },
            icon: const Icon(Icons.explore),
            label: const Text('استكشف الخدمات'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'حدث خطأ',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error ?? 'فشل في تحميل الطلبات',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: loadBookings,
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingDetails(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تفاصيل الطلب #${booking['id']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('الخدمة', booking['service_name'] ?? 'غير محدد'),
            _buildDetailRow('المزود', booking['provider_name'] ?? 'غير محدد'),
            _buildDetailRow('التاريخ', booking['booking_date'] ?? 'غير محدد'),
            _buildDetailRow('الوقت', booking['booking_time'] ?? 'غير محدد'),
            _buildDetailRow('السعر', '${booking['price']?.toStringAsFixed(0) ?? '0'} ريال'),
            _buildDetailRow('الحالة', statusOptions[booking['status']] ?? 'غير محدد'),
            if (booking['notes'] != null && booking['notes'].toString().isNotEmpty)
              _buildDetailRow('الملاحظات', booking['notes']),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _cancelBooking(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إلغاء الطلب'),
        content: Text('هل أنت متأكد من إلغاء طلب ${booking['service_name']}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // هنا يمكن إضافة منطق إلغاء الطلب
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إلغاء الطلب بنجاح'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('تأكيد الإلغاء'),
          ),
        ],
      ),
    );
  }
}
