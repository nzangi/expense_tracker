import 'package:expense_tracker/bar_graph/bar_graph.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../components/my_list_tile.dart';
import '../database/expense_database.dart';
import '../helper/helper_functions.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // text controllers
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  Future<Map<int, double>>? _monthlyTotalsFeature;

  @override
  void initState() {
    // read the data on initial start up
    Provider.of<ExpenseDatabase>(context, listen: false).readExpenses();

    //  futures loading
    refreshGraphData();
    super.initState();
  }

  // refresh graph data
  void refreshGraphData() {
    _monthlyTotalsFeature = Provider.of<ExpenseDatabase>(context, listen: false)
        .calculateMonthlyTotalCosts();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseDatabase>(builder: (context, value, child) {
      // get all the dates
      int startMonth = value.getStartMonth();
      int startYear = value.getYearMonth();
      int currentMonth = DateTime.now().month;
      int currentYear = DateTime.now().year;

      // calculate expense of months since first month
      int monthCount =
          calculateMonthCount(startYear, startMonth, currentYear, currentMonth);

      //only display expense for the current month

      //return UI
      return Scaffold(
          backgroundColor: Colors.grey.shade300,
          floatingActionButton: FloatingActionButton(
            onPressed: openExpenseBox,
            child: const Icon(Icons.add),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // GRAPH UI
                SizedBox(
                  height: 250,
                  child: FutureBuilder(
                      future: _monthlyTotalsFeature,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          final monthlyTotals = snapshot.data ?? {};
                          //   create a list of summary
                          List<double> monthlySalary = List.generate(
                              monthCount,
                              (index) =>
                                  monthlyTotals[startMonth + index] ?? 0.0);

                          return MyBarGraph(
                              monthlySalary: monthlySalary,
                              startMonth: startMonth);
                        } else {
                          return const Center(
                            child: Text('Loading ...'),
                          );
                        }
                      }),
                ),
                // MyBarGraph(monthlySalary: monthlySalary, startMonth: startMonth),
                // list builder
                Expanded(
                  child: ListView.builder(
                      itemCount: value.allExpenses.length,
                      itemBuilder: (context, index) {
                        // get individual expense
                        Expense individualExpense = value.allExpenses[index];
                        return MyListTile(
                          title: individualExpense.name,
                          trailing: formatAmount(individualExpense.amount),
                          onDeletePressed: (context) =>
                              openDeleteBox(individualExpense),
                          onEditPressed: (context) =>
                              openEditBox(individualExpense),
                        );
                      }),
                ),
              ],
            ),
          ));
    });
  }

  // delete button
  void openDeleteBox(Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        actions: [
          //   cancel button
          _cancelButton(),

          //   Delete button
          _deleteExpenseButton(expense.id)
        ],
      ),
    );
  }

  void openEditBox(Expense expense) {
    String existingName = expense.name;
    String existingAmount = expense.amount.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //   user input, expense name
            TextField(
              controller: nameController,
              decoration: InputDecoration(hintText: existingName),
            ),
            TextField(
              controller: amountController,
              decoration: InputDecoration(hintText: existingAmount),
            ),
          ],
        ),
        actions: [
          //   cancel button
          _cancelButton(),

          //   save button
          _editExpenseButton(expense)
        ],
      ),
    );
  }

  // expense box
  void openExpenseBox() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('New Expense'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  //   user input, expense name
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(hintText: "Name"),
                  ),
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(hintText: "Amount"),
                  ),
                ],
              ),
              actions: [
                //   cancel button
                _cancelButton(),

                //   save button
                _createExpense()
              ],
            ));
  }

  // cancel button
  Widget _cancelButton() {
    return MaterialButton(
      onPressed: () {
        //   pop box
        Navigator.pop(context);
        //   clear controllers
        nameController.clear();
        amountController.clear();
      },
      child: const Text('Cancel'),
    );
  }

  // create expense
  Widget _createExpense() {
    return MaterialButton(
      onPressed: () async {
        //   save if only there is something on text field
        if (nameController.text.isNotEmpty &&
            amountController.text.isNotEmpty) {
          //   pop box
          Navigator.pop(context);
          //   create new expense
          Expense newExpense = Expense(
              name: nameController.text,
              amount: convertStringToDouble(amountController.text),
              date: DateTime.now());
          //   save to db
          await context.read<ExpenseDatabase>().createExpense(newExpense);

          refreshGraphData();
          //   clear controllers
          nameController.clear();
          amountController.clear();
        }
      },
      child: const Text('Save'),
    );
  }

  // save update
  Widget _editExpenseButton(Expense expense) {
    return MaterialButton(
      onPressed: () async {
        //   save if name or amount has changed
        if (nameController.text.isNotEmpty ||
            amountController.text.isNotEmpty) {
          //   pop box
          Navigator.pop(context);
          //   create new updated expense
          Expense updatedExpense = Expense(
              name: nameController.text.isNotEmpty
                  ? nameController.text
                  : expense.name,
              amount: amountController.text.isNotEmpty
                  ? convertStringToDouble(amountController.text)
                  : expense.amount,
              date: DateTime.now());
          //   old expense id
          int existingId = expense.id;

          //   update
          await context
              .read<ExpenseDatabase>()
              .updateExpense(existingId, updatedExpense);
        }
        refreshGraphData();
      },
      child: const Text('Update'),
    );
  }

  Widget _deleteExpenseButton(int id) {
    return MaterialButton(
      onPressed: () async {
        //   pop box
        Navigator.pop(context);
        //   delete from expense db
        await context.read<ExpenseDatabase>().deleteExpense(id);
        refreshGraphData();
      },
      child: const Text('Delete'),
    );
  }
}
