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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // backgroundColor: Theme.of(context).backgroundColor,
        body: Center(
            child: Padding(
                padding: const EdgeInsets.all(60.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      key: const ValueKey("username"),
                      decoration: InputDecoration(labelText: "Email"),
                      controller: _emailController,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      key: const ValueKey("password"),
                      decoration: InputDecoration(labelText: "Password"),
                      controller: _passwordController,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    RaisedButton(
                      key: const ValueKey("signIn"),
                      onPressed: () async {
                        final String retVal = await Auth(
                                auth: widget.auth, firestore: widget.firestore)
                            .signIn(
                          email: _emailController.text,
                          password: _passwordController.text,
                        );
                        if (retVal == "Success") {
                          _emailController.clear();
                          _passwordController.clear();
                        } else {
                          Scaffold.of(context).showSnackBar(
                            SnackBar(
                              content: Text(retVal),
                            ),
                          );
                        }
                      },
                      child: const Text("Sign In"),
                    ),
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
                          Scaffold.of(context).showSnackBar(
                            SnackBar(
                              content: Text(retVal),
                            ),
                          );
                        }
                      },
                      child: Text("Create Account"),
                    )
                  ],
                ))));
  }
}
