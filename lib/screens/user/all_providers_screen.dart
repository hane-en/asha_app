import 'package:flutter/material.dart';
import '../../services/unified_data_service.dart';
import '../../utils/constants.dart';

class AllProvidersScreen extends StatefulWidget {
  final int? categoryId;
  final String? categoryName;

  const AllProvidersScreen({
    Key? key,
    this.categoryId,
    this.categoryName,
  }) : super(key: key);

  @override
  State<AllProvidersScreen> createState() => _AllProvidersScreenState();
}

class _AllProvidersScreenState extends State<AllProvidersScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _data;
  String? _error;
  String _searchQuery = '';
  String _sortBy = 'rating';
  String _sortOrder = 'DESC';
  int _currentPage = 1;
  int _itemsPerPage = 20;
  bool _hasMoreData = true;
  List<Map<String, dynamic>> _providers = [];
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

  Future<void> _loadProviders({bool refresh = false}) async {
    try {
      if (refresh) {
        setState(() {
          _isLoading = true;
          _currentPage = 1;
          _providers = [];
        });
      }

      final response = await UnifiedDataService.getAllProviders(
        categoryId: widget.categoryId,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
        limit: _itemsPerPage,
        offset: (_currentPage - 1) * _itemsPerPage,
      );

      if (response['success']) {
        final newProviders = List<Map<String, dynamic>>.from(
          response['data']['providers'] ?? [],
        );

        setState(() {
          if (refresh) {
            _providers = newProviders;
          } else {
            _providers.addAll(newProviders);
          }
          _data = response['data'];
          _hasMoreData = response['data']['pagination']['has_next'] ?? false;
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

  void _searchProviders(String query) {
    setState(() {
      _searchQuery = query;
    });
    _loadProviders(refresh: true);
  }

  void _changeSort(String sortBy) {
    setState(() {
      _sortBy = sortBy;
    });
    _loadProviders(refresh: true);
  }

  void _loadMoreData() {
    if (!_isLoading && _hasMoreData) {
      setState(() {
        _currentPage++;
      });
      _loadProviders();
    }
  }

  String _getSortText() {
    switch (_sortBy) {
      case 'rating':
        return 'حسب التقييم';
      case 'name':
        return 'حسب الاسم';
      case 'services':
        return 'حسب الخدمات';
      case 'price':
        return 'حسب السعر';
      case 'bookings':
        return 'حسب الحجوزات';
      case 'reviews':
        return 'حسب المراجعات';
      case 'created':
        return 'حسب التاريخ';
      default:
        return 'ترتيب';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.categoryName != null
              ? 'مزودي الخدمات - ${widget.categoryName}'
              : 'جميع مزودي الخدمات',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortDialog,
            tooltip: 'ترتيب المزودين',
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط البحث
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _searchProviders,
              decoration: InputDecoration(
                hintText: 'البحث في المزودين...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _searchProviders('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),

          // إحصائيات سريعة
          if (_data != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.people, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${_data!['total_providers']} مزود',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  if (_searchQuery.isNotEmpty)
                    Text(
                      'نتائج البحث: ${_providers.length}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
          ],

          // قائمة المزودين
          Expanded(
            child: _isLoading && _providers.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _error != null && _providers.isEmpty
                    ? _buildErrorWidget()
                    : _providers.isEmpty
                        ? _buildEmptyWidget()
                        : RefreshIndicator(
                            onRefresh: () => _loadProviders(refresh: true),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _providers.length + (_hasMoreData ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == _providers.length) {
                                  // زر تحميل المزيد
                                  return _buildLoadMoreButton();
                                }
                                return _buildProviderCard(_providers[index]);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCard(Map<String, dynamic> provider) {
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
            '/provider-services',
            arguments: {
              'provider_id': provider['id'],
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
                            errorBuilder: (context, error, stackTrace) {
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
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                            padding: EdgeInsets.only(left: 8),
                            child: Icon(
                              Icons.verified,
                              color: Colors.blue,
                              size: 18,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // الفئات
                    if (provider['categories'] != null && provider['categories'].isNotEmpty)
                      Text(
                        provider['categories'].join(', '),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                    const SizedBox(height: 4),

                    // التقييم
                    if (provider['avg_service_rating'] != null && provider['avg_service_rating'] > 0)
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            return Icon(
                              index < provider['avg_service_rating']
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.orange,
                              size: 14,
                            );
                          }),
                          const SizedBox(width: 4),
                          Text(
                            '${provider['avg_service_rating'].toStringAsFixed(1)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${provider['total_reviews_count']} مراجعة)',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 4),

                    // معلومات إضافية
                    Row(
                      children: [
                        Icon(Icons.work, size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${provider['services_count']} خدمة',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.event, size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${provider['total_bookings']} حجز',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 10,
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
                  if (provider['avg_price'] != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ElevatedButton(
          onPressed: _hasMoreData ? _loadMoreData : null,
          child: Text(_hasMoreData ? 'تحميل المزيد' : 'لا توجد بيانات أكثر'),
        ),
      ),
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
            _error!,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _loadProviders(refresh: true),
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? 'لا توجد نتائج للبحث'
                : 'لا يوجد مزودي خدمات',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'جرب البحث بكلمات مختلفة'
                : 'جرب البحث في فئات أخرى',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
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
                _loadProviders(refresh: true);
              },
            ),
            RadioListTile<String>(
              title: const Text('حسب الاسم'),
              value: 'name',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                });
                Navigator.pop(context);
                _loadProviders(refresh: true);
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
                _loadProviders(refresh: true);
              },
            ),
            RadioListTile<String>(
              title: const Text('حسب السعر'),
              value: 'price',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                });
                Navigator.pop(context);
                _loadProviders(refresh: true);
              },
            ),
            RadioListTile<String>(
              title: const Text('حسب عدد الحجوزات'),
              value: 'bookings',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                });
                Navigator.pop(context);
                _loadProviders(refresh: true);
              },
            ),
          ],
        ),
      ),
    );
  }
} 