import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/service_category_model.dart';
import '../../services/service_category_service.dart';
import 'edit_service_category_page.dart';

class ServiceCategoryDetailsPage extends StatefulWidget {
  final int categoryId;
  final String serviceTitle;

  const ServiceCategoryDetailsPage({
    Key? key,
    required this.categoryId,
    required this.serviceTitle,
  }) : super(key: key);

  @override
  State<ServiceCategoryDetailsPage> createState() =>
      _ServiceCategoryDetailsPageState();
}

class _ServiceCategoryDetailsPageState
    extends State<ServiceCategoryDetailsPage> {
  bool _isLoading = true;
  ServiceCategory? _category;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCategory();
  }

  Future<void> _loadCategory() async {
    try {
      final category = await ServiceCategoryService.getServiceCategory(
        widget.categoryId,
      );

      if (category != null) {
        setState(() {
          _category = category;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'فئة الخدمة غير موجودة';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'خطأ في تحميل البيانات: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteCategory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف فئة الخدمة "${_category?.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await ServiceCategoryService.deleteServiceCategory(
          widget.categoryId,
        );

        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('تم حذف فئة الخدمة "${_category?.name}" بنجاح'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(true); // إرجاع true للإشارة إلى الحذف
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('فشل في حذف فئة الخدمة'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل فئة الخدمة'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (_category != null) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editCategory(),
              tooltip: 'تعديل',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteCategory,
              tooltip: 'حذف',
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadCategory,
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            )
          : _category == null
          ? const Center(child: Text('فئة الخدمة غير موجودة'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // صورة فئة الخدمة
                  if (_category!.image.isNotEmpty)
                    Card(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: _category!.image,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: const Icon(Icons.error),
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // معلومات فئة الخدمة
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.category, color: Colors.blue),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _category!.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _category!.isActive
                                      ? Colors.green
                                      : Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _category!.isActive ? 'نشط' : 'غير نشط',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _category!.description,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),

                          // السعر والمدة
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoCard(
                                  'السعر',
                                  '${_category!.price} ريال',
                                  Icons.attach_money,
                                  Colors.green,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildInfoCard(
                                  'المدة',
                                  _category!.duration ?? 'غير محدد',
                                  Icons.access_time,
                                  Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // المعلومات الإضافية
                  if (_category!.size != null ||
                      _category!.dimensions != null ||
                      _category!.location != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'المعلومات الإضافية',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (_category!.size != null) ...[
                              _buildInfoRow('الحجم', _category!.size!),
                              const SizedBox(height: 8),
                            ],
                            if (_category!.dimensions != null) ...[
                              _buildInfoRow('الأبعاد', _category!.dimensions!),
                              const SizedBox(height: 8),
                            ],
                            if (_category!.location != null) ...[
                              _buildInfoRow('الموقع', _category!.location!),
                              const SizedBox(height: 8),
                            ],
                            _buildInfoRow(
                              'الكمية',
                              _category!.quantity.toString(),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // المواد والميزات
                  if (_category!.materials != null ||
                      _category!.additionalFeatures != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'التفاصيل',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (_category!.materials != null) ...[
                              _buildInfoRow(
                                'المواد المستخدمة',
                                _category!.materials!,
                              ),
                              const SizedBox(height: 8),
                            ],
                            if (_category!.additionalFeatures != null) ...[
                              _buildInfoRow(
                                'ميزات إضافية',
                                _category!.additionalFeatures!,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // معلومات الخدمة
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'معلومات الخدمة',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow('اسم الخدمة', widget.serviceTitle),
                          const SizedBox(height: 8),
                          _buildInfoRow('تاريخ الإنشاء', _category!.createdAt),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: color),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
      ],
    );
  }

  void _editCategory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditServiceCategoryPage(
          categoryId: widget.categoryId,
          serviceTitle: widget.serviceTitle,
        ),
      ),
    ).then((updated) {
      if (updated == true) {
        _loadCategory(); // إعادة تحميل البيانات
      }
    });
  }
}
