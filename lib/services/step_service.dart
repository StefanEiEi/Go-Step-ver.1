import 'dart:async';

import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StepService {
  StreamSubscription<StepCount>? _subscription;

  /// callback ให้หน้า UI เวลา steps เปลี่ยน
  Function(int steps)? onStepChanged;

  int steps = 0;
  double distance = 0;
  double calories = 0;
  int dailyGoal = 8000;

  /// เรียกตอนเริ่มหน้า HomeScreen
  Future<void> init() async {
    await _loadGoal();
    final ok = await _ensurePermission();
    if (!ok) {
      throw Exception(
        'Please allow Activity Recognition permission to use the step counter.',
      );
    }
    _startListening();
  }

  Future<void> _loadGoal() async {
    final prefs = await SharedPreferences.getInstance();
    dailyGoal = prefs.getInt('dailyGoal') ?? 8000;
  }

  Future<bool> _ensurePermission() async {
    var status = await Permission.activityRecognition.status;

    if (!status.isGranted) {
      status = await Permission.activityRecognition.request();
    }

    return status.isGranted;
  }

  void _startListening() {
    _subscription = Pedometer.stepCountStream.listen(
      (StepCount event) {
        steps = event.steps;
        _updateStats();
        if (onStepChanged != null) {
          onStepChanged!(steps);
        }
      },
      onError: (error) {
        // ไม่ให้แอพตาย แต่อาจจะ log ไว้
        // เช่น sensor ไม่มีในเครื่อง
        // print('Pedometer error: $error');
      },
      cancelOnError: false,
    );
  }

  void _updateStats() {
    // ปรับตามโจทย์ / สมมติฐาน
    distance = steps * 0.0008; // 1 step ~ 0.8 m
    calories = steps * 0.04; // 1 step ~ 0.04 kcal
  }

  Future<void> setGoal(int newGoal) async {
    dailyGoal = newGoal;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('dailyGoal', newGoal);
  }

  void dispose() {
    _subscription?.cancel();
  }
}
