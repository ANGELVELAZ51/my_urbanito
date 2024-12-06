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

  @override
  void initState() {
    super.initState();
    _setupRouteVisualization();
  }

  void _setupRouteVisualization() {
    // Extract coordinates from the route
    LatLng origen = widget.route['coordsOrigen'];
    LatLng destino = widget.route['coordsDestino'];

    // Create markers for origin and destination
    _markers.addAll([
      Marker(
        markerId: MarkerId('origin'),
        position: origen,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(title: 'Origen: ${widget.route['origen']}'),
      ),
      Marker(
        markerId: MarkerId('destination'),
        position: destino,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: 'Destino: ${widget.route['destino']}'),
      ),
    ]);

    // Create polyline connecting origin and destination
    _polylines.add(
      Polyline(
        polylineId: PolylineId('route'),
        color: Colors.blue,
        width: 5,
        points: [origen, destino],
      ),
    );

    // Start at origin
    _currentPosition = origen;

    // Simulate vehicle movement
    _startVehicleMovement();
  }

  void _startVehicleMovement() {
    LatLng origen = widget.route['coordsOrigen'];
    LatLng destino = widget.route['coordsDestino'];

    _movementTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (_currentPosition == null) return;

      // Simple linear interpolation for movement
      double lat = _currentPosition!.latitude +
          (destino.latitude - origen.latitude) * 0.05;
      double lng = _currentPosition!.longitude +
          (destino.longitude - origen.longitude) * 0.05;

      setState(() {
        _currentPosition = LatLng(lat, lng);

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

      // Stop movement when close to destination
      if (_isCloseToDestination(destino)) {
        timer.cancel();
      }
    });
  }

  bool _isCloseToDestination(LatLng destination) {
    const double threshold = 0.0001; // Adjust based on your precision needs
    return ((_currentPosition!.latitude - destination.latitude).abs() <
            threshold &&
        (_currentPosition!.longitude - destination.longitude).abs() <
            threshold);
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
        title: Text(
            'Ruta: ${widget.route['origen']} → ${widget.route['destino']}'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: widget.route['coordsOrigen'],
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
