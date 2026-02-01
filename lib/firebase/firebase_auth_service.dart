import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// ================= EMAIL LOGIN =================
  Future<User?> login({
    required String email,
    required String password,
  }) async {
    final UserCredential result =
        await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  /// ================= EMAIL REGISTER =================
  Future<User?> register({
    required String email,
    required String password,
  }) async {
    final UserCredential result =
        await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  /// ================= GOOGLE LOGIN =================
  Future<User?> signInWithGoogle() async {
    // 🔥 FORCE ACCOUNT PICKER EVERY TIME
    await _googleSignIn.signOut();

    final GoogleSignInAccount? googleUser =
        await _googleSignIn.signIn();

    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential =
        GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential result =
        await _auth.signInWithCredential(credential);

    return result.user;
  }

  /// ================= LOGOUT =================
  Future<void> logout() async {
    await _googleSignIn.signOut(); // Google logout
    await _auth.signOut();         // Firebase logout
  }

  /// ================= CURRENT USER =================
  User? get currentUser => _auth.currentUser;
}
