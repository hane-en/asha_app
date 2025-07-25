import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class CommentPage extends StatefulWidget {
  const CommentPage({super.key, required this.serviceId});
  final int serviceId;

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final commentController = TextEditingController();
  final ratingController = TextEditingController();
  bool isLoading = false;

  Future<void> submitComment() async {
    setState(() => isLoading = true);
    final success = await ApiService.addComment(
      widget.serviceId,
      commentController.text,
      double.tryParse(ratingController.text) ?? 5.0,
    );
    setState(() => isLoading = false);

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم إضافة التعليق بنجاح')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('فشل إضافة التعليق')));
    }
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
      onWillPop: () async {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/user_home',
          (route) => false,
        );
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(title: const Text('إضافة تعليق')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: commentController,
                  decoration: const InputDecoration(labelText: 'التعليق'),
                  maxLines: 3,
                ),
                TextField(
                  controller: ratingController,
                  decoration: const InputDecoration(labelText: 'التقييم (1-5)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: submitComment,
                        child: const Text('إرسال'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
}
