import 'package:flutter/material.dart';

class CenteredMessage extends StatelessWidget {
  final String message;
  final String message2;
  final IconData? icon;
  final double iconSize;
  final double fontSize;

  const CenteredMessage(
    this.message, {
    this.message2 = '',
    this.icon,
    this.iconSize = 64,
    this.fontSize = 24,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Visibility(
            child: Icon(
              icon,
              size: iconSize,
            ),
            visible: icon != null,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: Text(
              message,
              style: TextStyle(fontSize: fontSize),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              message2,
              style: TextStyle(fontSize: fontSize-8),
            ),
          ),
        ],
      ),
    );
  }
}
