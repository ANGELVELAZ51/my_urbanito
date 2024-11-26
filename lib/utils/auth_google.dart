import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthGoogle {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '965311815504-mntqir0rubkla8krvkmnn6svhtfq086o.apps.googleusercontent.com', // Configura el Client ID aquí
  );

  Future loginGoogle() async {
    try {
      final accountGoogle = await GoogleSignIn().signIn();
      if (accountGoogle == null) {
        print("Google SignIn Cancelado");
        return null;
      }

      final googleAuth = await accountGoogle.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      print("Usuario autenticado: ${userCredential.user?.displayName}");

      return userCredential.user;
    } catch (e) {
      print("Error en login con Google: $e");
      return null;
    }
  }
}
