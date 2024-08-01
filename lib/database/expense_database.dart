import 'package:flutter/cupertino.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/expense.dart';

class ExpenseDatabase extends ChangeNotifier {
  static late Isar isar;
  List<Expense> _allExpenses = [];

  /*
    SET UP
   */

  // initialize db
  static Future<void> initialize() async {
    final directory = await getApplicationDocumentsDirectory();
    isar = await Isar.open([ExpenseSchema], directory: directory.path);
  }

  /*
    GETTERS
   */

  List<Expense> get allExpenses => _allExpenses;

  /*
    OPERATIONS
   */

  // Create - add a new expense
  Future<void> createExpense(Expense newExpense) async {
    //   add to db
    await isar.writeTxn(() => isar.expenses.put(newExpense));

    //   reread from db
    await readExpenses();
  }

  // Read - read an expense

  Future<void> readExpenses() async {
    //   fetch all existing databases
    List<Expense> fetchedExpenses = await isar.expenses.where().findAll();
    // give to local expense list
    _allExpenses.clear();
    _allExpenses.addAll(fetchedExpenses);
    // update UI
    notifyListeners();
  }

  // Update - update an  expense
  Future<void> updateExpense(int id, Expense updatedExpense) async {
    // Get the Expense Id
    updatedExpense.id = id;
    // Update the db
    await isar.writeTxn(() => isar.expenses.put(updatedExpense));
    // reread from db
    await readExpenses();
  }

  // Delete - delete an expense
  Future<void> deleteExpense(int id) async {
    // delete from db
    await isar.writeTxn(() => isar.expenses.delete(id));
    //reread from db
    await readExpenses();
  }

  /*
    HELPERS
   */

  //   calculate total expenses for each month
  Future<Map<int, double>> calculateMonthlyTotalCosts() async {
    //   read all expenses from db
    await readExpenses();
    //create a mpa to keep a track of each month
    Map<int, double> monthlyTotals = {};

    //   illiterate over all expenses
    for (var expense in _allExpenses) {
      //   extract date and month from each expense
      int month = expense.date.month;
      //   check if the map is in the map, internalize it to zero
      if (!monthlyTotals.containsKey(month)) {
        monthlyTotals[month] = 0;
      }

      //    add all month's expense to that month
      monthlyTotals[month] = monthlyTotals[month]! + expense.amount;
    }
    return monthlyTotals;
  }

//   get start year
  int getStartMonth(){
    if(_allExpenses.isEmpty){
      return DateTime.now()
          .month; // default current month if no expense recorded
    }

    // get all the expense to get the earliest
    _allExpenses.sort(
        (a,b) => a.date.compareTo(b.date)
    );
    return _allExpenses.first.date.month;
  }

  int getYearMonth(){
    if(_allExpenses.isEmpty){
      return DateTime.now()
          .year; // default current month if no expense recorded
    }
    // get all the expense to get the earliest

    _allExpenses.sort(
            (a,b) => a.date.compareTo(b.date)
    );
    return _allExpenses.first.date.year;
  }
}
