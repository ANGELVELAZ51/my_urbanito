// custom_header.dart
import 'package:flutter/material.dart';

class CustomHeader extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final String userName; // Nuevo parámetro para el nombre de usuario

  const CustomHeader({
    Key? key,
    required this.title,
    required this.userName, required String nameController, // Nuevo parámetro requerido
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  State<CustomHeader> createState() => _CustomHeaderState();
}

class _CustomHeaderState extends State<CustomHeader> {
  void _navigateToSettings() {
    Navigator.pushNamed(context, '/settings');
  }

  void _navigateToProfile() {
    Navigator.pushNamed(context, '/profile');
  }

  void _handleLogout() {
    // Implementa aquí la lógica para cerrar sesión
    // Por ejemplo:
    // AuthService.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      title: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            margin: EdgeInsets.only(right: 8),
            child: Image.asset(
              'assets/Logo.png',
              fit: BoxFit.contain,
            ),
          ),
          Text(
            widget.title,
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.settings, color: Colors.black),
          onPressed: _navigateToSettings,
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.person, color: Colors.black),
          onSelected: (value) {
            if (value == 'profile') {
              _navigateToProfile();
            } else if (value == 'logout') {
              _handleLogout();
            }
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  Icon(Icons.person_outline),
                  SizedBox(width: 8),
                  Text(widget.userName), // Usamos el nombre de usuario pasado como parámetro
                ],
              ),
            ),
            PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout),
                  SizedBox(width: 8),
                  Text('Cerrar sesión'),
                ],
              ),
            ),
          ],
        ),
        SizedBox(width: 8),
      ],
    );
  }
}