import 'package:flutter/material.dart';
import '../../models/category_model.dart';
import '../../services/unified_data_service.dart';
import '../../utils/constants.dart';
import '../../routes/route_names.dart';

class ProvidersByCategoryScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const ProvidersByCategoryScreen({
    Key? key,
    required this.categoryId,
    required this.categoryName,
  }) : super(key: key);

  @override
  State<ProvidersByCategoryScreen> createState() =>
      _ProvidersByCategoryScreenState();
}

class _ProvidersByCategoryScreenState extends State<ProvidersByCategoryScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _data;
  String? _error;
  String _sortBy = 'rating'; // rating, services, price
  List<Map<String, dynamic>> _filteredProviders = [];
  List<Map<String, dynamic>> _allProviders = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProviders() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await UnifiedDataService.getProvidersByCategory(
        widget.categoryId,
      );

      if (response['success']) {
        setState(() {
          _data = response['data'];
          _allProviders = List<Map<String, dynamic>>.from(
            _data!['providers'] ?? [],
          );
          _filteredProviders = _allProviders;
          _isLoading = false;
        });
        _sortProviders();
      } else {
        setState(() {
          _error = response['message'] ?? 'فشل في تحميل البيانات';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading providers: $e'); // Debug info
      String errorMessage = 'خطأ في الاتصال بالشبكة';

      if (e.toString().contains('SocketException')) {
        errorMessage = 'لا يمكن الاتصال بالخادم. تأكد من اتصالك بالإنترنت';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'انتهت مهلة الاتصال. حاول مرة أخرى';
      } else if (e.toString().contains('HttpException')) {
        errorMessage = 'خطأ في الخادم. حاول مرة أخرى لاحقاً';
      }

      setState(() {
        _error = errorMessage;
        _isLoading = false;
      });
    }
  }

  void _sortProviders() {
    if (_filteredProviders.isEmpty) return;

    switch (_sortBy) {
      case 'rating':
        _filteredProviders.sort(
          (a, b) => (b['avg_rating'] ?? 0.0).compareTo(a['avg_rating'] ?? 0.0),
        );
        break;
      case 'services':
        _filteredProviders.sort(
          (a, b) =>
              (b['services_count'] ?? 0).compareTo(a['services_count'] ?? 0),
        );
        break;
      case 'price':
        _filteredProviders.sort(
          (a, b) => (a['avg_price'] ?? 0.0).compareTo(b['avg_price'] ?? 0.0),
        );
        break;
    }
    setState(() {});
  }

  void _searchProviders(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredProviders = _allProviders;
      });
    } else {
      setState(() {
        _filteredProviders = _allProviders.where((provider) {
          return provider['name'].toString().toLowerCase().contains(
            query.toLowerCase(),
          );
        }).toList();
      });
    }
    _sortProviders();
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ترتيب المزودين'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('حسب التقييم'),
              value: 'rating',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                });
                Navigator.pop(context);
                _sortProviders();
              },
            ),
            RadioListTile<String>(
              title: const Text('حسب عدد الخدمات'),
              value: 'services',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                });
                Navigator.pop(context);
                _sortProviders();
              },
            ),
            RadioListTile<String>(
              title: const Text('حسب السعر (الأقل أولاً)'),
              value: 'price',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                });
                Navigator.pop(context);
                _sortProviders();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'مزودي الخدمات - ${widget.categoryName}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_filteredProviders.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.sort),
              onPressed: _showSortDialog,
              tooltip: 'ترتيب المزودين',
            ),
        ],
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
                  const SizedBox(height: 8),
                  Text(
                    'تأكد من اتصالك بالإنترنت وأن الخادم يعمل',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'معلومات التشخيص:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'الفئة: ${widget.categoryName}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'معرف الفئة: ${widget.categoryId}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'الوقت: ${DateTime.now().toString().substring(0, 19)}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _loadProviders,
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('إعادة المحاولة'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back, size: 16),
                        label: const Text('العودة'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          : _data == null
          ? const Center(child: Text('لا توجد بيانات'))
          : RefreshIndicator(
              onRefresh: _loadProviders,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // معلومات الفئة
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryColor, primaryColor.withOpacity(0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.category,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    widget.categoryName,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.people,
                                  color: Colors.white70,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'عدد المزودين: ${_filteredProviders.length}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            if (_data != null &&
                                _data!['category_stats'] != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.work,
                                    color: Colors.white70,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'إجمالي الخدمات: ${_data!['category_stats']['total_services']}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.white70,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'متوسط التقييم: ${_data!['category_stats']['avg_rating'].toStringAsFixed(1)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                              if (_data!['category_stats']['price_range']['min'] >
                                  0) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.attach_money,
                                      color: Colors.white70,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'نطاق الأسعار: ${_data!['category_stats']['price_range']['min'].toStringAsFixed(0)} - ${_data!['category_stats']['price_range']['max'].toStringAsFixed(0)} ريال',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // قائمة المزودين
                    if (_filteredProviders.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'مزودي الخدمات',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _showSortDialog,
                            icon: const Icon(Icons.sort, size: 16),
                            label: Text(_getSortText()),
                            style: TextButton.styleFrom(
                              foregroundColor: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // حقل البحث
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: _searchProviders,
                          decoration: InputDecoration(
                            hintText: 'البحث في المزودين...',
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.grey,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.clear,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      _searchProviders('');
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // عداد النتائج
                      if (_searchController.text.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            'تم العثور على ${_filteredProviders.length} مزود',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),

                      ..._filteredProviders.map((provider) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                RouteNames.providerServices,
                                arguments: {
                                  'provider_id': provider['id'] is int
                                      ? provider['id']
                                      : int.tryParse(
                                              provider['id'].toString(),
                                            ) ??
                                            0,
                                  'provider_name': provider['name'],
                                },
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // صورة المزود
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: primaryColor.withOpacity(0.1),
                                        ),
                                        child: provider['profile_image'] != null
                                            ? Image.network(
                                                provider['profile_image'],
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return Icon(
                                                        Icons.person,
                                                        size: 30,
                                                        color: primaryColor,
                                                      );
                                                    },
                                              )
                                            : Icon(
                                                Icons.person,
                                                size: 30,
                                                color: primaryColor,
                                              ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 16),

                                  // معلومات المزود
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                provider['name'],
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (provider['is_verified'] == 1)
                                              const Padding(
                                                padding: EdgeInsets.only(
                                                  left: 8,
                                                ),
                                                child: Icon(
                                                  Icons.verified,
                                                  color: Colors.blue,
                                                  size: 18,
                                                ),
                                              ),
                                          ],
                                        ),

                                        const SizedBox(height: 4),

                                        Row(
                                          children: [
                                            Icon(
                                              Icons.work,
                                              size: 14,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${provider['services_count']} خدمة',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 4),

                                        if (provider['avg_rating'] != null &&
                                            provider['avg_rating'] > 0)
                                          Row(
                                            children: [
                                              ...List.generate(5, (index) {
                                                return Icon(
                                                  index < provider['avg_rating']
                                                      ? Icons.star
                                                      : Icons.star_border,
                                                  color: Colors.orange,
                                                  size: 14,
                                                );
                                              }),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${provider['avg_rating'].toStringAsFixed(1)}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),

                                  // معلومات إضافية
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      if (provider['avg_price'] != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withOpacity(
                                              0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Colors.green.withOpacity(
                                                0.3,
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            '${provider['avg_price'].toStringAsFixed(0)} ريال',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ),

                                      const SizedBox(height: 4),

                                      if (provider['total_bookings'] != null)
                                        Text(
                                          '${provider['total_bookings']} حجز',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey[500],
                                          ),
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
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isNotEmpty
                                  ? 'لا توجد نتائج للبحث'
                                  : 'لا يوجد مزودي خدمات في هذه الفئة',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchController.text.isNotEmpty
                                  ? 'جرب البحث بكلمات مختلفة'
                                  : 'جرب البحث في فئات أخرى أو عد لاحقاً',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  String _getSortText() {
    switch (_sortBy) {
      case 'rating':
        return 'حسب التقييم';
      case 'services':
        return 'حسب الخدمات';
      case 'price':
        return 'حسب السعر';
      default:
        return 'ترتيب';
    }
  }
}
