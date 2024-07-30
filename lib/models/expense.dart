import 'package:isar/isar.dart';

part 'expense.g.dart';

@collection
class Expense {
  Id id = Isar.autoIncrement; // you can also use id = null to auto increment
  final String name;
  final double amount;
  final DateTime date;

  Expense(
      {required this.id,
      required this.name,
      required this.amount,
      required this.date});
}
