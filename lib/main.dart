
import 'package:expense_tracker/database/expense_database.dart';
import 'package:expense_tracker/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // initialize db
  await ExpenseDatabase.initialize();
  runApp(ChangeNotifierProvider(
      create: (context) => ExpenseDatabase(),
      child: const ExpenseTrackerApp())
    );
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
