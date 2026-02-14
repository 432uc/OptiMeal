
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_data.dart';

// Key for storing data in SharedPreferences
const String _heightKey = 'height';
const String _weightKey = 'weight';
const String _ageKey = 'age';
const String _genderKey = 'gender';
const String _activityLevelKey = 'activityLevel';

class UserDataRepository {
  Future<void> saveUserData(UserData userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_heightKey, userData.height);
    await prefs.setDouble(_weightKey, userData.weight);
    await prefs.setInt(_ageKey, userData.age);
    await prefs.setInt(_genderKey, userData.gender.index);
    await prefs.setInt(_activityLevelKey, userData.activityLevel.index);
  }

  Future<UserData?> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final height = prefs.getDouble(_heightKey);
    final weight = prefs.getDouble(_weightKey);
    final age = prefs.getInt(_ageKey);
    final genderIndex = prefs.getInt(_genderKey);
    final activityLevelIndex = prefs.getInt(_activityLevelKey);

    if (height != null &&
        weight != null &&
        age != null &&
        genderIndex != null &&
        activityLevelIndex != null) {
      return UserData(
        height: height,
        weight: weight,
        age: age,
        gender: Gender.values[genderIndex],
        activityLevel: ActivityLevel.values[activityLevelIndex],
      );
    }
    return null;
  }
}

final userDataProvider = StateNotifierProvider<UserDataNotifier, UserData?>((ref) {
  final notifier = UserDataNotifier(UserDataRepository());
  return notifier;
});

class UserDataNotifier extends StateNotifier<UserData?> {
  final UserDataRepository _repository;

  UserDataNotifier(this._repository) : super(null) {
    loadUserData(); // Load data on initialization
  }

  Future<void> loadUserData() async {
    state = await _repository.loadUserData();
  }

  Future<void> setUserData(UserData userData) async {
    await _repository.saveUserData(userData);
    state = userData;
  }

  double? get tdee => state?.tdee;
}
