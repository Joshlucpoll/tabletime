import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';
import 'dart:io';

import 'localDatabase.dart';

class AuthCred {
  final User user;
  final bool local;

  AuthCred({this.user, this.local});
}

class Auth {
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool localAccount = false;
  StreamController<AuthCred> _onChangeController;
  Stream<AuthCred> _onChange;

  Auth() {
    _onChangeController = StreamController();
    _onChange = _onChangeController.stream.asBroadcastStream();
    _initialiseAuth();
  }

  Future<void> _initialiseAuth() async {
    await _updateAuthCredStream(user: null);

    user.listen((User user) async {
      await _updateAuthCredStream(user: user);
    });
  }

  Future<void> _updateAuthCredStream({User user, bool local = false}) async {
    bool exists;

    if (!kIsWeb) {
      if (local == false) {
        File file = await LocalDatabase().localFile;
        exists = await file.exists();
      } else {
        exists = local;
      }
    } else {
      exists = false;
    }

    localAccount = exists;

    _onChangeController.add(AuthCred(user: user, local: exists));
  }

  Stream<User> get user => auth.authStateChanges();

  Stream<AuthCred> get authCred => _onChange;

  String get uid => auth.currentUser.uid;

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    UserCredential userCredential = await auth.signInWithCredential(credential);
    return userCredential;
  }

  Future<void> createLocalAccount() async {
    await _updateAuthCredStream(user: null, local: true);
  }

  Future<String> signOut() async {
    try {
      await auth.signOut();
      return "Success";
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      rethrow;
    }
  }
}
