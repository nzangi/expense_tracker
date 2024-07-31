import 'package:expense_tracker/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  @override
  void initState() {
    Provider.of<ExpenseDatabase>(context, listen: false).readExpenses();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseDatabase>(
        builder: (context, value, child) => Scaffold(
              floatingActionButton: FloatingActionButton(
                onPressed: openExpenseBox,
                child: const Icon(Icons.add),
              ),
              body: ListView.builder(
                  itemCount: value.allExpenses.length,
                  itemBuilder: (context, index) {
                    // get individual expense
                    Expense individualExpense = value.allExpenses[index];
                    return ListTile(
                      title: Text(individualExpense.name),
                      trailing: Text(individualExpense.amount.toString()),
                    );
                  }),
            ));
  }

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
          //   clear controllers
          nameController.clear();
          amountController.clear();
        }
      },
      child: const Text('Save'),
    );
  }
}
