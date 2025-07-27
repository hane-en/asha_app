import 'package:flutter/material.dart';
import '../../services/services_service.dart';
import '../../models/service_model.dart';
import '../../widgets/service_card.dart';

class ServicesScreen extends StatefulWidget {
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
      final response = await _servicesService.getAllServices(
        page: _currentPage,
        limit: 20,
      );

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
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text('الخدمات')),
      body: RefreshIndicator(
        onRefresh: () => _loadServices(refresh: true),
        child: ListView.builder(
          itemCount: _services.length + (_hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _services.length) {
              if (_hasMore) {
                _loadServices();
                return Center(child: CircularProgressIndicator());
              }
              return SizedBox.shrink();
            }

            final service = _services[index];
            return ServiceCard(service: service);
          },
        ),
      ),
    );
  }
}
