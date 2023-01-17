import 'package:flutter/material.dart';
import 'package:terralis/components/flutter_utils.dart';
import 'package:terralis/components/number_form_field.dart';

class QtUsedDialog extends StatefulWidget {
  final String _title;
  final double? _qtUsed;

  const QtUsedDialog(this._title, this._qtUsed, {Key? key}) : super(key: key);

  @override
  State<QtUsedDialog> createState() => _QtUsedDialogState();
}

class _QtUsedDialogState extends State<QtUsedDialog> {
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _textController.text = widget._qtUsed?.toStringAsFixed(2) ?? '';
    return AlertDialog(
      title: Text(widget._title),
      content: NumberFormField(
        validator: (value) => FlutterUtils.validateNotEmpty(value),
        controller: _textController,
        label: 'Qtd usado',
        style: const TextStyle(fontSize: 20.0),
        allowDecimal: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, _textController.text);
          },
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}
