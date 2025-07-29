import 'package:flutter/material.dart';
import '../../models/service_category_model.dart';
import '../../services/service_category_service.dart';

class AddServiceCategoryPage extends StatefulWidget {
  final int serviceId;
  final String serviceTitle;

  const AddServiceCategoryPage({
    Key? key,
    required this.serviceId,
    required this.serviceTitle,
  }) : super(key: key);

  @override
  State<AddServiceCategoryPage> createState() => _AddServiceCategoryPageState();
}

class _AddServiceCategoryPageState extends State<AddServiceCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageController = TextEditingController();
  final _sizeController = TextEditingController();
  final _dimensionsController = TextEditingController();
  final _locationController = TextEditingController();
  final _quantityController = TextEditingController();
  final _durationController = TextEditingController();
  final _materialsController = TextEditingController();
  final _additionalFeaturesController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _quantityController.text = '1';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    _sizeController.dispose();
    _dimensionsController.dispose();
    _locationController.dispose();
    _quantityController.dispose();
    _durationController.dispose();
    _materialsController.dispose();
    _additionalFeaturesController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final categoryData = {
        'service_id': widget.serviceId,
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.parse(_priceController.text),
        'image': _imageController.text.trim(),
        'size': _sizeController.text.trim(),
        'dimensions': _dimensionsController.text.trim(),
        'location': _locationController.text.trim(),
        'quantity': int.parse(_quantityController.text),
        'duration': _durationController.text.trim(),
        'materials': _materialsController.text.trim(),
        'additional_features': _additionalFeaturesController.text.trim(),
        'is_active': true,
      };

      final response = await ServiceCategoryService.addServiceCategory(
        categoryData,
      );

      if (response.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في إضافة فئة الخدمة: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'إضافة فئة خدمة',
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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // معلومات الخدمة
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'الخدمة: ${widget.serviceTitle}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'معرف الخدمة: ${widget.serviceId}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // الحقول المطلوبة
                    _buildSectionTitle('المعلومات الأساسية'),
                    _buildTextField(
                      controller: _nameController,
                      label: 'اسم فئة الخدمة *',
                      hint: 'مثال: تنظيف غرف النوم',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'اسم فئة الخدمة مطلوب';
                        }
                        return null;
                      },
                    ),
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'وصف فئة الخدمة',
                      hint: 'وصف مفصل لفئة الخدمة',
                      maxLines: 3,
                    ),
                    _buildTextField(
                      controller: _priceController,
                      label: 'السعر *',
                      hint: 'مثال: 150.00',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'السعر مطلوب';
                        }
                        if (double.tryParse(value) == null) {
                          return 'يرجى إدخال سعر صحيح';
                        }
                        return null;
                      },
                    ),
                    _buildTextField(
                      controller: _imageController,
                      label: 'رابط الصورة',
                      hint: 'رابط صورة فئة الخدمة',
                    ),

                    const SizedBox(height: 24),

                    // الحقول الاختيارية
                    _buildSectionTitle('معلومات إضافية'),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _sizeController,
                            label: 'الحجم',
                            hint: 'مثال: متوسط',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _dimensionsController,
                            label: 'الأبعاد',
                            hint: 'مثال: 3 غرف',
                          ),
                        ),
                      ],
                    ),
                    _buildTextField(
                      controller: _locationController,
                      label: 'الموقع',
                      hint: 'مثال: صنعاء',
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _quantityController,
                            label: 'الكمية',
                            hint: 'مثال: 1',
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'الكمية مطلوبة';
                              }
                              if (int.tryParse(value) == null) {
                                return 'يرجى إدخال كمية صحيحة';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _durationController,
                            label: 'المدة',
                            hint: 'مثال: 2-3 ساعات',
                          ),
                        ),
                      ],
                    ),
                    _buildTextField(
                      controller: _materialsController,
                      label: 'المواد المستخدمة',
                      hint: 'مثال: منظفات آمنة، مكنسة كهربائية',
                      maxLines: 2,
                    ),
                    _buildTextField(
                      controller: _additionalFeaturesController,
                      label: 'ميزات إضافية',
                      hint: 'مثال: تغيير الملاءات، تنظيف النوافذ',
                      maxLines: 2,
                    ),

                    const SizedBox(height: 32),

                    // زر الإضافة
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'إضافة فئة الخدمة',
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
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        validator: validator,
      ),
    );
  }
}
