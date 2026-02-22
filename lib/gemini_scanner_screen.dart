
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI栄養成分スキャナー'),
      ),
      body: Center(
        child: _isProcessing
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('AIが画像を解析しています...')
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickAndProcessImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('カメラで撮影'),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => _pickAndProcessImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('ギャラリーから選択'),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                  ),
                ],
              ),
      ),
    );
  }
}
