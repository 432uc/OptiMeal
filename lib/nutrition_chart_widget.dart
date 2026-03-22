import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'calendar_provider.dart';

class NutritionChartWidget extends ConsumerWidget {
  const NutritionChartWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actual = ref.watch(periodNutritionProvider);
    final target = ref.watch(periodTargetsProvider);

    final actualCal = actual['calories'] ?? 0;
    final actualP = actual['protein'] ?? 0;
    final actualF = actual['fat'] ?? 0;
    final actualC = actual['carbs'] ?? 0;

    final targetCal = target['calories'] ?? 0;
    final targetP = target['protein'] ?? 0;
    final targetF = target['fat'] ?? 0;
    final targetC = target['carbs'] ?? 0;

    if (targetCal == 0) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('ホーム画面右上の設定からユーザー情報を登録すると目標値が表示されます。'),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        color: Colors.white,
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('栄養サマリー', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SegmentedButton<GraphPeriod>(
                    segments: const [
                      ButtonSegment(value: GraphPeriod.day, label: Text('1日')),
                      ButtonSegment(value: GraphPeriod.week, label: Text('週間')),
                      ButtonSegment(value: GraphPeriod.month, label: Text('月間')),
                    ],
                    selected: {ref.watch(graphPeriodProvider)},
                    onSelectionChanged: (Set<GraphPeriod> newSelection) {
                      ref.read(graphPeriodProvider.notifier).state = newSelection.first;
                    },
                    style: SegmentedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 円グラフ (PFCバランス)
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: (actualP == 0 && actualF == 0 && actualC == 0)
                        ? const Center(child: Text('データなし'))
                        : PieChart(
                            PieChartData(
                              sectionsSpace: 0,
                              centerSpaceRadius: 30,
                              sections: [
                                PieChartSectionData(
                                  value: actualP,
                                  color: Colors.blue,
                                  title: 'P\n${actualP.toInt()}g',
                                  radius: 30,
                                  titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                PieChartSectionData(
                                  value: actualF,
                                  color: Colors.orange,
                                  title: 'F\n${actualF.toInt()}g',
                                  radius: 30,
                                  titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                PieChartSectionData(
                                  value: actualC,
                                  color: Colors.green,
                                  title: 'C\n${actualC.toInt()}g',
                                  radius: 30,
                                  titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                  ),
                  const SizedBox(width: 24),
                  // 目標と実績のプログレス＆テキスト
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMacroRow('カロリー', actualCal, targetCal, Colors.red),
                        const SizedBox(height: 8),
                        _buildMacroRow('タンパク質', actualP, targetP, Colors.blue),
                        const SizedBox(height: 8),
                        _buildMacroRow('脂質', actualF, targetF, Colors.orange),
                        const SizedBox(height: 8),
                        _buildMacroRow('炭水化物', actualC, targetC, Colors.green),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacroRow(String label, double actual, double target, Color color) {
    final diff = target - actual;
    final diffText = diff >= 0 ? 'あと ${diff.toInt()}' : '超過 ${(diff * -1).toInt()}';

    // 0 division check
    final double ratio = target > 0 ? (actual / target).clamp(0.0, 1.0) : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            Text('${actual.toInt()} / ${target.toInt()} ($diffText)', style: const TextStyle(fontSize: 11)),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: ratio,
          backgroundColor: Colors.grey[200],
          color: diff < 0 ? Colors.redAccent : color, // Exceeded = Red
          minHeight: 6,
        ),
      ],
    );
  }
}
