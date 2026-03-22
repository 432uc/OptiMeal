
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opti_meal/meal_record.dart';
import 'package:opti_meal/meal_repository.dart';
import 'food_item.dart';
import 'food_provider.dart';

class FoodEditScreen extends ConsumerStatefulWidget {
  final FoodItem foodItem;

  const FoodEditScreen({super.key, required this.foodItem});

  @override
  ConsumerState<FoodEditScreen> createState() => _FoodEditScreenState();
}

class _FoodEditScreenState extends ConsumerState<FoodEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _energyController;
  late TextEditingController _proteinController;
  late TextEditingController _fatController;
  late TextEditingController _carbohydrateController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.foodItem.name);
    _energyController = TextEditingController(text: widget.foodItem.energy?.toString() ?? '');
    _proteinController = TextEditingController(text: widget.foodItem.protein?.toString() ?? '');
    _fatController = TextEditingController(text: widget.foodItem.fat?.toString() ?? '');
    _carbohydrateController = TextEditingController(text: widget.foodItem.carbohydrate?.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _energyController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _carbohydrateController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      final updatedItem = FoodItem(
        id: widget.foodItem.id,
        name: _nameController.text,
        energy: double.tryParse(_energyController.text),
        protein: double.tryParse(_proteinController.text),
        fat: double.tryParse(_fatController.text),
        carbohydrate: double.tryParse(_carbohydrateController.text),
      );
      
      // Save for current session (SharedPrefs / current list)
      ref.read(foodListProvider.notifier).addOrUpdateFoodItem(updatedItem);

      // Save to Isar for history/calendar
      final mealRecord = MealRecord(
        name: updatedItem.name,
        energy: updatedItem.energy,
        protein: updatedItem.protein,
        fat: updatedItem.fat,
        carbohydrate: updatedItem.carbohydrate,
        date: DateTime.now(), // Store with current timestamp
      );
      await ref.read(mealRepositoryProvider).saveMealRecord(mealRecord);

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  void _deleteItem() {
    ref.read(foodListProvider.notifier).removeFoodItem(widget.foodItem.id);
    Navigator.of(context).pop(); 
    if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.foodItem.name.isEmpty ? '食事内容の入力' : '食事内容の編集'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteItem,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: '食品・料理名'),
                validator: (value) => value!.isEmpty ? '名前を入力してください' : null,
              ),
              TextFormField(
                controller: _energyController,
                decoration: const InputDecoration(labelText: 'エネルギー (kcal)'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _proteinController,
                decoration: const InputDecoration(labelText: 'タンパク質 (g)'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _fatController,
                decoration: const InputDecoration(labelText: '脂質 (g)'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _carbohydrateController,
                decoration: const InputDecoration(labelText: '炭水化物 (g)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveForm, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text('保存', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
