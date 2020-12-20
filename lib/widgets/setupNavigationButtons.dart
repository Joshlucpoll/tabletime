import 'package:flutter/material.dart';

class SetupNavigationButtons extends StatelessWidget {
  final double pageIndex;
  final Function changePage;

  SetupNavigationButtons({Key key, this.pageIndex, this.changePage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Visibility(
          visible: pageIndex >= 0.1,
          child: Container(
            margin: EdgeInsets.all(10.0),
            child: IconButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                changePage(next: false);
              },
              splashRadius: 25.0,
              icon: Icon(Icons.arrow_back),
            ),
          ),
        ),
        Visibility(
          visible: pageIndex <= 2.9,
          child: Container(
            margin: EdgeInsets.all(10.0),
            child: IconButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                changePage(next: true);
              },
              splashRadius: 25.0,
              icon: Icon(Icons.arrow_forward),
            ),
          ),
        ),
      ],
    );
  }
}
