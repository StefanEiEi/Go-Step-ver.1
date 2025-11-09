import 'package:flutter/material.dart';

import '../services/step_service.dart';
import '../widgets/stat_card.dart';
import '../widgets/summary_header.dart';
import '../widgets/weekly_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StepService _stepService = StepService();

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeStepService();
  }

  Future<void> _initializeStepService() async {
    try {
      await _stepService.init();

      // เมื่อมีการนับก้าวใหม่ → อัปเดตหน้าจอ
      _stepService.onStepChanged = (steps) {
        if (mounted) {
          setState(() {});
        }
      };
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _stepService.dispose();
    super.dispose();
  }

  // สร้าง data สำหรับกราฟ 7 วัน (เวอร์ชันง่าย)
  List<Map<String, dynamic>> _buildWeeklyDataForChart() {
    final now = DateTime.now();
    return List.generate(7, (index) {
      final day = now.subtract(Duration(days: 6 - index));
      final isToday = index == 6;
      return {
        'date': DateTime(day.year, day.month, day.day),
        'steps': isToday ? _stepService.steps : 0,
      };
    });
  }

  Future<void> _showSetGoalDialog() async {
    final controller = TextEditingController(
      text: _stepService.dailyGoal.toString(),
    );

    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set Daily Goal'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Steps per day',
              hintText: 'เช่น 8000',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final value = int.tryParse(controller.text);
                if (value != null && value > 0) {
                  Navigator.of(context).pop(value);
                } else {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result != null && result > 0) {
      await _stepService.setGoal(result);
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = _stepService.steps;
    final goal = _stepService.dailyGoal;
    final progress = goal > 0 ? (steps / goal).clamp(0.0, 1.0) : 0.0;

    // กำลังโหลด
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // มี error (เช่น ไม่ให้ permission)
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('GoStep!')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 16),
                Text(_errorMessage!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _errorMessage = null;
                    });
                    _initializeStepService();
                  },
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ปกติ
    return Scaffold(
      appBar: AppBar(
        title: const Text("GoStep!"),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.flag),
            tooltip: 'Set Goal',
            onPressed: _showSetGoalDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SummaryHeader(steps: steps, goal: goal, progress: progress),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                StatCard(
                  icon: Icons.local_fire_department,
                  value: _stepService.calories.toStringAsFixed(1),
                  unit: 'kcal',
                  color: Colors.orange,
                ),
                StatCard(
                  icon: Icons.directions_walk,
                  value: _stepService.distance.toStringAsFixed(2),
                  unit: 'km',
                  color: Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 24),
            WeeklyChart(
              weeklyData: _buildWeeklyDataForChart(),
              dailyGoal: goal,
            ),
          ],
        ),
      ),
    );
  }
}
