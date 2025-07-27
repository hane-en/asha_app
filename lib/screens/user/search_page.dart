import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/api_service.dart';
import '../../models/service_model.dart';
import '../../widgets/service_card.dart';
import '../../routes/route_names.dart';
import '../../routes/route_arguments.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final RangeValues _priceRange = const RangeValues(0, 10000);
  RangeValues _currentPriceRange = const RangeValues(0, 10000);

  List<Service> _services = [];
  List<Map<String, dynamic>> _categories = [];
  Map<String, dynamic>? _selectedCategory;
  String _sortBy = 'created_at';
  String _sortOrder = 'DESC';
  String _searchType = 'category'; // category, price, distance
  String _searchStep = 'category'; // category, criteria
  double? _userLat;
  double? _userLng;
  bool _isLoading = false;
  bool _isLocationEnabled = false;
  bool _showFilters = false;
  bool _showPriceRange = false;
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _checkLocationPermission();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await ApiService.getCategories();
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  Future<void> _checkLocationPermission() async {
    try {
      var serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLocationEnabled = false;
        });
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLocationEnabled = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLocationEnabled = false;
        });
        return;
      }

      setState(() {
        _isLocationEnabled = true;
      });

      // جلب الموقع الحالي
      await _getCurrentLocation();
    } catch (e) {
      print('Error checking location permission: $e');
      setState(() {
        _isLocationEnabled = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      var position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _userLat = position.latitude;
        _userLng = position.longitude;
      });
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  Future<void> _navigateToFavorites() async {
    Navigator.pushReplacementNamed(context, RouteNames.favorites);
  }

  Future<void> _navigateToBookings() async {
    Navigator.pushReplacementNamed(context, RouteNames.bookingStatus);
  }

  Future<void> _performSearch() async {
    // إذا كان البحث في خطوة اختيار الفئة، لا تنفذ البحث
    if (_searchStep == 'category') {
      return;
    }

    // إذا لم يتم اختيار فئة، لا تنفذ البحث
    if (_selectedCategory == null) {
      return;
    }

    // إذا كان البحث من نوع "الأقرب" ولم يتم تفعيل الموقع
    if (_searchType == 'distance' && !_isLocationEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تفعيل GPS للبحث عن الأقرب')),
      );
      return;
    }

    // إذا كان البحث من نوع "السعر الأنسب" ولم يتم تحديد نطاق السعر
    if (_searchType == 'price' &&
        (_minPriceController.text.isEmpty ||
            _maxPriceController.text.isEmpty)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('يرجى تحديد نطاق السعر')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // تطبيق فلاتر حسب نوع البحث
      double? minPrice;
      double? maxPrice;

      if (_searchType == 'price') {
        // استخدام نطاق السعر المخصص
        minPrice = double.tryParse(_minPriceController.text) ?? 0;
        maxPrice = double.tryParse(_maxPriceController.text) ?? 10000;
      } else {
        minPrice = _currentPriceRange.start;
        maxPrice = _currentPriceRange.end;
      }

      // تحويل category_id إلى int
      int? categoryId;
      if (_selectedCategory?['id'] != null) {
        categoryId = int.tryParse(_selectedCategory!['id'].toString());
      }

      final result = await ApiService.advancedSearch(
        query: _searchController.text.trim().isNotEmpty
            ? _searchController.text.trim()
            : null,
        categoryId: categoryId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        userLat: _userLat,
        userLng: _userLng,
        maxDistance: _isLocationEnabled ? 50.0 : null,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
      );

      setState(() {
        _services = result['services'] ?? [];
        _isLoading = false;
      });

      // عرض رسالة إذا لم توجد نتائج
      if (_services.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لا توجد خدمات تطابق معايير البحث'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ في البحث: $e')));
    }
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategory = null;
      _currentPriceRange = _priceRange;
      _sortBy = 'created_at';
      _sortOrder = 'DESC';
      _searchType = 'category';
      _searchStep = 'category';
      _showPriceRange = false;
      _minPriceController.clear();
      _maxPriceController.clear();
      _services.clear();
    });
  }

  void _setSearchType(String type) {
    setState(() {
      _searchType = type;

      if (type == 'price') {
        _sortBy = 'price';
        _sortOrder = 'ASC'; // الأرخص أولاً
        _showPriceRange = true;
      } else if (type == 'distance') {
        _sortBy = 'distance';
        _sortOrder = 'ASC'; // الأقرب أولاً
        _showPriceRange = false;
        // تنفيذ البحث مباشرة للأقرب إذا كان GPS مفعل
        if (_isLocationEnabled) {
          _performSearch();
        }
      }
    });
  }

  void _selectCategory(Map<String, dynamic> category) {
    setState(() {
      _selectedCategory = category;
      _searchStep = 'criteria';
    });
  }

  void _goBackToCategories() {
    setState(() {
      _selectedCategory = null;
      _searchStep = 'category';
      _searchType = 'category';
      _showPriceRange = false;
      _minPriceController.clear();
      _maxPriceController.clear();
      _services.clear();
    });
  }

  Widget _buildQuickSearchChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Colors.grey[300]!,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildCategoriesView() => Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'اختر نوع الخدمة:',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              return GestureDetector(
                onTap: () {
                  _selectCategory(category);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getCategoryIcon(category['name']),
                        size: 48,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${category['services_count']} خدمة',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName) {
      case 'تصوير':
        return Icons.camera_alt;
      case 'تنسيق':
        return Icons.celebration;
      case 'مطاعم':
        return Icons.restaurant;
      case 'موسيقى':
        return Icons.music_note;
      case 'نقل':
        return Icons.directions_car;
      case 'أزياء':
        return Icons.checkroom;
      case 'ديكور':
        return Icons.home;
      case 'أمن':
        return Icons.security;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
    onWillPop: () async {
      Navigator.pushNamedAndRemoveUntil(
        context,
        RouteNames.userHome,
        (route) => false,
      );
      return false;
    },
    child: SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('البحث المتقدم'),
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () =>
                Navigator.pushReplacementNamed(context, RouteNames.userHome),
          ),
          actions: [
            IconButton(
              icon: Icon(
                _showFilters ? Icons.filter_list_off : Icons.filter_list,
              ),
              onPressed: () {
                setState(() {
                  _showFilters = !_showFilters;
                });
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // شريط البحث
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: _searchStep == 'category'
                            ? 'ابحث في جميع الخدمات...'
                            : 'ابحث في ${_selectedCategory?['name']}...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  if (_searchStep == 'criteria') {
                                    _performSearch();
                                  }
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onSubmitted: (_) {
                        // لا ينفذ البحث عند الضغط على Enter
                        // البحث يتم فقط عند اختيار معيار البحث
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      // لا ينفذ البحث عند الضغط على زر البحث
                      // البحث يتم فقط عند اختيار معيار البحث
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('بحث'),
                  ),
                ],
              ),
            ),

            // عرض الخطوات
            if (_searchStep == 'category') ...[
              // خطوة اختيار الفئة
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'الخطوة 1: اختر نوع الخدمة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'اختر نوع الخدمة التي تبحث عنها:',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ] else if (_searchStep == 'criteria') ...[
              // خطوة اختيار المعيار
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'الخطوة 2: اختر معيار البحث',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'الفئة المختارة: ${_selectedCategory?['name']}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _goBackToCategories,
                          icon: const Icon(Icons.arrow_back),
                          tooltip: 'العودة لاختيار الفئة',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildQuickSearchChip(
                          label: 'السعر الأنسب',
                          icon: Icons.attach_money,
                          isSelected: _searchType == 'price',
                          onTap: () => _setSearchType('price'),
                        ),
                        _buildQuickSearchChip(
                          label: 'الأقرب',
                          icon: Icons.location_on,
                          isSelected: _searchType == 'distance',
                          onTap: () => _setSearchType('distance'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            // حقل نطاق السعر (عند اختيار السعر الأنسب)
            if (_searchType == 'price' && _showPriceRange) ...[
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'حدد نطاق السعر:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _minPriceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'الحد الأدنى (ريال)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.attach_money),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _maxPriceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'الحد الأقصى (ريال)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.attach_money),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _performSearch,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'بحث عن الخدمات',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // زر البحث للأقرب (عند اختيار الأقرب)
            if (_searchType == 'distance' && !_isLoading) ...[
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isLocationEnabled
                              ? Icons.location_on
                              : Icons.location_off,
                          color: _isLocationEnabled ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isLocationEnabled
                              ? 'GPS مفعل - جاهز للبحث عن الأقرب'
                              : 'GPS غير مفعل - يرجى تفعيله',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _isLocationEnabled
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    if (_isLocationEnabled) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _performSearch,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'بحث عن الأقرب',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // الفلاتر
            if (_showFilters) ...[
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'الفلاتر',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: _resetFilters,
                          child: const Text('إعادة تعيين'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // فلتر الفئة
                    const Text(
                      'الفئة:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<Map<String, dynamic>>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      hint: const Text('اختر الفئة'),
                      items: [
                        const DropdownMenuItem<Map<String, dynamic>>(
                          value: null,
                          child: Text('جميع الفئات'),
                        ),
                        ..._categories.map(
                          (category) => DropdownMenuItem(
                            value: category,
                            child: Text(
                              '${category['name']} (${category['services_count']})',
                            ),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // فلتر السعر
                    const Text(
                      'نطاق السعر (ريال):',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    RangeSlider(
                      values: _currentPriceRange,
                      min: _priceRange.start,
                      max: _priceRange.end,
                      divisions: 100,
                      labels: RangeLabels(
                        '${_currentPriceRange.start.round()} ريال',
                        '${_currentPriceRange.end.round()} ريال',
                      ),
                      onChanged: (values) {
                        setState(() {
                          _currentPriceRange = values;
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${_currentPriceRange.start.round()} ريال'),
                        Text('${_currentPriceRange.end.round()} ريال'),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // فلتر الترتيب
                    const Text(
                      'الترتيب حسب:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _sortBy,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'created_at',
                                child: Text('الأحدث'),
                              ),
                              DropdownMenuItem(
                                value: 'price',
                                child: Text('السعر'),
                              ),
                              DropdownMenuItem(
                                value: 'rating',
                                child: Text('التقييم'),
                              ),
                              DropdownMenuItem(
                                value: 'distance',
                                child: Text('المسافة'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _sortBy = value!;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        DropdownButtonFormField<String>(
                          value: _sortOrder,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'ASC',
                              child: Text('تصاعدي'),
                            ),
                            DropdownMenuItem(
                              value: 'DESC',
                              child: Text('تنازلي'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _sortOrder = value!;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // حالة الموقع
                    Row(
                      children: [
                        Icon(
                          _isLocationEnabled
                              ? Icons.location_on
                              : Icons.location_off,
                          color: _isLocationEnabled ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _isLocationEnabled
                                ? 'الموقع مفعل - سيتم البحث عن الخدمات القريبة'
                                : 'الموقع غير مفعل - لن يتم البحث حسب المسافة',
                            style: TextStyle(
                              color: _isLocationEnabled
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // نتائج البحث
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _searchStep == 'category'
                  ? _buildCategoriesView()
                  : _services.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'لا توجد نتائج',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          Text(
                            'جرب تغيير معايير البحث',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _services.length,
                      itemBuilder: (context, index) {
                        final service = _services[index];
                        return ServiceCard(
                          service: service,
                          onTap: () {
                            // التنقل إلى تفاصيل الخدمة
                          },
                          onCall:
                              null, // حذف زر الاتصال لأنه يعتمد على خاصية غير موجودة
                        );
                      },
                    ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: 1,
          selectedItemColor: Colors.purple,
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            if (index == 1) return;
            switch (index) {
              case 0:
                Navigator.pushReplacementNamed(context, RouteNames.userHome);
                break;
              case 2:
                _navigateToFavorites();
                break;
              case 3:
                _navigateToBookings();
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'بحث'),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'المفضلة',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.event), label: 'الطلبات'),
          ],
        ),
      ),
    ),
  );
}
