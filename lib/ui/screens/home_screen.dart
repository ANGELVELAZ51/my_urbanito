import 'package:flutter/material.dart';
import '../widgets/custom_header.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;

class HomeScreen extends StatelessWidget {
  final List<Map<String, dynamic>> rutasEnTransito = [
    {
      'origen': 'Universidad UTNG',
      'destino': 'Centro',
      'hora': '12:30 - 13:00',
      'coordsOrigen': LatLng(21.16763, -100.93270),
      'coordsDestino': LatLng(21.15494, -100.93655)
    },
    {
      'origen': 'Cinepolis',
      'destino': 'Central',
      'hora': '12:45 - 13:15',
      'coordsOrigen': LatLng(21.16006, -100.92914),
      'coordsDestino': LatLng(21.15494, -100.93655)
    },
    {
      'origen': 'Museo Jose Alfredo',
      'destino': 'Monumento a los Heroes',
      'hora': '13:00 - 13:30',
      'coordsOrigen': LatLng(21.15733, -100.93275),
      'coordsDestino': LatLng(21.15801, -100.91657)
    },
  ];

  final List<Map<String, dynamic>> proximasRutas = [
    {
      'origen': 'Centro',
      'destino': 'Fracc GTO',
      'hora': '13:00 - 13:30',
      'coordsOrigen': LatLng(21.15494, -100.93655),
      'coordsDestino': LatLng(21.16763, -100.93270)
    },
    {
      'origen': 'Plaza',
      'destino': 'Terminal',
      'hora': '13:15 - 13:45',
      'coordsOrigen': LatLng(21.16006, -100.92914),
      'coordsDestino': LatLng(21.15494, -100.93655)
    },
    {
      'origen': 'Hospital',
      'destino': 'Universidad',
      'hora': '13:30 - 14:00',
      'coordsOrigen': LatLng(21.15733, -100.93275),
      'coordsDestino': LatLng(21.15801, -100.91657)
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomHeader(
        title: 'Mi Urbanito',
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Colors.blue.shade50],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Bienvenido a',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                'Mi Urbanito',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF045FAA),
                ),
              ),
              SizedBox(height: 30),
              _buildRouteSection(
                'Rutas en Tránsito',
                rutasEnTransito,
                Colors.blue.shade700,
                Icons.directions_bus,
                context,
              ),
              SizedBox(height: 20),
              _buildRouteSection(
                'Próximas Rutas',
                proximasRutas,
                Colors.green.shade700,
                Icons.schedule,
                context,
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouteSection(
    String title,
    List<Map<String, dynamic>> routes,
    Color color,
    IconData icon,
    BuildContext context,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: color, size: 24),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          ...routes
              .map((route) => _buildRouteCard(route, color, context))
              .toList(),
          SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildRouteCard(
      Map<String, dynamic> route, Color color, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/map',
          arguments: {
            'route': route,
          },
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${route['origen']} → ${route['destino']}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(left: 16),
                child: Text(
                  route['hora']!,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
