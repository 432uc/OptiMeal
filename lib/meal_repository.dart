
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'meal_record.dart';

final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError('Isar is not initialized yet.');
});

final mealRepositoryProvider = Provider((ref) {
  final isar = ref.watch(isarProvider);
  return MealRepository(isar);
});

class MealRepository {
  final Isar _isar;

  MealRepository(this._isar);

  static Future<Isar> init() async {
    final dir = await getApplicationDocumentsDirectory();
    return Isar.open(
      [MealRecordSchema],
      directory: dir.path,
    );
  }

  Future<void> saveMealRecord(MealRecord record) async {
    await _isar.writeTxn(() async {
      await _isar.mealRecords.put(record);
    });
  }

  Future<void> deleteMealRecord(Id id) async {
    await _isar.writeTxn(() async {
      await _isar.mealRecords.delete(id);
    });
  }

  Future<List<MealRecord>> getMealRecordsForDay(DateTime day) async {
    final startOfDay = DateTime(day.year, day.month, day.day);
    final endOfDay = DateTime(day.year, day.month, day.day, 23, 59, 59);

    return _isar.mealRecords
        .filter()
        .dateBetween(startOfDay, endOfDay)
        .findAll();
  }

  Future<List<MealRecord>> getMealRecordsForMonth(DateTime month) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    return _isar.mealRecords
        .filter()
        .dateBetween(startOfMonth, endOfMonth)
        .findAll();
  }

  // Calculate totals for a given date
  Future<Map<String, double>> calculateDailyTotals(DateTime date) async {
    final records = await getMealRecordsForDay(date);
    double totalCalories = 0;
    double totalProtein = 0;
    double totalFat = 0;
    double totalCarbs = 0;

    for (var record in records) {
      totalCalories += record.energy ?? 0;
      totalProtein += record.protein ?? 0;
      totalFat += record.fat ?? 0;
      totalCarbs += record.carbohydrate ?? 0;
    }

    return {
      'calories': totalCalories,
      'protein': totalProtein,
      'fat': totalFat,
      'carbs': totalCarbs,
    };
  }

  // Watch flow to auto-update UI when DB changes
  Stream<List<MealRecord>> watchMealRecordsForMonth(DateTime month) {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    return _isar.mealRecords
        .filter()
        .dateBetween(startOfMonth, endOfMonth)
        .watch(fireImmediately: true);
  }
}
