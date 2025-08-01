import 'package:flutter/material.dart';
import '../../services/services_service.dart';
import '../../models/service_model.dart';
import '../../widgets/service_card.dart';
import '../../routes/route_names.dart';

class ServicesScreen extends StatefulWidget {
  final int? categoryId;
  final String? categoryName;

  const ServicesScreen({super.key, this.categoryId, this.categoryName});

  @override
  _ServicesScreenState createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final ServicesService _servicesService = ServicesService();
  List<Service> _services = [];
  bool _isLoading = true;
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _services.clear();
    }

    try {
      Map<String, dynamic> response;

      if (widget.categoryId != null) {
        // جلب الخدمات الخاصة بالفئة المحددة فقط
        response = await _servicesService.getServicesByCategory(
          widget.categoryId!,
          page: _currentPage,
          limit: 20,
        );
      } else {
        // جلب جميع الخدمات (للتوافق مع الكود القديم)
        response = await _servicesService.getAllServices(
          page: _currentPage,
          limit: 20,
        );
      }

      if (response['success'] == true) {
        final data = response['data'];
        final List<dynamic> servicesJson = data['services'];
        final List<Service> newServices = servicesJson
            .map((json) => Service.fromJson(json))
            .toList();

        setState(() {
          if (refresh) {
            _services = newServices;
          } else {
            _services.addAll(newServices);
          }

          final pagination = data['pagination'];
          _hasMore = _currentPage < pagination['total_pages'];
          _currentPage++;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        _showError(response['message'] ?? 'فشل في تحميل الخدمات');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _services.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.categoryName ?? 'الخدمات'),
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName ?? 'الخدمات'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadServices(refresh: true),
        child: _services.isEmpty && !_isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد خدمات متاحة',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.categoryId != null
                          ? 'لا توجد خدمات في هذه الفئة حالياً'
                          : 'لا توجد خدمات متاحة حالياً',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _services.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _services.length) {
                    if (_hasMore) {
                      _loadServices();
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return const SizedBox.shrink();
                  }

                  final service = _services[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ServiceCard(
                      service: service,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          RouteNames.serviceProviders,
                          arguments: {
                            'service_id': service.id,
                            'service_name': service.title,
                          },
                        );
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
