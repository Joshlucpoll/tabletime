import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Services
import '../services/auth.dart';

class Login extends StatefulWidget {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  const Login({Key key, this.auth, this.firestore}) : super(key: key);

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
                  width: MediaQuery.of(context).size.shortestSide * 0.3,
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
                      onPressed: () async {
                        final String retVal = await Auth(
                                auth: widget.auth, firestore: widget.firestore)
                            .signIn(
                          email: _emailController.text,
                          password: _passwordController.text,
                        );
                        if (retVal != "Success") {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(retVal),
                            ),
                          );
                        }
                      },
                      child: const Text("Sign In"),
                    ),
                    SizedBox(height: 5.0),
                    FlatButton(
                      key: const ValueKey("createAccount"),
                      onPressed: () async {
                        final String retVal = await Auth(
                                auth: widget.auth, firestore: widget.firestore)
                            .createAccount(
                          email: _emailController.text,
                          password: _passwordController.text,
                        );
                        if (retVal == "Success") {
                          _emailController.clear();
                          _passwordController.clear();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(retVal),
                            ),
                          );
                        }
                      },
                      child: Text(
                        "Create Account",
                      ),
                    )
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
