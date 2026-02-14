
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:opti_meal/food_edit_screen.dart';
import 'package:opti_meal/food_item.dart';
import 'nutrition_parser.dart';

class OcrScannerScreen extends StatefulWidget {
  const OcrScannerScreen({super.key});

  @override
  State<OcrScannerScreen> createState() => _OcrScannerScreenState();
}

class _OcrScannerScreenState extends State<OcrScannerScreen> {
  bool _isProcessing = false;

  Future<void> _pickAndProcessImage(ImageSource source) async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
    });

    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile == null) {
        setState(() => _isProcessing = false);
        return;
      }

      final imageFile = File(pickedFile.path);
      final textRecognizer = TextRecognizer();
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await textRecognizer.processImage(inputImage);
      textRecognizer.close();

      final nutritionData = NutritionParser.parse(recognizedText.text);

      final newFoodItem = FoodItem.create(
        name: 'Scanned Food',
        energy: nutritionData.energy,
        protein: nutritionData.protein,
        fat: nutritionData.fat,
        carbohydrate: nutritionData.carbohydrate,
      );

      if (!mounted) return;

      // Navigate to the edit screen with the new food item
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => FoodEditScreen(foodItem: newFoodItem),
        ),
      );

    } catch (e) {
      debugPrint('Failed to process image: $e');
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to process image.')),
        );
      }
    } finally {
       if(mounted) {
         setState(() {
            _isProcessing = false;
         });
       }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('栄養成分スキャナー'),
      ),
      body: Center(
        child: _isProcessing
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickAndProcessImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('カメラで撮影'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => _pickAndProcessImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('ギャラリーから選択'),
                  ),
                ],
              ),
      ),
    );
  }
}
