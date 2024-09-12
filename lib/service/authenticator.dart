import 'package:firebase_auth/firebase_auth.dart';
import 'package:g2s/mock/g2s_error.dart';
import 'package:g2s/mock/g2s_log.dart';
import 'package:g2s/mock/g2s_user.dart';
import 'package:g2s/service/g2s_log_user.dart';
import 'package:g2s/service/g2s_user_db.dart';

class Authenticator {
  final _authentificator = FirebaseAuth.instance;

  Stream<G2SUser?> isAuthenticated() {
    return _authentificator.authStateChanges().asyncMap<G2SUser?>((User? user) {
      if (user != null) {
        return G2SUserDB().getUser(uid: user.uid);
      }
      return null;
    });
  }

  Future<String?> createG2SUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential =
          await _authentificator.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        G2SLog g2sLog = G2SLog(
          uid: user.uid,
          order: 'createUser(UID:${user.uid})',
          description: 'Create a new user in the authentificator.',
          created: DateTime.now(),
        );
        await G2SLogUser().putLogUser(g2sLog: g2sLog);
        user.sendEmailVerification();
        return user.uid;
      }

      return null;
    } on FirebaseAuthException catch (except) {
      return Future.error(G2SError(code: except.code, message: except.message));
    }
  }

  Future<G2SUser?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential =
          await _authentificator.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null && user.emailVerified) {
        G2SLog g2sLog = G2SLog(
          uid: user.uid,
          order: 'logInUser(UID:${user.uid})',
          description: 'sign in a new user in the app',
          created: DateTime.now(),
        );
        await G2SLogUser().putLogUser(g2sLog: g2sLog);
        await G2SUserDB().updateLastLogin(uid: user.uid);
        return G2SUserDB().getUser(uid: user.uid);
      } else {
        _authentificator.signOut();
      }

      return null;
    } on FirebaseAuthException catch (except) {
      return Future.error(G2SError(code: except.code, message: except.message));
    }
  }

  Future<void> resetAndUpdatePassword({required String email}) {
    return _authentificator.sendPasswordResetEmail(email: email).then(
      (value) {
        G2SLog g2sLog = G2SLog(
          uid: email,
          order: "resetPassword(UID:$email)",
          description: "sending a password reset email",
          created: DateTime.now(),
        );
        G2SLogUser().putLogUser(g2sLog: g2sLog);
      },
    );
  }

  Future<void> signOutG2SUser() {
    return _authentificator.signOut();
  }
}
