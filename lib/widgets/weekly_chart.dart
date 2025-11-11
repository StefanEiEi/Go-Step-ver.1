import 'package:flutter/material.dart';

class WeeklyChart extends StatelessWidget {
  final List<Map<String, dynamic>> weeklyData;
  final int dailyGoal;

  const WeeklyChart({
    super.key,
    required this.weeklyData,
    required this.dailyGoal,
  });

  @override
  Widget build(BuildContext context) {
    if (weeklyData.isEmpty) {
      return _buildContainer(
        child: const Center(
          child: Text(
            'No data yet',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ),
      );
    }

    final maxSteps = weeklyData.fold<int>(
      0,
      (max, item) => item['steps'] is int
          ? (item['steps'] as int > max ? item['steps'] as int : max)
          : max,
    );

    final effectiveMax =
        maxSteps > 0 ? maxSteps : (dailyGoal > 0 ? dailyGoal : 1);

    return _buildContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Progress',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: weeklyData.map((day) {
                final int steps = day['steps'] ?? 0;
                final DateTime date = day['date'];
                final label = _dayLabel(date);

                final bool reached = dailyGoal > 0 && steps >= dailyGoal;

                final double heightFactor =
                    (steps / effectiveMax).clamp(0.0, 1.0);

                final Color barColor =
                    reached ? const Color(0xFF4CAF50) : const Color(0xFF2196F3);

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: 100 * heightFactor + 10,
                        width: 14,
                        decoration: BoxDecoration(
                          color: barColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: date.weekday == DateTime.now().weekday
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: date.weekday == DateTime.now().weekday
                              ? Colors.black
                              : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  String _dayLabel(DateTime date) {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[date.weekday % 7];
  }
}
