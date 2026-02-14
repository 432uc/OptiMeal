
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_data.dart';

final userDataProvider = StateNotifierProvider<UserDataNotifier, UserData?>((ref) {
  return UserDataNotifier();
});

class UserDataNotifier extends StateNotifier<UserData?> {
  UserDataNotifier() : super(null);

  void setUserData(UserData userData) {
    state = userData;
  }

  double? get tdee => state?.tdee;
}
