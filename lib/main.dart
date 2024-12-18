import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_urbanito/firebase_options.dart';
import 'package:my_urbanito/ui/screens/home_screen.dart';
import 'package:my_urbanito/ui/screens/map_screen.dart';
import 'package:my_urbanito/ui/screens/route_details.dart';
import 'package:my_urbanito/ui/screens/settings_screen.dart';
import 'package:my_urbanito/ui/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyUrbanitoApp());
}

class MyUrbanitoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi Urbanito',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(userName: '',),
      routes: {
        // '/home': (context) => HomeScreen(),
        '/map': (context) => MapScreen(
            route: {}), // Proporciona un valor predeterminado para 'route'
        '/route_details': (context) => RouteDetailsScreen(),
        '/settings': (context) => SettingsScreen(),
        '/login': (context) => LoginScreen(),
      },
    );
  }
}
