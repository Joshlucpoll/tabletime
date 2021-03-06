import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              "assets/images/tabletime_logo.png",
              width: MediaQuery.of(context).size.shortestSide * 0.6,
            ),
            CircularProgressIndicator.adaptive(),
          ],
        ),
      ),
    );
  }
}
