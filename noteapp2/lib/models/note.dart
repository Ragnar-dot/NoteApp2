import 'package:hive/hive.dart';

part 'note.g.dart';

@HiveType(typeId: 0)
class Note extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String content;

  @HiveField(2)
  DateTime createdDate;

  @HiveField(3)
  bool isChecked;

  @HiveField(4)
  DateTime? reminderDate;

  Note({
    required this.title,
    required this.content,
    required this.createdDate,
    this.isChecked = false,
    this.reminderDate,
  });
}