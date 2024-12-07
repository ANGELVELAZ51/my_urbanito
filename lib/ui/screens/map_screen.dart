import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'dart:math';

class MapScreen extends StatefulWidget {
  final Map<String, dynamic> route;

  const MapScreen({Key? key, required this.route}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  LatLng? _currentPosition;
  Timer? _movementTimer;
  bool _destinationReached = false;

  List<LatLng> _routePoints = [];
  int _currentPointIndex = 0;

  @override
  void initState() {
    super.initState();
    _setRoutePoints();
    _setupRouteVisualization();
  }

  void _setRoutePoints() {
    switch ('${widget.route['origen']} - ${widget.route['destino']}') {
      case 'Cinepolis - Central':
        _routePoints = [
          LatLng(21.159630, -100.929378), // Cinepolis
          LatLng(21.16049, -100.93155), // Punto 1
          LatLng(21.15571, -100.93358), // Punto 2
          LatLng(21.15645, -100.93562), // Punto 3
          LatLng(21.155034, -100.936309) // Central
        ];
        break;
      case 'Museo Jose Alfredo - Monumento a los Heroes':
        _routePoints = [
          LatLng(21.15733, -100.93275), // Museo
          LatLng(21.157379, -100.932891), // Punto
          LatLng(21.15645, -100.93328), // Punto 1
          LatLng(21.15403, -100.92687), // Punto 2
          LatLng(21.15491, -100.92652), // Punto 3
          LatLng(21.15475, -100.92564), // Punto 4
          LatLng(21.15768, -100.91804), // Punto 5
          LatLng(21.15801, -100.91657) // Monumento a los Heroes
        ];
        break;
      case 'Universidad UTNG - Centro':
      default:
        _routePoints = [
          LatLng(21.16763, -100.93270), // Universidad
          LatLng(21.16442, -100.93322), // Punto intermedio 1
          LatLng(21.16119, -100.93340), // Punto intermedio 2
          LatLng(21.15494, -100.93655) // Centro
        ];
        break;
    }
  }

  void _setupRouteVisualization() {
    // Create polyline connecting route points
    _polylines.add(
      Polyline(
        polylineId: PolylineId('route'),
        color: Colors.blue,
        width: 5,
        points: _routePoints,
      ),
    );

    // Create markers for origin and destination
    _markers.addAll([
      Marker(
        markerId: MarkerId('origin'),
        position: _routePoints.first,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(title: 'Origen: ${widget.route['origen']}'),
      ),
      Marker(
        markerId: MarkerId('destination'),
        position: _routePoints.last,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: 'Destino: ${widget.route['destino']}'),
      ),
    ]);

    // Start at origin
    _currentPosition = _routePoints.first;
    _startVehicleMovement();
  }

  void _startVehicleMovement() {
    _movementTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (_currentPointIndex < _routePoints.length - 1) {
        LatLng currentPoint = _routePoints[_currentPointIndex];
        LatLng nextPoint = _routePoints[_currentPointIndex + 1];

        // Calculate direction and distance
        double dx = nextPoint.longitude - currentPoint.longitude;
        double dy = nextPoint.latitude - currentPoint.latitude;
        double distance = sqrt(dx * dx + dy * dy);

        // Move a small fraction towards next point
        double moveFraction = 0.020; // Adjust for speed
        double newLat = _currentPosition!.latitude + (dy * moveFraction);
        double newLng = _currentPosition!.longitude + (dx * moveFraction);

        setState(() {
          _currentPosition = LatLng(newLat, newLng);

          // Update urban vehicle marker
          _markers.removeWhere((marker) => marker.markerId.value == 'vehicle');
          _markers.add(
            Marker(
              markerId: MarkerId('vehicle'),
              position: _currentPosition!,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueOrange),
              infoWindow: InfoWindow(title: 'Urbano en Tránsito'),
            ),
          );

          // Animate camera to follow vehicle
          _mapController.animateCamera(
            CameraUpdate.newLatLng(_currentPosition!),
          );
        });

        // Check if we've reached the next point
        if (_isCloseToPoint(nextPoint)) {
          _currentPointIndex++;
        }

        // Stop movement when reached last point
        if (_currentPointIndex == _routePoints.length - 1) {
          timer.cancel();
          if (!_destinationReached) {
            _destinationReached = true;
            _showDestinationNotification(context);
          }
        }
      }
    });
  }

  bool _isCloseToPoint(LatLng point) {
    const double threshold = 0.0005; // Adjust precision as needed
    return ((_currentPosition!.latitude - point.latitude).abs() < threshold &&
        (_currentPosition!.longitude - point.longitude).abs() < threshold);
  }

  void _showDestinationNotification(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.location_on, color: Colors.green, size: 30),
              SizedBox(width: 10),
              Text(
                '¡Destino Alcanzado!',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.green[800]),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ruta: ${widget.route['origen']} → ${widget.route['destino']}',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 10),
              Text(
                '¡Tu viaje con Mi Urbanito ha finalizado con éxito! \n'
                'Gracias por elegirnos para tu transporte. \n'
                '🚌✨ ¡Buen día!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Cerrar', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _movementTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.route['origen']} → ${widget.route['destino']}'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _routePoints.first,
          zoom: 14.0,
        ),
        markers: _markers,
        polylines: _polylines,
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
      ),
    );
  }
}
