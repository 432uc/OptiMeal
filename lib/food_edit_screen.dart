
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final updatedItem = FoodItem(
        id: widget.foodItem.id,
        name: _nameController.text,
        energy: double.tryParse(_energyController.text),
        protein: double.tryParse(_proteinController.text),
        fat: double.tryParse(_fatController.text),
        carbohydrate: double.tryParse(_carbohydrateController.text),
      );
      ref.read(foodListProvider.notifier).addOrUpdateFoodItem(updatedItem);
      Navigator.of(context).pop();
    }
  }

  void _deleteItem() {
    ref.read(foodListProvider.notifier).removeFoodItem(widget.foodItem.id);
    // Pop twice to go back to the main screen
    Navigator.of(context).pop(); 
    if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.foodItem.name.isEmpty ? 'Add Food' : 'Edit Food'),
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
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
              ),
              TextFormField(
                controller: _energyController,
                decoration: const InputDecoration(labelText: 'Energy (kcal)'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _proteinController,
                decoration: const InputDecoration(labelText: 'Protein (g)'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _fatController,
                decoration: const InputDecoration(labelText: 'Fat (g)'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _carbohydrateController,
                decoration: const InputDecoration(labelText: 'Carbohydrate (g)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _saveForm, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }
}
