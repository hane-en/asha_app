import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../../utils/validators.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/config.dart';

class AddAdPage extends StatefulWidget {
  const AddAdPage({super.key});

  @override
  State<AddAdPage> createState() => _AddAdPageState();
}

class _AddAdPageState extends State<AddAdPage> {
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

  @override
  void initState() {
    super.initState();
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

  // دالة تحميل خدمات المزود
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

  Future<void> submitAd() async {
    if (!_formKey.currentState!.validate()) return;

    // التحقق من الحقول الإجبارية
    if (_selectedImage == null) {
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
      // الحصول على معرف المستخدم من SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      var uri = Uri.parse('${Config.apiBaseUrl}/provider/add_ad.php');
      var request = http.MultipartRequest('POST', uri);

      // الحقول الإجبارية
      request.fields['title'] = titleController.text.trim();
      request.fields['description'] = descriptionController.text.trim();
      request.fields['service_id'] = selectedService!;

      if (userId != null) {
        request.fields['provider_id'] = userId.toString();
      }

      // الحقول الاختيارية
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

      // إضافة الصورة
      request.files.add(
        await http.MultipartFile.fromPath('image', _selectedImage!.path),
      );

      var response = await request.send();
      if (!mounted) return;

      final responseData = await response.stream.bytesToString();
      final data = json.decode(responseData);

      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${data['message'] ?? 'تم إضافة الإعلان بنجاح'}'),
            backgroundColor: Colors.green,
          ),
        );
        _resetForm();
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${data['message'] ?? 'فشل في إضافة الإعلان'}'),
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

  void _resetForm() {
    _formKey.currentState!.reset();
    setState(() {
      _selectedImage = null;
      selectedService = null;
    });
    titleController.clear();
    descriptionController.clear();
    linkController.clear();
    priorityController.clear();
    startDateController.clear();
    endDateController.clear();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Scaffold(
      appBar: AppBar(
        title: const Text(
          'إضافة إعلان جديد',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        // foregroundColor: const Color.fromARGB(255, 255, 255, 255),
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
                        child: Icon(
                          Icons.add_business,
                          size: 80,
                          color: Colors.purple,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Center(
                        child: Text(
                          'إضافة إعلان جديد',
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
                          'أضف إعلانك لجذب المزيد من العملاء',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 108, 108, 108),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // عنوان الإعلان
                      TextFormField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: 'عنوان الإعلان',
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
                            return 'يرجى إدخال عنوان الإعلان';
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
                          labelText: 'وصف الإعلان',
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
                            return 'يرجى إدخال وصف الإعلان';
                          }
                          if (value.length < 10) {
                            return 'الوصف يجب أن يكون 10 أحرف على الأقل';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // اختيار صورة من المعرض
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.image),
                            label: const Text('اختر صورة من المعرض'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (_selectedImage != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _selectedImage!,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                        ],
                      ),
                      if (_selectedImage == null)
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            'يرجى اختيار صورة للإعلان',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      const SizedBox(height: 16),

                      // اختيار الخدمة المرتبطة بالإعلان
                      if (services.isNotEmpty) ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'اختر الخدمة المرتبطة بالإعلان',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 108, 108, 108),
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: selectedService,
                              decoration: InputDecoration(
                                labelText: 'الخدمة',
                                prefixIcon: const Icon(Icons.category),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              items: services.map((service) {
                                return DropdownMenuItem(
                                  value: service['id'].toString(),
                                  child: Text(service['name'] ?? 'غير محدد'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedService = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'يرجى اختيار الخدمة';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ] else ...[
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            'لا توجد خدمات متاحة. يرجى إضافة خدمة أولاً.',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),

                      // الحقول الإضافية
                      TextFormField(
                        controller: linkController,
                        decoration: InputDecoration(
                          labelText: 'رابط الإعلان (اختياري)',
                          hintText: 'أدخل رابط الإعلان (إذا كان موجود)',
                          prefixIcon: const Icon(Icons.link),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (value) {
                          if (value != null &&
                              value.trim().isNotEmpty &&
                              !Uri.parse(value).isAbsolute) {
                            return 'يرجى إدخال رابط صالح';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: priorityController,
                        decoration: InputDecoration(
                          labelText: 'أولوية الإعلان (اختياري)',
                          hintText:
                              'أدخل أولوية الإعلان (مثل: عاجل, متوسط, طويل)',
                          prefixIcon: const Icon(Icons.priority_high),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            return null;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: startDateController,
                        decoration: InputDecoration(
                          labelText: 'تاريخ بدء الإعلان (اختياري)',
                          hintText: 'أدخل تاريخ بدء الإعلان (مثل: 2023-10-27)',
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            return null;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: endDateController,
                        decoration: InputDecoration(
                          labelText: 'تاريخ انتهاء الإعلان (اختياري)',
                          hintText:
                              'أدخل تاريخ انتهاء الإعلان (مثل: 2023-11-27)',
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            return null;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      const SizedBox(height: 24),

                      // زر الإضافة
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                onPressed: submitAd,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'إضافة الإعلان',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
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
