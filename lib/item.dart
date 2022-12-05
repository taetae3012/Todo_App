import 'package:isar/isar.dart';

part 'item.g.dart';

@collection
class Item {
  Id id = Isar.autoIncrement; // you can also use id = null to auto increment
  String? text;
  bool isCompleted = false;
}