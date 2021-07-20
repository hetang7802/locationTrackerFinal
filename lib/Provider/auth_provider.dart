import 'package:firebase_auth/firebase_auth.dart';

class AuthClass {

  FirebaseAuth auth= FirebaseAuth.instance;

  //Create Account
  Future<String> createAccount({ required String name, required String email,required String password}) async{
    try {
      await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
      );
      auth.currentUser.updateProfile(displayName: name);
      return "Account Created";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      }
    } catch (e) {
      return "Error occured";
    }
    return "Error occured";
  }

  //Sign in user
  Future<String> signIn({required String email,required String password}) async{
    try {
      await auth.signInWithEmailAndPassword(
          email: email,
          password: password
      );
      return "Welcome";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for that user.';
      }
    }
    return "Error occured";
  }



  //Reset Password
  Future<String> resetPassword({required String email}) async{
    try {
      await auth.sendPasswordResetEmail(
        email: email,
      );
      return "Email Sent";
    } catch (e) {
      return 'Error Occured';
    }
  }



  //SignOut
  void signOut(){
    auth.signOut();

  }


}