import 'package:flutter/material.dart';
import 'package:my_urbanito/ui/screens/home_screen.dart';
import 'package:my_urbanito/ui/screens/map_screen.dart';
import 'package:my_urbanito/ui/screens/route_details.dart';
import 'package:my_urbanito/ui/screens/settings_screen.dart';
import 'package:my_urbanito/ui/screens/login_screen.dart';

void main() {
  runApp(MyUrbanitoApp());
}

class MyUrbanitoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Urbanito',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginScreen(),
      // home: HomeScreen(),
      routes: {
        '/map': (context) => MapScreen(),
        '/route_details': (context) => RouteDetailsScreen(),
        '/settings': (context) => SettingsScreen(),
        '/login': (context) => LoginScreen(),
      },
    );
  }
}
