import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get_it/get_it.dart';
import './database.dart';

class Auth {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Stream<User> get user => auth.authStateChanges();

  String get uid => auth.currentUser.uid;

  Future<UserCredential> createAccount({String email, String password}) async {
    UserCredential userCredential = await auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    if (userCredential.additionalUserInfo.isNewUser) {
      await GetIt.I.get<Database>().addUser();
    }
    return userCredential;
  }

  Future<UserCredential> signIn({String email, String password}) async {
    return await auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

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
