
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'meal_record.dart';
import 'meal_repository.dart';

import 'package:table_calendar/table_calendar.dart';
import 'package:opti_meal/user_data_provider.dart';

// Graph period selection
enum GraphPeriod { day, week, month }
final graphPeriodProvider = StateProvider<GraphPeriod>((ref) => GraphPeriod.day);

// Calendar format
final calendarFormatProvider = StateProvider<CalendarFormat>((ref) => CalendarFormat.month);

// Current focused month/day in the calendar
final focusedDayProvider = StateProvider<DateTime>((ref) => DateTime.now());
final selectedDayProvider = StateProvider<DateTime>((ref) => DateTime.now());

// Stream of meal records for the currently focused month
final moonthlyMealsProvider = StreamProvider<List<MealRecord>>((ref) {
  final repository = ref.watch(mealRepositoryProvider);
  final focusedDay = ref.watch(focusedDayProvider);
  return repository.watchMealRecordsForMonth(focusedDay);
});

// Calculate the visible meals based on the graph period
final visiblePeriodMealsProvider = Provider<List<MealRecord>>((ref) {
  final monthlyMeals = ref.watch(moonthlyMealsProvider).value ?? [];
  final period = ref.watch(graphPeriodProvider);
  final selected = ref.watch(selectedDayProvider);
  
  if (period == GraphPeriod.month) {
    return monthlyMeals;
  } else if (period == GraphPeriod.week) {
    final weekDay = selected.weekday;
    final startOffset = weekDay == 7 ? 0 : weekDay; // Sunday = 0
    final startOfWeek = selected.subtract(Duration(days: startOffset));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final end = DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59);
    
    return monthlyMeals.where((m) => m.date.isAfter(start.subtract(const Duration(seconds: 1))) && m.date.isBefore(end.add(const Duration(seconds: 1)))).toList();
  } else if (period == GraphPeriod.day) {
    return monthlyMeals.where((m) => 
      m.date.year == selected.year &&
      m.date.month == selected.month &&
      m.date.day == selected.day
    ).toList();
  }
  return [];
});

// Calculate macros for the visible period
final periodNutritionProvider = Provider<Map<String, double>>((ref) {
  final meals = ref.watch(visiblePeriodMealsProvider);
  double cals = 0, p = 0, f = 0, c = 0;
  for (final m in meals) {
    cals += m.energy ?? 0;
    p += m.protein ?? 0;
    f += m.fat ?? 0;
    c += m.carbohydrate ?? 0;
  }
  return {'calories': cals, 'protein': p, 'fat': f, 'carbs': c};
});

// Calculate targets based on UserData
final periodTargetsProvider = Provider<Map<String, double>>((ref) {
  final userData = ref.watch(userDataProvider);
  final period = ref.watch(graphPeriodProvider);
  final focused = ref.watch(focusedDayProvider);
  
  int daysInPeriod = 1;
  if (period == GraphPeriod.month) {
    daysInPeriod = DateTime(focused.year, focused.month + 1, 0).day;
  } else if (period == GraphPeriod.week) {
    daysInPeriod = 7;
  } else if (period == GraphPeriod.day) {
    daysInPeriod = 1;
  }
  
  if (userData == null || userData.tdee <= 0) {
    return {'calories': 0, 'protein': 0, 'fat': 0, 'carbs': 0};
  }
  
  final dailyCals = userData.tdee;
  final dailyP = (dailyCals * 0.2) / 4;
  final dailyF = (dailyCals * 0.25) / 9;
  final dailyC = (dailyCals * 0.55) / 4;
  
  return {
    'calories': dailyCals * daysInPeriod,
    'protein': dailyP * daysInPeriod,
    'fat': dailyF * daysInPeriod,
    'carbs': dailyC * daysInPeriod,
  };
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
