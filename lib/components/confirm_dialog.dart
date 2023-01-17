import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String description;

  const ConfirmDialog(this.title, this.description, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(description),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'cancel'),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, 'OK'),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
