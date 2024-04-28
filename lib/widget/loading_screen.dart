import 'package:flutter/material.dart';

/// 加载页，可以自定义成骨架屏、默认图、或者loading
class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              color: Colors.black.withOpacity(0.5),
            ),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
