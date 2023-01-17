import 'package:flutter/material.dart';

class MessageDialog extends StatelessWidget {
  final String title;
  final String message;
  final String errorMessage;
  final String buttonText;
  final IconData? icon;
  final Color colorIcon;

  const MessageDialog({
    this.title = '',
    this.message = '',
    this.errorMessage = '',
    this.icon,
    this.buttonText = 'OK',
    this.colorIcon = Colors.black,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Visibility(
        child: Text(title),
        visible: title.isNotEmpty,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Visibility(
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Icon(
                icon,
                size: 64,
                color: colorIcon,
              ),
            ),
            visible: icon != null,
          ),
          Visibility(
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24.0,
                ),
              ),
            ),
            visible: message.isNotEmpty,
          ),
          Visibility(
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ),
            visible: errorMessage.isNotEmpty,
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: Text(buttonText),
          onPressed: () => Navigator.pop(context),
        )
      ],
    );
  }
}

class SuccessMessageDialog extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;

  const SuccessMessageDialog({
    this.message = '',
    this.title = '',
    this.icon = Icons.done,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MessageDialog(
      title: title,
      message: message,
      icon: icon,
      colorIcon: Colors.green,
    );
  }
}

class WarningMessageDialog extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;

  const WarningMessageDialog({
    this.message = '',
    this.title = 'Aviso',
    this.icon = Icons.warning,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MessageDialog(
      title: title,
      message: message,
      icon: icon,
      colorIcon: Colors.yellow,
    );
  }
}

class FailureMessageDialog extends StatelessWidget {
  final String title;
  final String message;
  final String errorMessage;
  final IconData icon;

  const FailureMessageDialog({
    this.message = '',
    this.errorMessage = '',
    this.title = '',
    this.icon = Icons.error,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MessageDialog(
      title: title,
      message: message,
      errorMessage: errorMessage,
      icon: icon,
      colorIcon: Colors.red,
    );
  }
}
