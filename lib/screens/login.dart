import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/foundation.dart';

// Services
import '../services/auth.dart';

class Login extends StatelessWidget {
  final Auth _auth = GetIt.I.get<Auth>();
  Login({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Image(
                        image: AssetImage("assets/images/tabletime_logo.png"),
                        width: MediaQuery.of(context).size.shortestSide * 0.3,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xFF3469C1),
                          onPrimary: Colors.white,
                          padding: EdgeInsets.all(0),
                        ),
                        onPressed: () =>
                            _auth.signInWithGoogle().catchError((e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.message),
                            ),
                          );
                        }),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              margin: EdgeInsets.only(right: 10),
                              color: Colors.white,
                              child: Image(
                                image:
                                    AssetImage("assets/images/google_logo.png"),
                                height: 18,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(right: 10),
                              child: Text("Sign in with Google"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: !kIsWeb,
                  child: OutlinedButton(
                    onPressed: () => showModalBottomSheet(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20.0),
                        ),
                      ),
                      context: context,
                      builder: (BuildContext context) => Container(
                        padding: EdgeInsets.only(
                          left: 24,
                          right: 24,
                          bottom: 24,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 10, bottom: 9),
                              width: 30,
                              height: 5,
                              decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(5),
                                  color: Theme.of(context).splashColor),
                            ),
                            Text(
                              "Use without an account?",
                              style: Theme.of(context).textTheme.headline6,
                            ),
                            Padding(padding: EdgeInsets.all(20)),
                            Text(
                              "Tabletime is at its best when used with a Google account.\nHere are some of the features you're missing out on:\n\n - Cloud data sync\n - Use of web app",
                            ),
                            Text(
                              "\nTimetable data may be lost when app is uninstalled if you proceed",
                              style: TextStyle(
                                color: Colors.red,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            Padding(padding: EdgeInsets.all(20)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                OutlinedButton(
                                  style: TextButton.styleFrom(
                                    primary: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .color,
                                  ),
                                  child: Text("Go back"),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                                OutlinedButton(
                                  child: Text("Continue"),
                                  onPressed: () async {
                                    _auth.createLocalAccount();
                                    Navigator.of(context).pop();
                                  },
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    child: Text("Use without account"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
