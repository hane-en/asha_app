import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/service_model.dart';
import '../../models/service_category_model.dart';
import '../../services/service_category_service.dart';
import '../../widgets/service_category_card.dart';
import '../../utils/helpers.dart';

class ServiceDetailsPage extends StatefulWidget {
  final Service service;

  const ServiceDetailsPage({Key? key, required this.service}) : super(key: key);

  @override
  State<ServiceDetailsPage> createState() => _ServiceDetailsPageState();
}

class _ServiceDetailsPageState extends State<ServiceDetailsPage> {
  List<ServiceCategory> _categories = [];
  Map<String, dynamic>? _serviceInfo;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadServiceCategories();
  }

  Future<void> _loadServiceCategories() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await ServiceCategoryService.getServiceCategories(
        widget.service.id,
      );

      if (response.success) {
        setState(() {
          _categories = response.data;
          _serviceInfo = response.serviceInfo;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'خطأ في تحميل فئات الخدمة: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.service.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorWidget()
          : _buildContent(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadServiceCategories,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildServiceHeader(),
          const SizedBox(height: 16),
          _buildServiceInfo(),
          const SizedBox(height: 24),
          _buildCategoriesSection(),
        ],
      ),
    );
  }

  Widget _buildServiceHeader() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue, Colors.blue.shade700],
        ),
      ),
      child: Stack(
        children: [
          // صورة الخدمة
          if (widget.service.images.isNotEmpty)
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: widget.service.images.first,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 64, color: Colors.grey),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.error, size: 64, color: Colors.grey),
                ),
              ),
            ),
          // طبقة شفافة
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
          // معلومات الخدمة
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.service.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      widget.service.city,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${widget.service.price.toStringAsFixed(0)} ريال',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
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
    );
  }

  Widget _buildServiceInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'وصف الخدمة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.service.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          if (_serviceInfo != null) ...[
            _buildInfoRow(
              'المزود',
              _serviceInfo!['provider_name'] ?? 'غير محدد',
            ),
            _buildInfoRow(
              'الفئة',
              _serviceInfo!['category_name'] ?? 'غير محدد',
            ),
            _buildInfoRow(
              'الموقع',
              _serviceInfo!['service_city'] ?? widget.service.city,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.category, color: Colors.blue, size: 24),
              const SizedBox(width: 8),
              Text(
                'فئات الخدمة',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const Spacer(),
              Text(
                '${_categories.length} فئة',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_categories.isEmpty)
            _buildEmptyCategories()
          else
            _buildCategoriesList(),
        ],
      ),
    );
  }

  Widget _buildEmptyCategories() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.category_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'لا توجد فئات خدمة متاحة حالياً',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ServiceCategoryCard(
            category: category,
            onTap: () => _onCategoryTap(category),
          ),
        );
      },
    );
  }

  void _onCategoryTap(ServiceCategory category) {
    // يمكن إضافة منطق إضافي هنا مثل الانتقال إلى صفحة الحجز
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(category.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('السعر: ${category.price.toStringAsFixed(0)} ريال'),
            if (category.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('الوصف: ${category.description}'),
            ],
            if (category.duration != null) ...[
              const SizedBox(height: 8),
              Text('المدة: ${category.duration}'),
            ],
            if (category.materials != null) ...[
              const SizedBox(height: 8),
              Text('المواد: ${category.materials}'),
            ],
            if (category.additionalFeatures != null) ...[
              const SizedBox(height: 8),
              Text('ميزات إضافية: ${category.additionalFeatures}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _bookService(category);
            },
            child: const Text('حجز الخدمة'),
          ),
        ],
      ),
    );
  }

  void _bookService(ServiceCategory category) {
    // هنا يمكن الانتقال إلى صفحة الحجز
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('سيتم إضافة صفحة الحجز قريباً'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
