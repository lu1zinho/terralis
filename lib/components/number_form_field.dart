import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberFormField extends StatelessWidget {
  const NumberFormField({
    Key? key,
    required this.label,
    this.controller,
    this.value,
    this.onChanged,
    this.validator,
    this.error,
    this.icon,
    this.style,
    this.allowDecimal = false,
    this.enabled = true,
  }) : super(key: key);

  final TextEditingController? controller;
  final String? value;
  final String label;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final String? error;
  final Widget? icon;
  final bool allowDecimal;
  final TextStyle? style;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: enabled,
      controller: controller,
      initialValue: value,
      validator: validator,
      onChanged: onChanged,
      keyboardType: TextInputType.numberWithOptions(decimal: allowDecimal),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(_getRegexString())),
        TextInputFormatter.withFunction(
          (oldValue, newValue) => newValue.copyWith(
            text: newValue.text.replaceAll(',', '.'),
          ),
        ),
      ],
      decoration: InputDecoration(
        label: Text(label),
        errorText: error,
        icon: icon,
      ),
      style: style,
    );
  }

  String _getRegexString() =>
      allowDecimal ? r'[0-9]+[,.]{0,1}[0-9]*' : r'[0-9]';
}
