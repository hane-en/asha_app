import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/validators.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/config.dart';

class EditAdPage extends StatefulWidget {
  const EditAdPage({super.key, required this.ad});
  final Map<String, dynamic> ad;

  @override
  State<EditAdPage> createState() => _EditAdPageState();
}

class _EditAdPageState extends State<EditAdPage> {
  final _formKey = GlobalKey<FormState>();
  File? _selectedImage;
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final linkController = TextEditingController();
  final priorityController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  String? selectedService;
  List<Map<String, dynamic>> services = [];
  bool isLoadingServices = false;
  bool isLoading = false;
  String? currentImagePath;

  @override
  void initState() {
    super.initState();
    titleController.text = widget.ad['title'] ?? '';
    descriptionController.text = widget.ad['description'] ?? '';
    linkController.text = widget.ad['link'] ?? '';
    priorityController.text = widget.ad['priority']?.toString() ?? '';
    startDateController.text = widget.ad['start_date'] ?? '';
    endDateController.text = widget.ad['end_date'] ?? '';
    selectedService = widget.ad['service_id']?.toString();
    currentImagePath = widget.ad['image'] ?? widget.ad['image_url'];
    _loadServices();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    linkController.dispose();
    priorityController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    super.dispose();
  }

  Future<void> _loadServices() async {
    setState(() {
      isLoadingServices = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      if (userId != null) {
        final response = await http.get(
          Uri.parse(
            '${Config.apiBaseUrl}/provider/get_my_services.php?provider_id=$userId',
          ),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['success'] == true) {
            setState(() {
              services = List<Map<String, dynamic>>.from(data['data']);
            });
          }
        }
      }
    } catch (e) {
      print('خطأ في تحميل الخدمات: $e');
    } finally {
      setState(() {
        isLoadingServices = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> updateAd() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage == null &&
        (currentImagePath == null || currentImagePath!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ يرجى اختيار صورة للإعلان'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ يرجى اختيار الخدمة المرتبطة بالإعلان'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      var uri = Uri.parse('${Config.apiBaseUrl}/provider/update_ad.php');
      var request = http.MultipartRequest('POST', uri);
      request.fields['ad_id'] = widget.ad['id'].toString();
      request.fields['title'] = titleController.text.trim();
      request.fields['description'] = descriptionController.text.trim();
      request.fields['service_id'] = selectedService!;
      if (userId != null) {
        request.fields['provider_id'] = userId.toString();
      }
      if (linkController.text.isNotEmpty) {
        request.fields['link'] = linkController.text.trim();
      }
      if (priorityController.text.isNotEmpty) {
        request.fields['priority'] = priorityController.text.trim();
      }
      if (startDateController.text.isNotEmpty) {
        request.fields['start_date'] = startDateController.text.trim();
      }
      if (endDateController.text.isNotEmpty) {
        request.fields['end_date'] = endDateController.text.trim();
      }
      if (_selectedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', _selectedImage!.path),
        );
      }
      var response = await request.send();
      final responseData = await response.stream.bytesToString();
      final data = json.decode(responseData);
      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${data['message'] ?? 'تم تحديث الإعلان بنجاح'}'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${data['message'] ?? 'فشل في تحديث الإعلان'}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ خطأ في الاتصال: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Scaffold(
      appBar: AppBar(
        title: const Text('تعديل الإعلان'),
        centerTitle: true,
        elevation: 0,
        foregroundColor: Colors.white,
        backgroundColor: Colors.purple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple, Colors.purple],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Icon(Icons.edit, size: 80, color: Colors.purple),
                      ),
                      const SizedBox(height: 24),
                      const Center(
                        child: Text(
                          'تعديل الإعلان',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 108, 108, 108),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Center(
                        child: Text(
                          'قم بتعديل بيانات إعلانك',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 108, 108, 108),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // الحقول الإجبارية
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.star, color: Colors.red, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'الحقول الإجبارية',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // عنوان الإعلان
                              TextFormField(
                                controller: titleController,
                                decoration: InputDecoration(
                                  labelText: 'عنوان الإعلان *',
                                  hintText: 'أدخل عنوان الإعلان',
                                  prefixIcon: const Icon(Icons.title),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'عنوان الإعلان مطلوب';
                                  }
                                  if (value.length < 5) {
                                    return 'العنوان يجب أن يكون 5 أحرف على الأقل';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // وصف الإعلان
                              TextFormField(
                                controller: descriptionController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  labelText: 'وصف الإعلان *',
                                  hintText: 'أدخل وصف الإعلان',
                                  prefixIcon: const Icon(Icons.description),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'وصف الإعلان مطلوب';
                                  }
                                  if (value.length < 10) {
                                    return 'الوصف يجب أن يكون 10 أحرف على الأقل';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // اختيار الخدمة
                              DropdownButtonFormField<String>(
                                value: selectedService,
                                decoration: InputDecoration(
                                  labelText: 'الخدمة المرتبطة *',
                                  hintText: 'اختر الخدمة المرتبطة بالإعلان',
                                  prefixIcon: const Icon(Icons.design_services),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                                items: isLoadingServices
                                    ? [
                                        const DropdownMenuItem(
                                          value: null,
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: 16,
                                                height: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              ),
                                              SizedBox(width: 8),
                                              Text('جاري التحميل...'),
                                            ],
                                          ),
                                        ),
                                      ]
                                    : services.map((service) {
                                        return DropdownMenuItem(
                                          value: service['id'].toString(),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.design_services,
                                                color: Color.fromARGB(
                                                  255,
                                                  169,
                                                  145,
                                                  173,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  service['title'] ??
                                                      service['name'] ??
                                                      'خدمة غير محددة',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                onChanged: isLoadingServices
                                    ? null
                                    : (value) => setState(
                                        () => selectedService = value,
                                      ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'الخدمة المرتبطة مطلوبة';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // الصورة
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.grey[50],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(
                                          Icons.image,
                                          color: Colors.deepPurple,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'صورة الإعلان *',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.deepPurple,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    if (_selectedImage != null)
                                      kIsWeb
                                          ? Image.network(
                                              _selectedImage!.path,
                                              width: double.infinity,
                                              height: 200,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    return Container(
                                                      width: double.infinity,
                                                      height: 200,
                                                      color: Colors.grey[300],
                                                      child: const Icon(
                                                        Icons.error,
                                                      ),
                                                    );
                                                  },
                                            )
                                          : Image.file(
                                              _selectedImage!,
                                              width: double.infinity,
                                              height: 200,
                                              fit: BoxFit.cover,
                                            )
                                    else if (currentImagePath != null)
                                      Image.network(
                                        '${Config.apiBaseUrl.replaceAll('/api', '')}/$currentImagePath',
                                        width: double.infinity,
                                        height: 200,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            width: double.infinity,
                                            height: 200,
                                            color: Colors.grey[300],
                                            child: const Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.error,
                                                  size: 40,
                                                  color: Colors.grey,
                                                ),
                                                SizedBox(height: 8),
                                                Text(
                                                  'لا يمكن تحميل الصورة الحالية',
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      )
                                    else
                                      Container(
                                        width: double.infinity,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey[300]!,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.add_photo_alternate,
                                                size: 40,
                                                color: Colors.grey,
                                              ),
                                              SizedBox(height: 8),
                                              Text('لم يتم اختيار صورة جديدة'),
                                            ],
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            icon: const Icon(
                                              Icons.photo_library,
                                            ),
                                            label: const Text('من المعرض'),
                                            onPressed: _pickImage,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.deepPurple.shade200,
                                              foregroundColor: Colors.white,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            icon: const Icon(Icons.camera_alt),
                                            label: const Text('الكاميرا'),
                                            onPressed: _pickImageFromCamera,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.deepPurple.shade200,
                                              foregroundColor: Colors.white,
                                            ),
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

                      const SizedBox(height: 20),

                      // الحقول الاختيارية
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.info,
                                    color: Colors.blue,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'معلومات إضافية (اختيارية)',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // رابط الإعلان
                              TextFormField(
                                controller: linkController,
                                decoration: InputDecoration(
                                  labelText: 'رابط الإعلان',
                                  hintText: 'أدخل رابط الإعلان (اختياري)',
                                  prefixIcon: const Icon(Icons.link),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // الأولوية
                              TextFormField(
                                controller: priorityController,
                                decoration: InputDecoration(
                                  labelText: 'الأولوية',
                                  hintText: 'أدخل رقم الأولوية (1-10)',
                                  prefixIcon: const Icon(Icons.priority_high),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 16),

                              // تاريخ البداية
                              TextFormField(
                                controller: startDateController,
                                decoration: InputDecoration(
                                  labelText: 'تاريخ بداية الإعلان',
                                  hintText: 'YYYY-MM-DD',
                                  prefixIcon: const Icon(Icons.calendar_today),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // تاريخ النهاية
                              TextFormField(
                                controller: endDateController,
                                decoration: InputDecoration(
                                  labelText: 'تاريخ نهاية الإعلان',
                                  hintText: 'YYYY-MM-DD',
                                  prefixIcon: const Icon(Icons.event_busy),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // زر التحديث
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          icon: isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.update),
                          label: Text(
                            isLoading ? 'جاري التحديث...' : 'تحديث الإعلان',
                          ),
                          onPressed: isLoading ? null : updateAd,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple.shade200,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
