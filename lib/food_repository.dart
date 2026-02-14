
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'food_item.dart';

class FoodRepository {
  static const _foodListKey = 'food_list';

  Future<List<FoodItem>> loadFoodItems() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_foodListKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => FoodItem.fromMap(json)).toList();
    }
    return [];
  }

  Future<void> saveFoodItems(List<FoodItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonList = items.map((item) => item.toMap()).toList();
    await prefs.setString(_foodListKey, json.encode(jsonList));
  }
}
