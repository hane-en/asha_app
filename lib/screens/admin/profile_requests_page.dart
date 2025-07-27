import 'package:flutter/material.dart';
import '../../services/admin_service.dart';

class ProfileRequestsPage extends StatefulWidget {
  const ProfileRequestsPage({super.key});

  @override
  State<ProfileRequestsPage> createState() => _ProfileRequestsPageState();
}

class _ProfileRequestsPageState extends State<ProfileRequestsPage> {
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = false;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _requests = [];
        _hasMore = true;
      });
    }

    if (!_hasMore || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      final response = await AdminService.getProfileRequests(_currentPage);

      if (response['success'] == true) {
        final newRequests = List<Map<String, dynamic>>.from(response['data']);
        final pagination = response['pagination'];

        setState(() {
          if (refresh) {
            _requests = newRequests;
          } else {
            _requests.addAll(newRequests);
          }
          _totalPages = pagination['total_pages'] ?? 1;
          _hasMore = _currentPage < _totalPages;
          _currentPage++;
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ: ${response['message']}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ في تحميل البيانات: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRequest(int requestId, String action) async {
    final adminNotes = await _showNotesDialog(action);
    if (adminNotes == null) return; // User cancelled

    try {
      final response = await AdminService.handleProfileRequest(
        requestId,
        action,
        adminNotes,
      );

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']),
            backgroundColor: Colors.green,
          ),
        );
        _loadRequests(refresh: true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: ${response['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<String?> _showNotesDialog(String action) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(action == 'approve' ? 'ملاحظات الموافقة' : 'سبب الرفض'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'اكتب ملاحظاتك هنا (اختياري)',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'approved':
        return 'تمت الموافقة';
      case 'rejected':
        return 'مرفوض';
      default:
        return 'غير معروف';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'طلبات تحديث البيانات',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadRequests(refresh: true),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadRequests(refresh: true),
        child: _requests.isEmpty && !_isLoading
            ? const Center(
                child: Text(
                  'لا توجد طلبات تحديث بيانات',
                  style: TextStyle(fontSize: 16),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _requests.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _requests.length) {
                    return _buildLoadMoreButton();
                  }

                  final request = _requests[index];
                  return _buildRequestCard(request);
                },
              ),
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    final status = request['status'] ?? 'pending';
    final isPending = status == 'pending';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ExpansionTile(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: _getStatusColor(status),
              child: Text(
                request['name']?[0]?.toUpperCase() ?? '?',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request['name'] ?? 'غير محدد',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    request['email'] ?? 'غير محدد',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(status),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getStatusText(status),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
        subtitle: Text(
          'تاريخ الطلب: ${request['created_at'] ?? 'غير محدد'}',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildComparisonRow(
                  'الاسم',
                  request['current_name'],
                  request['name'],
                ),
                _buildComparisonRow(
                  'البريد الإلكتروني',
                  request['current_email'],
                  request['email'],
                ),
                _buildComparisonRow(
                  'رقم الهاتف',
                  request['current_phone'],
                  request['phone'],
                ),
                if (request['bio'] != null)
                  _buildInfoRow('نبذة شخصية', request['bio']),
                if (request['website'] != null)
                  _buildInfoRow('الموقع الإلكتروني', request['website']),
                if (request['address'] != null)
                  _buildInfoRow('العنوان', request['address']),
                if (request['city'] != null)
                  _buildInfoRow('المدينة', request['city']),

                if (isPending) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              _handleRequest(request['id'], 'approve'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('موافقة'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              _handleRequest(request['id'], 'reject'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('رفض'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(
    String label,
    String? currentValue,
    String? newValue,
  ) {
    final hasChanged = currentValue != newValue;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasChanged) ...[
                  Text(
                    'الحالي: ${currentValue ?? 'غير محدد'}',
                    style: TextStyle(
                      color: Colors.red[700],
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  Text(
                    'الجديد: ${newValue ?? 'غير محدد'}',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ] else ...[
                  Text(currentValue ?? 'غير محدد'),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_hasMore) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ElevatedButton(
          onPressed: () => _loadRequests(),
          child: const Text('تحميل المزيد'),
        ),
      ),
    );
  }
}
