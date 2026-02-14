
import 'dart:convert';
import 'package:uuid/uuid.dart';

class FoodItem {
  final String id;
  String name;
  double? energy; // kcal
  double? protein; // g
  double? fat; // g
  double? carbohydrate; // g

  FoodItem({
    required this.id,
    this.name = 'New Food',
    this.energy,
    this.protein,
    this.fat,
    this.carbohydrate,
  });

  factory FoodItem.create({
    String name = 'New Food',
    double? energy,
    double? protein,
    double? fat,
    double? carbohydrate,
  }) {
    return FoodItem(
      id: const Uuid().v4(),
      name: name,
      energy: energy,
      protein: protein,
      fat: fat,
      carbohydrate: carbohydrate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'energy': energy,
      'protein': protein,
      'fat': fat,
      'carbohydrate': carbohydrate,
    };
  }

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id'],
      name: map['name'],
      energy: map['energy'],
      protein: map['protein'],
      fat: map['fat'],
      carbohydrate: map['carbohydrate'],
    );
  }

  String toJson() => json.encode(toMap());

  factory FoodItem.fromJson(String source) => FoodItem.fromMap(json.decode(source));
}
