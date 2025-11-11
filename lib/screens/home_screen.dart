import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../services/step_service.dart';
import '../services/isar_service.dart';
import '../widgets/stat_card.dart';
import '../widgets/summary_header.dart';
import '../widgets/weekly_chart.dart';

enum ScreenState {
  loading,
  fail,
  normal,
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StepService _stepService = StepService();

  ScreenState _screenState = ScreenState.loading;
  String? _errorMessage;

  bool _isWalking = false;
  Timer? _walkingTimer;

  @override
  void initState() {
    super.initState();
    _initializeStepService();
  }

  @override
  void dispose() {
    _walkingTimer?.cancel();
    _stepService.dispose();
    super.dispose();
  }

  Future<void> _initializeStepService() async {
    try {
      
      setState(() {
        _screenState = ScreenState.loading;
        _errorMessage = null;
      });

      await Future.delayed(const Duration(seconds: 4));

      await _stepService.init();

      _stepService.onStepChanged = (steps) {
        if (!mounted) return;

        setState(() {
          _isWalking = true;
        });

        _walkingTimer?.cancel();
        _walkingTimer = Timer(const Duration(seconds: 3), () {
          if (!mounted) return;
          setState(() {
            _isWalking = false;
          });
        });

        //Save dately data to Isar
        IsarService.saveDailyData(
          date: DateTime.now(),
          steps: _stepService.steps,
          calories: _stepService.calories,
          distance: _stepService.distance,
        );
      };

      if (!mounted) return;

      //loading เสร็จ
      setState(() {
        _screenState = ScreenState.normal;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _screenState = ScreenState.fail;
        _errorMessage = e.toString();
      });
    }
  }

  // weekly data
  Future<List<Map<String, dynamic>>> _buildWeeklyDataForChart() async {
    final weekly = await IsarService.getWeeklyData();
    if (weekly.isEmpty) {
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

    return weekly
        .map((d) => {
              'date': d.date,
              'steps': d.steps,
            })
        .toList();
  }

  // popup set goal
  Future<void> _showSetGoalDialog() async {
    final controller =
        TextEditingController(text: _stepService.dailyGoal.toString());

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
      if (mounted) setState(() {});
    }
  }

  // ==================== BUILD ====================
  @override
  Widget build(BuildContext context) {
    // 1) Loading
    if (_screenState == ScreenState.loading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        body: Center(
          child: Lottie.asset(
            'assets/loading.json',
            width: 180,
            height: 180,
            repeat: true,
          ),
        ),
      );
    }

    // 2) Fail
    if (_screenState == ScreenState.fail) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/error.json',
                  width: 220,
                  height: 220,
                  repeat: true,
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage ??
                      'An error occurred while initializing the system.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
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

    // 3) Normal UI
    final steps = _stepService.steps;
    final goal = _stepService.dailyGoal;
    final progress = goal > 0 ? (steps / goal).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //GoStep! + ปุ่มตั้ง Goal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'GoStep!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, size: 26),
                    onPressed: _showSetGoalDialog,
                  ),
                ],
              ),

              const SizedBox(height: 24),
              
              // SummaryHeader
              SummaryHeader(
                steps: steps,
                goal: goal,
                progress: progress,
                isWalking: _isWalking,
              ),

              const SizedBox(height: 24),

              //Calories & Distance
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      icon: Icons.local_fire_department,
                      value: _stepService.calories.toStringAsFixed(1),
                      unit: 'cal',
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      icon: Icons.straighten,
                      value: _stepService.distance.toStringAsFixed(2),
                      unit: 'km',
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Weekly Progress
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _buildWeeklyDataForChart(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  final weeklyData = snapshot.data!;
                  return WeeklyChart(
                    weeklyData: weeklyData,
                    dailyGoal: goal,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
