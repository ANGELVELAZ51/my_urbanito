import 'package:flutter/material.dart';

class MapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mapa de Rutas'),
      ),
      body: Center(
        child: Text('Aquí irá el mapa con las rutas'),
      ),
    );
  }
}
