import 'package:flutter/material.dart';

class FlutterUtils {

  static void showSnackBar(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }

  static void showErrorSnackBar(BuildContext context, Object? error) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        action: SnackBarAction(
          label: 'Dispensar',
          onPressed: () {},
        ),
        backgroundColor: Colors.red,
        content: Text('Erro: ${error.toString()}'),
        duration: const Duration(seconds: 10),
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
