
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'meal_record.dart';
import 'meal_repository.dart';

// Current focused month/day in the calendar
final focusedDayProvider = StateProvider<DateTime>((ref) => DateTime.now());
final selectedDayProvider = StateProvider<DateTime>((ref) => DateTime.now());

// Stream of meal records for the currently focused month
final moonthlyMealsProvider = StreamProvider<List<MealRecord>>((ref) {
  final repository = ref.watch(mealRepositoryProvider);
  final focusedDay = ref.watch(focusedDayProvider);
  return repository.watchMealRecordsForMonth(focusedDay);
});

// Meal records for the selected day
final selectedDayMealsProvider = Provider<List<MealRecord>>((ref) {
  final monthlyMeals = ref.watch(moonthlyMealsProvider).value ?? [];
  final selectedDay = ref.watch(selectedDayProvider);
  
  return monthlyMeals.where((meal) {
    return meal.date.year == selectedDay.year &&
           meal.date.month == selectedDay.month &&
           meal.date.day == selectedDay.day;
  }).toList();
});

// Daily totals for each day in the focused month
final dailyTotalsProvider = Provider<Map<int, double>>((ref) {
  final monthlyMeals = ref.watch(moonthlyMealsProvider).value ?? [];
  final totals = <int, double>{};
  
  for (var meal in monthlyMeals) {
    final day = meal.date.day;
    totals[day] = (totals[day] ?? 0) + (meal.energy ?? 0);
  }
  
  return totals;
});
