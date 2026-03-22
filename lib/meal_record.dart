
import 'package:isar/isar.dart';

part 'meal_record.g.dart';

@collection
class MealRecord {
  Id id = Isar.autoIncrement;

  String? name;
  double? energy;
  double? protein;
  double? fat;
  double? carbohydrate;
  
  late DateTime date;

  MealRecord({
    this.name,
    this.energy,
    this.protein,
    this.fat,
    this.carbohydrate,
    required this.date,
  });
}
