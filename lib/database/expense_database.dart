import 'package:flutter/cupertino.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/expense.dart';

class ExpenseDatabase extends ChangeNotifier{
  static late Isar isar;
  List<Expense> _allExpenses = [];

  /*
    SET UP
   */

  // initialize db
  static Future<void> initialize() async{
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
  Future<void> createExpense (Expense newExpense) async{
    //   add to db
    await isar.writeTxn(() => isar.expenses.put(newExpense));

    //   reread from db
    await readExpenses();

  }

  // Read - read an expense

  Future<void> readExpenses() async{
    //   fetch all existing databases
    List<Expense> fetchedExpenses = await isar.expenses.where().findAll();
    // give to local expense list
    _allExpenses.clear();
    _allExpenses.addAll(fetchedExpenses);
    // update UI
    notifyListeners();
  }

  // Update - update an  expense
  Future<void> updateExpense(int id,Expense updatedExpense) async{
    // Get the Expense Id
    updatedExpense.id = id;
    // Update the db
    await isar.writeTxn(() => isar.expenses.put(updatedExpense));
    // reread from db
    await readExpenses();
  }

  // Delete - delete an expense
  Future<void> deleteExpense(int id) async{
   // delete from db
    await isar.writeTxn(() => isar.expenses.delete(id));
   //reread from db
    await readExpenses();

  }





    /*
    HELPERS
   */


}