import 'package:flutter/material.dart';

class RouteDetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles de la Ruta'),
      ),
      body: Center(
        child: Text('Detalles de la ruta seleccionada'),
      ),
    );
  }
}
