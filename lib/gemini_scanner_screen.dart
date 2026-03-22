
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:opti_meal/food_edit_screen.dart';
import 'package:opti_meal/food_item.dart';
import 'gemini_service.dart';
import 'nutrition_parser.dart';

class GeminiScannerScreen extends StatefulWidget {
  const GeminiScannerScreen({super.key});

  @override
  State<GeminiScannerScreen> createState() => _GeminiScannerScreenState();
}

class _GeminiScannerScreenState extends State<GeminiScannerScreen> {
  bool _isProcessing = false;
  final GeminiService _geminiService = GeminiService();

  Future<void> _pickAndProcessImage(ImageSource source) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile == null) {
        setState(() => _isProcessing = false);
        return;
      }

      final imageFile = File(pickedFile.path);
      final NutritionData? nutritionData = await _geminiService.analyzeImage(imageFile);

      if (nutritionData == null) {
         throw Exception('Could not parse nutrition data from image.');
      }

      final newFoodItem = FoodItem.create(
        name: nutritionData.name ?? 'Scanned Food', // Use name from Gemini
        energy: nutritionData.energy,
        protein: nutritionData.protein,
        fat: nutritionData.fat,
        carbohydrate: nutritionData.carbohydrate,
      );

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => FoodEditScreen(foodItem: newFoodItem),
        ),
      );

    } catch (e) {
      debugPrint('Failed to process image: $e');
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('画像の解析に失敗しました: ${e.toString()}')),
        );
      }
    } finally {
       if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _processText(String foodName) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final NutritionData? nutritionData = await _geminiService.analyzeText(foodName);

      if (nutritionData == null) {
         throw Exception('Could not estimate nutrition data from text.');
      }

      final newFoodItem = FoodItem.create(
        name: nutritionData.name ?? foodName,
        energy: nutritionData.energy,
        protein: nutritionData.protein,
        fat: nutritionData.fat,
        carbohydrate: nutritionData.carbohydrate,
      );

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => FoodEditScreen(foodItem: newFoodItem),
        ),
      );

    } catch (e) {
      debugPrint('Failed to process text: $e');
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('解析に失敗しました: ${e.toString()}')),
        );
      }
    } finally {
       if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showTextInputDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('手入力で登録'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: '例: バナナ、コカ・コーラ',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () {
                final text = controller.text.trim();
                Navigator.of(context).pop();
                if (text.isNotEmpty) {
                  _processText(text);
                }
              },
              child: const Text('AIで推定'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('食品の登録'),
      ),
      body: Center(
        child: _isProcessing
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('AIが解析しています...')
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickAndProcessImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('カメラで撮影して登録'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      minimumSize: const Size(220, 0),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _pickAndProcessImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('ギャラリーから選択'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      minimumSize: const Size(220, 0),
                    ),
                  ),
                  const SizedBox(height: 48),
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text('または'),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: _showTextInputDialog,
                    icon: const Icon(Icons.edit_note),
                    label: const Text('文字で入力して登録'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      backgroundColor: Colors.green.shade100,
                      foregroundColor: Colors.green.shade900,
                      minimumSize: const Size(220, 0),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
