/*
 These are some of the helper functions
 */

double convertStringToDouble(String string){
  double? amount = double.tryParse(string);
  return amount ?? 0 ;
}