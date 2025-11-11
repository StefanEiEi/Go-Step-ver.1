import 'package:isar/isar.dart';

part 'daily_data.g.dart';

@collection
class DailyData {
  Id id = Isar.autoIncrement;
  late DateTime date;
  late int steps;
  late double calories;
  late double distance;
}
