import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

// Services
import '../services/auth.dart';

class Login extends StatefulWidget {
  final Auth _auth = GetIt.I.get<Auth>();

  Login({Key key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Image(
                  image: AssetImage("assets/images/tabletime_logo.png"),
                  width: MediaQuery.of(context).size.shortestSide * 0.2,
                ),
                Container(
                  constraints: BoxConstraints(maxWidth: 500),
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        key: const ValueKey("username"),
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.email), labelText: "Email"),
                        controller: _emailController,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        key: const ValueKey("password"),
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock),
                          labelText: "Password",
                          suffixIcon: Container(
                            padding: EdgeInsets.all(5.0),
                            child: IconButton(
                              onPressed: () => setState(() {
                                _passwordVisible = !_passwordVisible;
                              }),
                              icon: Icon(
                                _passwordVisible
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off,
                              ),
                            ),
                          ),
                        ),
                        obscureText: _passwordVisible,
                        controller: _passwordController,
                      ),
                    ],
                  ),
                ),
                Column(
                  children: <Widget>[
                    SizedBox(height: 20.0),
                    RaisedButton(
                      key: const ValueKey("signIn"),
                      onPressed: () => widget._auth
                          .signIn(
                            email: _emailController.text,
                            password: _passwordController.text,
                          )
                          .catchError(
                            (e) => ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.message),
                              ),
                            ),
                          ),
                      child: const Text("Sign In"),
                    ),
                    SizedBox(height: 5.0),
                    FlatButton(
                      key: const ValueKey("createAccount"),
                      onPressed: () => widget._auth
                          .createAccount(
                            email: _emailController.text,
                            password: _passwordController.text,
                          )
                          .catchError(
                            (e) => ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.message),
                              ),
                            ),
                          ),
                      child: Text(
                        "Create Account",
                      ),
                    ),
                    RaisedButton(
                      padding: EdgeInsets.all(0),
                      onPressed: () =>
                          widget._auth.signInWithGoogle().catchError(
                                (e) =>
                                    ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(e.message),
                                  ),
                                ),
                              ),
                      color: Color(0xFF3469C1),
                      textColor: Colors.white,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
