
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'food_item.dart';
import 'food_repository.dart';

final foodRepositoryProvider = Provider((ref) => FoodRepository());

final foodListProvider = StateNotifierProvider<FoodListNotifier, List<FoodItem>>((ref) {
  final repository = ref.watch(foodRepositoryProvider);
  return FoodListNotifier(repository);
});

class FoodListNotifier extends StateNotifier<List<FoodItem>> {
  final FoodRepository _repository;

  FoodListNotifier(this._repository) : super([]) {
    loadFoodItems();
  }

  Future<void> loadFoodItems() async {
    state = await _repository.loadFoodItems();
  }

  Future<void> addOrUpdateFoodItem(FoodItem item) async {
    final index = state.indexWhere((food) => food.id == item.id);
    if (index != -1) {
      state = [
        ...state.sublist(0, index),
        item,
        ...state.sublist(index + 1),
      ];
    } else {
      state = [...state, item];
    }
    await _repository.saveFoodItems(state);
  }

  Future<void> removeFoodItem(String id) async {
    state = state.where((item) => item.id != id).toList();
    await _repository.saveFoodItems(state);
  }
}
