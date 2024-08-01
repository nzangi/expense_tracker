/*
 These are some of the helper functions
 */

import 'package:intl/intl.dart';

double convertStringToDouble(String string){
  double? amount = double.tryParse(string);
  return amount ?? 0 ;
}

// format double amount to dollars
String formatAmount(double amount){
  final format = NumberFormat.currency(locale: "en_US",symbol: "KSH ",decimalDigits: 2);
  return format.format(amount);
}

//calculate the number of months since the first month
int calculateMonthCount(int startYear,startMonth,currentYear,currentMonth){
  int monthCount = (currentYear - startYear) * 12 + currentMonth -startMonth +1;
  return monthCount;
}
