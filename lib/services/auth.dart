import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  final FirebaseAuth auth;

  Auth(this.auth);

  Stream<User> get user => auth.authStateChanges();
}
