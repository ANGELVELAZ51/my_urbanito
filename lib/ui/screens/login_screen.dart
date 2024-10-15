import 'package:flutter/material.dart';
import 'package:my_urbanito/ui/screens/password_recovery_screen.dart';
import 'package:my_urbanito/ui/screens/register_screen.dart';
import 'dart:ui'; // Importar para el filtro de desenfoque

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/gifmapa.gif'), // Imagen de fondo
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0), // Borde redondeado
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                      sigmaX: 10.0, sigmaY: 10.0), // Desenfoque
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white
                          .withOpacity(0.3), // Transparencia del fondo
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2), // Bordes ligeros
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
                            onSaved: (value) => _email = value!,
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
                            onSaved: (value) => _password = value!,
                          ),
                          SizedBox(height: 24),
                          ElevatedButton(
                            child: Text('Iniciar sesión'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              textStyle: TextStyle(
                                color: Colors.white,
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 15),
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                // Aquí iría la lógica de inicio de sesión
                                print('Email: $_email, Password: $_password');
                              }
                            },
                          ),
                          SizedBox(height: 16),
                          TextButton(
                            child: Text('¿Olvidaste tu contraseña?'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.black, // Texto negro
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        PasswordRecoveryScreen()),
                              );
                            },
                          ),
                          TextButton(
                            child: Text('Crear una cuenta'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.black, // Texto negro
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RegisterScreen()),
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
