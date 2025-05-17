import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //register
  Future<User?> register(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
        );
      return result.user;
    } catch (e) {
      print("Error register: $e");
      return null;
    }
  }

  //login
  Future<User?> login(String email, String password) async{
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email, password: password
        );
      return result.user;
    } catch (e) {
      print("Error login: $e");
      return null;
    }
  }


  //logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  //check user login atau nggak
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}