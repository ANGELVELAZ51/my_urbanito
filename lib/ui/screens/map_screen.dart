import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart';

class MapScreen extends StatefulWidget {
  final Map<String, String>? routeData;

  const MapScreen({Key? key, this.routeData}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  // Definir todas las rutas posibles
  final Map<String, Map<String, dynamic>> _routes = {
    'universidad-centro': {
      'start': const LatLng(21.16763, -100.93270),
      'end': const LatLng(21.15775, -100.93502),
      'name': 'Universidad - Centro'
    },
    'centro-terminal': {
      'start': const LatLng(21.15775, -100.93502),
      'end': const LatLng(21.1527, -100.9364),
      'name': 'Centro - Terminal'
    },
    'terminal-universidad': {
      'start': const LatLng(21.1527, -100.9364),
      'end': const LatLng(21.16763, -100.93270),
      'name': 'Terminal - Universidad'
    },
  };

  late LatLng _startLocation;
  late LatLng _endLocation;
  late String _routeName;
  LatLng _defaultLocation =
      const LatLng(21.1559, -100.9348); // Centro de Dolores
  LatLng? _busLocation;
  LatLng? _userLocation;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  Timer? _busUpdateTimer;
  List<LatLng> _routePolylinePoints = [];
  int _currentRoutePointIndex = 0;
  bool _isLoading = true;
  Location location = Location();

  @override
  void initState() {
    super.initState();
    _initializeSelectedRoute();
    _getCurrentLocation();
  }

  void _initializeSelectedRoute() {
    // Obtener la ruta seleccionada del routeData
    String selectedRoute = widget.routeData?['route'] ?? 'universidad-centro';
    var routeInfo = _routes[selectedRoute]!;

    _startLocation = routeInfo['start']!;
    _endLocation = routeInfo['end']!;
    _routeName = routeInfo['name'] as String;
    _defaultLocation = LatLng(
      (_startLocation.latitude + _endLocation.latitude) / 2,
      (_startLocation.longitude + _endLocation.longitude) / 2,
    );

    _initializeRoute();
  }

  @override
  void dispose() {
    _busUpdateTimer?.cancel();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationData locationData = await location.getLocation();
      setState(() {
        _userLocation = LatLng(locationData.latitude!, locationData.longitude!);
        _addMarker(
          _userLocation!,
          "Mi ubicación",
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          "Tu ubicación actual",
        );
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> _initializeRoute() async {
    try {
      // Inicializar la ubicación del autobús en el punto de partida
      _busLocation = _startLocation;

      // Agregar marcadores para el punto de salida y destino
      _addMarker(
        _startLocation,
        'Salida',
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        'Punto de salida',
      );

      _addMarker(
        _endLocation,
        'Destino',
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        'Destino final',
      );

      // Obtener y dibujar la ruta entre los puntos
      await _getRouteBetweenPoints();

      if (_routePolylinePoints.isNotEmpty) {
        _startBusSimulation();
      }
    } catch (e) {
      print('Error initializing route: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getRouteBetweenPoints() async {
    try {
      PolylinePoints polylinePoints = PolylinePoints();
      List<LatLng> allPoints = [];

      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        'AIzaSyDeQ9eyjSW0dU8-tUwJJ4-R2U2-PjuHj3g', // Reemplaza con tu API key
        PointLatLng(_startLocation.latitude, _startLocation.longitude),
        PointLatLng(_endLocation.latitude, _endLocation.longitude),
        travelMode: TravelMode.driving,
        optimizeWaypoints: true,
      );

      if (result.points.isNotEmpty) {
        allPoints.addAll(result.points
            .map((point) => LatLng(point.latitude, point.longitude)));
      }

      setState(() {
        _routePolylinePoints = allPoints;
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('busRoute'),
            color: Colors.blue,
            points: allPoints,
            width: 5,
            patterns: [
              PatternItem.dash(20),
              PatternItem.gap(10),
            ],
          ),
        );
      });

      await _updateCameraToShowRoute();
    } catch (e) {
      print('Error getting route: $e');
    }
  }

  void _startBusSimulation() {
    if (_routePolylinePoints.isEmpty) return;

    _busUpdateTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          if (_currentRoutePointIndex < _routePolylinePoints.length) {
            _busLocation = _routePolylinePoints[_currentRoutePointIndex];
            _updateBusMarker();
            _currentRoutePointIndex++;
          } else {
            _currentRoutePointIndex = 0;
          }
        });
      }
    });
  }

  void _updateBusMarker() {
    if (_busLocation != null) {
      _addMarker(
        _busLocation!,
        "Autobús",
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        "Autobús en ruta",
      );
    }
  }

  Future<void> _updateCameraToShowRoute() async {
    if (_routePolylinePoints.isEmpty) return;

    try {
      final GoogleMapController controller = await _mapController.future;
      List<LatLng> pointsToInclude = [..._routePolylinePoints];
      if (_userLocation != null) {
        pointsToInclude.add(_userLocation!);
      }

      double minLat = pointsToInclude.first.latitude;
      double maxLat = pointsToInclude.first.latitude;
      double minLng = pointsToInclude.first.longitude;
      double maxLng = pointsToInclude.first.longitude;

      for (LatLng point in pointsToInclude) {
        minLat = min(minLat, point.latitude);
        maxLat = max(maxLat, point.latitude);
        minLng = min(minLng, point.longitude);
        maxLng = max(maxLng, point.longitude);
      }

      final LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(minLat - 0.05, minLng - 0.05),
        northeast: LatLng(maxLat + 0.05, maxLng + 0.05),
      );

      await controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    } catch (e) {
      print('Error updating camera: $e');
    }
  }

  void _addMarker(
    LatLng position,
    String markerId,
    BitmapDescriptor icon,
    String description,
  ) {
    setState(() {
      _markers.removeWhere((marker) => marker.markerId == MarkerId(markerId));
      _markers.add(
        Marker(
          markerId: MarkerId(markerId),
          position: position,
          icon: icon,
          infoWindow: InfoWindow(
            title: markerId,
            snippet: description,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_routeName),
        backgroundColor: const Color(0xFF045FAA),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    if (!_mapController.isCompleted) {
                      _mapController.complete(controller);
                    }
                  },
                  initialCameraPosition: CameraPosition(
                    target: _defaultLocation,
                    zoom: 14,
                  ),
                  markers: _markers,
                  polylines: _polylines,
                  mapType: MapType.normal,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  trafficEnabled: true,
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: _updateCameraToShowRoute,
                    child: const Icon(Icons.center_focus_strong),
                    backgroundColor: const Color(0xFF045FAA),
                  ),
                ),
              ],
            ),
    );
  }
}
