
class NutritionData {
  final double? energy; // kcal
  final double? protein; // g
  final double? fat; // g
  final double? carbohydrate; // g

  NutritionData({this.energy, this.protein, this.fat, this.carbohydrate});

  @override
  String toString() {
    return 'NutritionData(energy: $energy, protein: $protein, fat: $fat, carbohydrate: $carbohydrate)';
  }
}

class NutritionParser {
  static NutritionData parse(String text) {
    final cleanedText = text.replaceAll(' ', '').replaceAll('\n', '');

    final energy = _extractValue(cleanedText, ['エネルギー', '熱量']);
    final protein = _extractValue(cleanedText, ['たんぱく質', 'タンパク質']);
    final fat = _extractValue(cleanedText, ['脂質']);
    final carbohydrate = _extractValue(cleanedText, ['炭水化物']);

    return NutritionData(
      energy: energy,
      protein: protein,
      fat: fat,
      carbohydrate: carbohydrate,
    );
  }

  static double? _extractValue(String text, List<String> keywords) {
    for (final keyword in keywords) {
      final regex = RegExp('$keyword[:：]?([\\d\\.]+)');
      final match = regex.firstMatch(text);
      if (match != null && match.group(1) != null) {
        return double.tryParse(match.group(1)!);
      }
    }
    // A more lenient regex for cases where units like kcal or g are attached
    for (final keyword in keywords) {
      final regex = RegExp('$keyword[:：]?([\\d\\.]+)(?:kcal|g)');
       final match = regex.firstMatch(text);
      if (match != null && match.group(1) != null) {
        return double.tryParse(match.group(1)!);
      }
    }
    return null;
  }
}
