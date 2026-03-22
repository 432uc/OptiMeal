
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'calendar_provider.dart';
import 'meal_record.dart';
import 'meal_record_edit_screen.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusedDay = ref.watch(focusedDayProvider);
    final selectedDay = ref.watch(selectedDayProvider);
    final selectedDayMeals = ref.watch(selectedDayMealsProvider);
    final dailyTotals = ref.watch(dailyTotalsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('栄養カレンダー'),
      ),
      body: Column(
        children: [
          _buildCalendarSection(ref, focusedDay, selectedDay, dailyTotals),
          const Divider(),
          Expanded(
            child: _buildMealListSection(selectedDay, selectedDayMeals),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarSection(
    WidgetRef ref,
    DateTime focusedDay,
    DateTime selectedDay,
    Map<int, double> dailyTotals,
  ) {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: focusedDay,
      selectedDayPredicate: (day) => isSameDay(selectedDay, day),
      onDaySelected: (selected, focused) {
        ref.read(selectedDayProvider.notifier).state = selected;
        ref.read(focusedDayProvider.notifier).state = focused;
      },
      onPageChanged: (focused) {
        ref.read(focusedDayProvider.notifier).state = focused;
      },
      calendarStyle: const CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Colors.greenAccent,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ),
      ),
      calendarBuilders: CalendarBuilders(
        // Use calendarBuilders to show the total calories below each date
        markerBuilder: (context, date, events) {
          final totalCalories = dailyTotals[date.day];
          if (totalCalories != null && totalCalories > 0 && date.month == focusedDay.month) {
            return Positioned(
              bottom: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${totalCalories.toInt()}kcal',
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
              ),
            );
          }
          return null;
        },
      ),
    );
  }

  Widget _buildMealListSection(DateTime selectedDay, List<MealRecord> meals) {
    final dateStr = DateFormat('yyyy/MM/dd (E)').format(selectedDay);
    
    if (meals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(dateStr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            const Text('この日の食事データはありません。'),
          ],
        ),
      );
    }

    double dayTotalCalories = 0;
    for (var m in meals) {
      dayTotalCalories += m.energy ?? 0;
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(dateStr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(
                '合計: ${dayTotalCalories.toInt()} kcal',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: meals.length,
            itemBuilder: (context, index) {
              final meal = meals[index];
              return ListTile(
                leading: const Icon(Icons.restaurant),
                title: Text(meal.name ?? '無名の食事'),
                subtitle: Text(
                  '${meal.energy?.toStringAsFixed(1)} kcal | P:${meal.protein?.toStringAsFixed(1)}g F:${meal.fat?.toStringAsFixed(1)}g C:${meal.carbohydrate?.toStringAsFixed(1)}g',
                ),
                trailing: Text(DateFormat('HH:mm').format(meal.date)),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MealRecordEditScreen(record: meal),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
