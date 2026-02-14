
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_data.dart';
import 'user_data_provider.dart';

class UserDataForm extends ConsumerStatefulWidget {
  const UserDataForm({super.key});

  @override
  ConsumerState<UserDataForm> createState() => _UserDataFormState();
}

class _UserDataFormState extends ConsumerState<UserDataForm> {
  final _formKey = GlobalKey<FormState>();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _ageController = TextEditingController();
  Gender _selectedGender = Gender.male;
  ActivityLevel _selectedActivityLevel = ActivityLevel.sedentary;

  @override
  void initState() {
    super.initState();
    final userData = ref.read(userDataProvider);
    if (userData != null) {
      _heightController.text = userData.height.toString();
      _weightController.text = userData.weight.toString();
      _ageController.text = userData.age.toString();
      _selectedGender = userData.gender;
      _selectedActivityLevel = userData.activityLevel;
    }
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final userData = UserData(
        height: double.parse(_heightController.text),
        weight: double.parse(_weightController.text),
        age: int.parse(_ageController.text),
        gender: _selectedGender,
        activityLevel: _selectedActivityLevel,
      );
      ref.read(userDataProvider.notifier).setUserData(userData);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ユーザー情報'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _heightController,
                decoration: const InputDecoration(labelText: '身長 (cm)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '身長を入力してください';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(labelText: '体重 (kg)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '体重を入力してください';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: '年齢'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '年齢を入力してください';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<Gender>(
                value: _selectedGender,
                items: Gender.values
                    .map((gender) => DropdownMenuItem(
                          value: gender,
                          child: Text(gender == Gender.male ? '男性' : '女性'),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedGender = value;
                    });
                  }
                },
                decoration: const InputDecoration(labelText: '性別'),
              ),
              DropdownButtonFormField<ActivityLevel>(
                value: _selectedActivityLevel,
                items: ActivityLevel.values
                    .map((level) => DropdownMenuItem(
                          value: level,
                          child: Text(_activityLevelToString(level)),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedActivityLevel = value;
                    });
                  }
                },
                decoration: const InputDecoration(labelText: '活動レベル'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveForm,
                child: const Text('保存'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _activityLevelToString(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.sedentary:
        return ' sedentary';
      case ActivityLevel.lightlyActive:
        return 'lightly active';
      case ActivityLevel.moderatelyActive:
        return 'moderately active';
      case ActivityLevel.veryActive:
        return 'very active';
      case ActivityLevel.extraActive:
        return 'extra active';
    }
  }
}
