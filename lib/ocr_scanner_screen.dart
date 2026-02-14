
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'nutrition_parser.dart';

class OcrScannerScreen extends StatefulWidget {
  const OcrScannerScreen({super.key});

  @override
  State<OcrScannerScreen> createState() => _OcrScannerScreenState();
}

class _OcrScannerScreenState extends State<OcrScannerScreen> {
  File? _image;
  String _text = '';
  NutritionData? _nutritionData;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile == null) return;

      setState(() {
        _image = File(pickedFile.path);
        _text = '';
        _nutritionData = null;
      });

      _processImage(File(pickedFile.path));
    } catch (e) {
      debugPrint('Failed to pick image: $e');
    }
  }

  Future<void> _processImage(File imageFile) async {
    final textRecognizer = TextRecognizer();
    final inputImage = InputImage.fromFile(imageFile);
    final recognizedText = await textRecognizer.processImage(inputImage);
    textRecognizer.close();

    setState(() {
      _text = recognizedText.text;
      _nutritionData = NutritionParser.parse(recognizedText.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('栄養成分スキャナー'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (_image == null)
                  const Text('画像を選択または撮影してください')
                else
                  Image.file(_image!),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('撮影'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('ギャラリー'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (_nutritionData != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('エネルギー: ${_nutritionData!.energy ?? "--"} kcal'),
                      Text('タンパク質: ${_nutritionData!.protein ?? "--"} g'),
                      Text('脂質: ${_nutritionData!.fat ?? "--"} g'),
                      Text('炭水化物: ${_nutritionData!.carbohydrate ?? "--"} g'),
                    ],
                  ),
                const SizedBox(height: 20),
                SelectableText(_text), // For debugging recognized text
              ],
            ),
          ),
        ),
      ),
    );
  }
}
