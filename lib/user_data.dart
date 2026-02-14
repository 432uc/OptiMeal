
enum Gender {
  male,
  female,
}

enum ActivityLevel {
  sedentary, // 1.2
  lightlyActive, // 1.375
  moderatelyActive, // 1.55
  veryActive, // 1.725
  extraActive, // 1.9
}

class UserData {
  final double height;
  final double weight;
  final int age;
  final Gender gender;
  final ActivityLevel activityLevel;

  UserData({
    required this.height,
    required this.weight,
    required this.age,
    required this.gender,
    required this.activityLevel,
  });

  double get bmr {
    if (gender == Gender.male) {
      return 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    } else {
      return 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    }
  }

  double get tdee {
    switch (activityLevel) {
      case ActivityLevel.sedentary:
        return bmr * 1.2;
      case ActivityLevel.lightlyActive:
        return bmr * 1.375;
      case ActivityLevel.moderatelyActive:
        return bmr * 1.55;
      case ActivityLevel.veryActive:
        return bmr * 1.725;
      case ActivityLevel.extraActive:
        return bmr * 1.9;
    }
  }
}
