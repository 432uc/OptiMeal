
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opti_meal/food_edit_screen.dart';
import 'package:opti_meal/food_item.dart';
import 'package:opti_meal/food_provider.dart';
import 'package:opti_meal/gemini_scanner_screen.dart';
import 'user_data_form.dart';
import 'user_data_provider.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Corrected provider name to match food_provider.dart
    final foodItems = ref.watch(foodListProvider);
    final userData = ref.watch(userDataProvider);

    // Calculate total energy locally as the helper method was missing
    double totalEnergy = 0;
    for (var item in foodItems) {
      totalEnergy += (item.energy ?? 0);
    }

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
      body: foodItems.isEmpty
          ? const Center(
              child: Text('食事を記録しましょう！'),
            )
          : ListView.builder(
              itemCount: foodItems.length,
              itemBuilder: (context, index) {
                final item = foodItems[index];
                return ListTile(
                  title: Text(item.name ?? '不明な食品'),
                  subtitle: Text(
                      '${item.energy?.toStringAsFixed(1)} kcal | P:${item.protein?.toStringAsFixed(1)}g F:${item.fat?.toStringAsFixed(1)}g C:${item.carbohydrate?.toStringAsFixed(1)}g'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      // Corrected method name to removeFoodItem
                      ref.read(foodListProvider.notifier).removeFoodItem(item.id);
                    },
                  ),
                  onTap: () {
                     Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => FoodEditScreen(foodItem: item),
                        ),
                      );
                  },
                );
              },
            ),
      bottomNavigationBar: userData == null 
        ? null
        : Container(
            color: Colors.green.shade100,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('今日の目標達成状況', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('エネルギー: ${totalEnergy.toStringAsFixed(1)} / ${userData.tdee.toStringAsFixed(1)} kcal'),
                LinearProgressIndicator(
                  value: userData.tdee > 0 ? totalEnergy / userData.tdee : 0,
                ),
              ],
            ),
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const GeminiScannerScreen(),
            ),
          );
        },
        child: const Icon(Icons.camera_alt),
        tooltip: 'Scan with AI',
      ),
    );
  }
}
