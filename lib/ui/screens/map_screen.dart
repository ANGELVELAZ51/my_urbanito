import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:my_urbanito/constants.dart';
import 'package:location/location.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  LatLng? _userLocation;
  LatLng? _driverLocation;

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  Timer? _driverUpdateTimer;

  @override
  void initState() {
    super.initState();
    _initUserLocation();
  }

  @override
  void dispose() {
    _driverUpdateTimer?.cancel();
    super.dispose();
  }

  void _initUserLocation() async {
    try {
      Location location = Location();
      LocationData locationData = await location.getLocation();
      if (locationData.latitude != null && locationData.longitude != null) {
        setState(() {
          _userLocation =
              LatLng(locationData.latitude!, locationData.longitude!);
          _addMarker(_userLocation!, "Your Location",
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure));
        });
        _updateCamera();
        _simulateDriverUpdates();
      } else {
        print("No se pudo obtener la ubicación del usuario");
      }
    } catch (e) {
      print("Error al obtener la ubicación: $e");
    }
  }

  void _simulateDriverUpdates() {
    if (_userLocation == null) {
      print("La ubicación del usuario aún no está disponible");
      return;
    }
    // Simulando la ubicación inicial del conductor
    _driverLocation =
        LatLng(_userLocation!.latitude - 0.01, _userLocation!.longitude - 0.01);
    _addMarker(_driverLocation!, "Driver",
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen));
    _getRouteToUser();

    // Actualizando la ubicación del conductor cada 5 segundos
    _driverUpdateTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_userLocation != null && _driverLocation != null) {
        setState(() {
          _driverLocation = LatLng(
            _driverLocation!.latitude +
                (_userLocation!.latitude - _driverLocation!.latitude) * 0.1,
            _driverLocation!.longitude +
                (_userLocation!.longitude - _driverLocation!.longitude) * 0.1,
          );
          _updateDriverMarker();
          _getRouteToUser();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ubicación de MyUrbanito'),
      ),
      body: _userLocation == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: ((GoogleMapController controller) =>
                  _mapController.complete(controller)),
              initialCameraPosition: CameraPosition(
                target: _userLocation!,
                zoom: 14,
              ),
              markers: _markers,
              polylines: _polylines,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _updateCamera,
        child: Icon(Icons.center_focus_strong),
      ),
    );
  }

  void _addMarker(LatLng position, String markerId, BitmapDescriptor icon) {
    setState(() {
      _markers.removeWhere((marker) => marker.markerId == MarkerId(markerId));
      _markers.add(
        Marker(
          markerId: MarkerId(markerId),
          position: position,
          icon: icon,
          infoWindow: InfoWindow(
            title: markerId,
          ),
        ),
      );
    });
  }

  void _updateDriverMarker() {
    if (_driverLocation != null) {
      _addMarker(_driverLocation!, "Driver",
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen));
    }
  }

  Future<void> _updateCamera() async {
    if (_userLocation == null || _driverLocation == null) return;

    final GoogleMapController? controller = await _mapController.future;
    if (controller == null) return;

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        _userLocation!.latitude < _driverLocation!.latitude
            ? _userLocation!.latitude
            : _driverLocation!.latitude,
        _userLocation!.longitude < _driverLocation!.longitude
            ? _userLocation!.longitude
            : _driverLocation!.longitude,
      ),
      northeast: LatLng(
        _userLocation!.latitude > _driverLocation!.latitude
            ? _userLocation!.latitude
            : _driverLocation!.latitude,
        _userLocation!.longitude > _driverLocation!.longitude
            ? _userLocation!.longitude
            : _driverLocation!.longitude,
      ),
    );
    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  Future<void> _getRouteToUser() async {
    if (_userLocation == null || _driverLocation == null) return;

    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      GOOGLE_MAPS_API_KEY,
      PointLatLng(_driverLocation!.latitude, _driverLocation!.longitude),
      PointLatLng(_userLocation!.latitude, _userLocation!.longitude),
      travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      List<LatLng> polylineCoordinates = result.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();

      setState(() {
        _polylines.clear();
        _polylines.add(Polyline(
          polylineId: PolylineId('driverRoute'),
          color: Colors.blue,
          points: polylineCoordinates,
          width: 5,
        ));
      });
    } else {
      print("No se pudo obtener la ruta: ${result.errorMessage}");
    }
  }
}
