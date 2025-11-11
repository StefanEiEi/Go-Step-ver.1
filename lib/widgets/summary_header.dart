import 'package:flutter/material.dart';

class SummaryHeader extends StatelessWidget {
  final int steps;
  final int goal;
  final double progress;
  final bool isWalking;

  const SummaryHeader({
    super.key,
    required this.steps,
    required this.goal,
    required this.progress,
    required this.isWalking,
  });

  @override
  Widget build(BuildContext context) {
    final safeGoal = goal > 0 ? goal : 0;
    final reachedGoal = safeGoal > 0 && steps >= safeGoal;

    //กำหนดสีพื้นหลังตามสถานะ
    final List<Color> gradientColors = reachedGoal
        ? [const Color(0xFF4CAF50), const Color(0xFF2E7D32)] // เขียว
        : [const Color(0xFF2196F3), const Color(0xFF1976D2)]; // ฟ้า

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: reachedGoal
                ? Colors.green.withOpacity(0.25)
                : Colors.blue.withOpacity(0.25),
            blurRadius: 22,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 130,
            width: double.infinity,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.06),
                    ),
                  ),
                  const Icon(
                    Icons.accessibility_new,
                    size: 54,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '$steps',
            style: const TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            'of $safeGoal Steps',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),

          const SizedBox(height: 22),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 40,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: isWalking
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFFE53935),
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: (isWalking
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFE53935))
                      .withOpacity(0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              isWalking ? 'Walking' : 'Stopped',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
