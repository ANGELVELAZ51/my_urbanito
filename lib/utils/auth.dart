import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Método para crear una cuenta
  Future<Object?> createAccount(String name, String correo, String pass) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: correo,
        password: pass,
      );
      if (userCredential.user != null) {
        await userCredential.user?.sendEmailVerification();
        return userCredential.user?.uid;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == "weak-password") {
        return 1; // Contraseña débil
      } else if (e.code == 'email-already-in-use') {
        return 2; // Correo ya en uso
      } else if (e.code == 'firebase_email_not_sent') {
        return 3; // Correo no enviado
      }
    } catch (e) {
      print(e);
      return 3; // Otro error
    }
    return null;
  }

  // Método para iniciar sesión con correo y contraseña
  Future<Object?> signInEmailAndPassword(String correo, String pass) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: correo,
        password: pass,
      );
      if (userCredential.user != null) {
        if (userCredential.user!.emailVerified) {
          return userCredential.user?.uid;
        } else {
          return 4; // Correo no verificado
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 1; // Usuario no encontrado
      } else if (e.code == 'wrong-password') {
        return 2; // Contraseña incorrecta
      }
    }
    return null;
  }

  // Método para enviar un correo de recuperación de contraseña
  Future<Object?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return 0; // Éxito
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        return 1; // Correo inválido
      } else if (e.code == 'user-not-found') {
        return 2; // Usuario no encontrado
      }
    } catch (e) {
      print(e);
      return 3; // Otro tipo de error
    }
    return null;
  }

  Future<Object?> resendVerificationEmail() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
      return 0; // Éxito
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 1; // Usuario no encontrado
      } else if (e.code == 'invalid-email') {
        return 2; // Correo inválido
      }
    } catch (e) {
      print(e);
      return 3; // Otro error
    }
    return null;
  }
}
