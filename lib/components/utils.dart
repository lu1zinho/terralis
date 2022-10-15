import 'package:flutter/material.dart';

class Utils {
  static String dateToString(DateTime date) =>
      '${date.day}/${date.month}/${date.year}';

  static String numberToCommaString(num number) =>
      number.toStringAsFixed(2).replaceAll('.', ',');

  static void showSnackBar(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        // backgroundColor: Colors.red,
        content: Text(text),
      ),
    );
  }

  static String? validateNotEmpty(String? value) {
    if (value == null || value.isEmpty) {
      return 'Preenchimento obrigatório';
    }
    return null;
  }
}
