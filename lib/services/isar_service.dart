import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/daily_data.dart';

class IsarService {
  static Isar? _isar;

  // Open data base (Singleton)
  static Future<Isar> open() async {
    if (_isar != null) return _isar!;
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [DailyDataSchema],
      directory: dir.path,
    );
    return _isar!;
  }

  // บันทึกข้อมูลรายวัน
  static Future<void> saveDailyData({
    required DateTime date,
    required int steps,
    required double calories,
    required double distance,
  }) async {
    final isar = await open();
    final existing = await isar.dailyDatas
        .filter()
        .dateEqualTo(DateTime(date.year, date.month, date.day))
        .findFirst();

    await isar.writeTxn(() async {
      if (existing != null) {
        existing.steps = steps;
        existing.calories = calories;
        existing.distance = distance;
        await isar.dailyDatas.put(existing);
      } else {
        final newData = DailyData()
          ..date = DateTime(date.year, date.month, date.day)
          ..steps = steps
          ..calories = calories
          ..distance = distance;
        await isar.dailyDatas.put(newData);
      }
    });
  }

  // ดึงข้อมูล 7 วันล่าสุด
  static Future<List<DailyData>> getWeeklyData() async {
    final isar = await open();
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 6));
    return await isar.dailyDatas
        .filter()
        .dateBetween(DateTime(start.year, start.month, start.day),
            DateTime(now.year, now.month, now.day))
        .sortByDate()
        .findAll();
  }
}
