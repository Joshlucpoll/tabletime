import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

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
                  onPressed: () => _auth.signInWithGoogle().catchError(
                        (e) => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.message),
                          ),
                        ),
                      ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.only(right: 10),
                        color: Colors.white,
                        child: Image(
                          image: AssetImage("assets/images/google_logo.png"),
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
        ),
      ),
    );
  }
}
