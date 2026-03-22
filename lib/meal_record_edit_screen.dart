import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'meal_record.dart';
import 'meal_repository.dart';

class MealRecordEditScreen extends ConsumerStatefulWidget {
  final MealRecord record;

  const MealRecordEditScreen({super.key, required this.record});

  @override
  ConsumerState<MealRecordEditScreen> createState() => _MealRecordEditScreenState();
}

class _MealRecordEditScreenState extends ConsumerState<MealRecordEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _energyController;
  late TextEditingController _proteinController;
  late TextEditingController _fatController;
  late TextEditingController _carbohydrateController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.record.name);
    _energyController = TextEditingController(text: widget.record.energy?.toString() ?? '');
    _proteinController = TextEditingController(text: widget.record.protein?.toString() ?? '');
    _fatController = TextEditingController(text: widget.record.fat?.toString() ?? '');
    _carbohydrateController = TextEditingController(text: widget.record.carbohydrate?.toString() ?? '');
    _selectedDate = widget.record.date;
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

  Future<void> _selectDateAndTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null) {
      if (!mounted) return;
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      final updatedRecord = MealRecord(
        name: _nameController.text,
        energy: double.tryParse(_energyController.text),
        protein: double.tryParse(_proteinController.text),
        fat: double.tryParse(_fatController.text),
        carbohydrate: double.tryParse(_carbohydrateController.text),
        date: _selectedDate,
      )..id = widget.record.id; // IDを引き継ぐことで上書き更新になる

      await ref.read(mealRepositoryProvider).saveMealRecord(updatedRecord);
      
      if (mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _deleteRecord() async {
    await ref.read(mealRepositoryProvider).deleteMealRecord(widget.record.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('記録の編集'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('削除の確認'),
                  content: const Text('この記録を削除してもよろしいですか？'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('キャンセル'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // ダイアログを閉じる
                        _deleteRecord(); // 削除処理＆前の画面へ戻る
                      },
                      child: const Text('削除する', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('日付と時間'),
                subtitle: Text(DateFormat('yyyy/MM/dd HH:mm').format(_selectedDate)),
                trailing: const Icon(Icons.calendar_month),
                onTap: _selectDateAndTime,
              ),
              const Divider(),
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
