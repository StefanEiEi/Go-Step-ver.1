import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeeklyChart extends StatelessWidget {
  final List<Map<String, dynamic>> weeklyData;
  final int dailyGoal;

  const WeeklyChart({
    super.key,
    required this.weeklyData,
    required this.dailyGoal,
  });

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Weekly Progress",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: weeklyData.map((data) {
              final steps = data['steps'] as int;
              final date = data['date'] as DateTime;

              final ratio = dailyGoal > 0
                  ? (steps / dailyGoal).clamp(0.0, 2.0)
                  : 0.0;
              final barHeight = 20 + (ratio * 60);

              final isToday = _sameDay(date, DateTime.now());

              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 18,
                    height: barHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: isToday ? Colors.blue : Colors.grey[300],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('E').format(date),
                    style: TextStyle(
                      fontSize: 10,
                      color: isToday ? Colors.blue : Colors.grey[600],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
