import 'package:flutter/material.dart';

class FullScreenLoading {
  late BuildContext context;

  FullScreenLoading(this.context);

  // this is where you would do your fullscreen loading
  Future<void> start() async {
    return await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const SimpleDialog(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          // can change this to your prefered color
          children: <Widget>[
            Center(
              child: CircularProgressIndicator(),
            )
          ],
        );
      },
    );
  }

  Future<void> stop() async {
    Navigator.of(context).pop();
  }
}
