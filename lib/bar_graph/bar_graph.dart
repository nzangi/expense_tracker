import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'individual_bar.dart';

class MyBarGraph extends StatefulWidget {
  final List<double> monthlySalary; //[25,500,600]
  final int startMonth; // 0 Jan 2 Feb ...
  const MyBarGraph(
      {super.key, required this.monthlySalary, required this.startMonth});

  @override
  State<MyBarGraph> createState() => _MyBarGraphState();
}

class _MyBarGraphState extends State<MyBarGraph> {
  // list to hold data for each category
  List<IndividualBar> barData = [];

  // initialize bar data
  void initializeData() {
    barData = List.generate(widget.monthlySalary.length,
        (index) => IndividualBar(x: index, y: widget.monthlySalary[index]));
  }

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        minY: 0,
        maxY: 100
      )
    );
  }
}
