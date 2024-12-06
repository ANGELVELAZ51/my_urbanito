import 'package:flutter/material.dart';
import 'package:my_urbanito/ui/screens/password_recovery_screen.dart';
import 'package:my_urbanito/ui/screens/register_screen.dart';
import 'dart:ui';
import 'package:my_urbanito/utils/auth.dart';
import 'package:my_urbanito/utils/auth_google.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();
  final AuthGoogle _authGoogle = AuthGoogle();

  String _email = '';
  String _password = '';

  // Future<void> _signInWithGoogle() async {
  //   try {
  //     var user = await _authGoogle.loginGoogle();
  //     if (user != null) {
  //       Navigator.popAndPushNamed(context, '/home');
  //     } else {
  //       print("Error al iniciar sesión con Google");
  //     }
  //   } catch (e) {
  //     print("Error en loginGoogle: $e");
  //   }
  // }

  Future<void> _signInWithEmailPassword() async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      _formKey.currentState?.save();
      var result = await _auth.signInEmailAndPassword(_email, _password);

      if (result is String) {
        Navigator.popAndPushNamed(context, '/home');
      } else if (result == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuario no encontrado')),
        );
      } else if (result == 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Contraseña incorrecta')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error desconocido')),
        );
      }
    } else {
      print("Formulario inválido o nulo");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/gifmapa.gif'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    padding: EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          SizedBox(height: 20),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Correo electrónico',
                              prefixIcon: Icon(Icons.email),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingrese su correo electrónico';
                              }
                              return null;
                            },
                            onSaved: (value) => _email = value ?? '',
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: Icon(Icons.lock),
                              border: OutlineInputBorder(),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingrese su contraseña';
                              }
                              return null;
                            },
                            onSaved: (value) => _password = value ?? '',
                          ),
                          SizedBox(height: 24),
                          ElevatedButton(
                            child: Text('Iniciar sesión'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              textStyle: TextStyle(
                                color: Colors.white,
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                            ),
                            onPressed: _signInWithEmailPassword,
                          ),
                          // SizedBox(height: 16),
                          // ElevatedButton.icon(
                          //   onPressed: _signInWithGoogle,
                          //   icon: Icon(Icons.login),
                          //   label: Text('Iniciar sesión con Google'),
                          //   style: ElevatedButton.styleFrom(
                          //     backgroundColor: const Color.fromARGB(255, 24, 23, 80),
                          //     padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          //   ),
                          // ),
                          SizedBox(height: 16),
                          TextButton(
                            child: Text('¿Olvidaste tu contraseña?'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.black,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => PasswordRecoveryScreen()),
                              );
                            },
                          ),
                          TextButton(
                            child: Text('Crear una cuenta'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.black,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => RegisterScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}