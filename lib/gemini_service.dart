
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'nutrition_parser.dart';

class GeminiService {
  // Extract API key and remove any potential hidden characters or quotes
  final String? _apiKey = dotenv.env['GEMINI_API_KEY']?.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '').trim();

  Future<NutritionData?> analyzeImage(File imageFile) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception('APIキーが.envファイルに見つかりません。');
    }

    // Attempt to use the most common models in sequence, including the newly discovered 2.5-flash
    final models = [
      'gemini-2.5-flash',
      'gemini-2.5-flash-latest',
      'gemini-2.0-flash-exp',
      'gemini-1.5-flash',
      'gemini-1.5-flash-latest'
    ];
    
    String lastError = '';

    for (final modelName in models) {
      try {
        debugPrint('Trying Gemini analysis with model: $modelName');
        final model = GenerativeModel(
          model: modelName,
          apiKey: _apiKey!,
        );

        final bytes = await imageFile.readAsBytes();
        final response = await model.generateContent([
          Content.multi([
            TextPart("Identify food in image. Respond ONLY with JSON: {\"name\":\"food name\", \"energy\":0.0, \"protein\":0.0, \"fat\":0.0, \"carbohydrate\":0.0}"),
            DataPart('image/jpeg', bytes),
          ])
        ]);

        final text = response.text;
        if (text == null) continue;

        // Extract JSON from response
        final match = RegExp(r'\{.*\}', dotAll: true).firstMatch(text);
        if (match == null) continue;
        
        final data = jsonDecode(match.group(0)!);
        debugPrint('Success with $modelName');

        return NutritionData(
          name: data['name'] as String?,
          energy: (data['energy'] as num?)?.toDouble(),
          protein: (data['protein'] as num?)?.toDouble(),
          fat: (data['fat'] as num?)?.toDouble(),
          carbohydrate: (data['carbohydrate'] as num?)?.toDouble(),
        );
      } catch (e) {
        lastError = e.toString();
        // If it's a 404 (model not found), try the next one.
        if (!e.toString().contains('404')) {
          break; // Stop on other errors like 401 (auth) or 429 (quota)
        }
      }
    }

    throw Exception('Gemini解析に失敗しました。詳細: $lastError');
  }
  Future<NutritionData?> analyzeText(String foodName) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception('APIキーが.envファイルに見つかりません。');
    }

    final models = [
      'gemini-2.5-flash',
      'gemini-2.5-flash-latest',
      'gemini-2.0-flash-exp',
      'gemini-1.5-flash',
      'gemini-1.5-flash-latest'
    ];
    
    String lastError = '';

    for (final modelName in models) {
      try {
        debugPrint('Trying Gemini text analysis with model: $modelName');
        final model = GenerativeModel(
          model: modelName,
          apiKey: _apiKey!,
        );

        final response = await model.generateContent([
          Content.text('「$foodName」の一般的な栄養成分を推定してください。回答は以下のJSONフォーマットのみで行ってください: {"name":"食品名", "energy":カロリー(数字), "protein":タンパク質g(数字), "fat":脂質g(数字), "carbohydrate":炭水化物g(数字)}')
        ]);

        final text = response.text;
        if (text == null) continue;

        // Extract JSON from response
        final match = RegExp(r'\{.*\}', dotAll: true).firstMatch(text);
        if (match == null) continue;
        
        final data = jsonDecode(match.group(0)!);
        debugPrint('Success with $modelName');

        return NutritionData(
          name: data['name'] as String?,
          energy: (data['energy'] as num?)?.toDouble(),
          protein: (data['protein'] as num?)?.toDouble(),
          fat: (data['fat'] as num?)?.toDouble(),
          carbohydrate: (data['carbohydrate'] as num?)?.toDouble(),
        );
      } catch (e) {
        lastError = e.toString();
        if (!e.toString().contains('404')) {
          break; 
        }
      }
    }

    throw Exception('Gemini解析に失敗しました。詳細: $lastError');
  }
}
