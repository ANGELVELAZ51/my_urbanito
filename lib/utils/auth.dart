import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Modificado para aceptar nombre, correo y contraseña
  Future<Object?> createAccount(String name, String correo, String pass) async {
    try {
      // Crear la cuenta con el correo y la contraseña
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: correo,
        password: pass,
      );

      print(userCredential.user); // Mostrar información del usuario creado
      return userCredential.user?.uid; // Retornar el UID del usuario
    } on FirebaseAuthException catch (e) {
      if (e.code == "weak-password") {
        print("La contraseña es demasiado débil");
        return 1; // Representa una contraseña débil
      } else if (e.code == 'email-already-in-use') {
        print('La cuenta ya existe para ese correo');
        return 2; // Representa un correo ya en uso
      }
    } catch (e) {
      print(e);
      return 3; // Otro tipo de error
    }
    return null; // Devuelve null si no se cumple ninguna condición
  }

  // Método para iniciar sesión con correo y contraseña
  Future singInEmailAndPassword(String correo, String pass) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: correo,
        password: pass,
      );

      final a = userCredential.user;
      if (a?.uid != null) {
        return a?.uid;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 1; // Usuario no encontrado
      } else if (e.code == 'wrong-password') {
        return 2; // Contraseña incorrecta
      }
    }
  }
}
