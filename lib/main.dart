
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opti_meal/food_edit_screen.dart';
import 'package:opti_meal/food_item.dart';
import 'package:opti_meal/food_provider.dart';
import 'ocr_scanner_screen.dart';
import 'user_data_form.dart';
import 'user_data_provider.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OptiMeal',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(userDataProvider);
    final tdee = userData?.tdee;
    final foodItems = ref.watch(foodListProvider);

    final totalEnergy = foodItems.fold<double>(
      0.0,
      (sum, item) => sum + (item.energy ?? 0.0),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('OptiMeal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const UserDataForm(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            _buildSummaryCard(context, tdee, totalEnergy),
            const SizedBox(height: 16),
            Text('今日の食事', style: Theme.of(context).textTheme.titleLarge),
            Expanded(
              child: ListView.builder(
                itemCount: foodItems.length,
                itemBuilder: (context, index) {
                  final item = foodItems[index];
                  return Card(
                    child: ListTile(
                      title: Text(item.name),
                      subtitle: Text('${item.energy?.toStringAsFixed(1) ?? 'N/A'} kcal'),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => FoodEditScreen(foodItem: item),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const OcrScannerScreen(),
            ),
          );
        },
        child: const Icon(Icons.camera_alt),
        tooltip: 'Scan Nutrition Label',
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, double? tdee, double totalEnergy) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text('目標 (TDEE)', style: Theme.of(context).textTheme.bodyLarge),
                Text(
                  tdee != null ? '${tdee.toStringAsFixed(0)} kcal' : '未設定',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            Column(
              children: [
                Text('摂取カロリー', style: Theme.of(context).textTheme.bodyLarge),
                Text(
                  '${totalEnergy.toStringAsFixed(0)} kcal',
                   style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: (tdee != null && totalEnergy > tdee) ? Colors.red : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
