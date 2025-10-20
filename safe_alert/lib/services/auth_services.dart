import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserModel?> signUp(String name, String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    final user = credential.user;
    if (user != null) {
      await user.updateDisplayName(name);
      return UserModel(id: user.uid, name: name, email: user.email!, alertTime: 5);
    }
    return null;
  }

  Future<UserModel?> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    final user = credential.user;
    if (user != null) {
      return UserModel(id: user.uid, name: user.displayName ?? '', email: user.email!, alertTime: 5);
    }
    return null;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}
