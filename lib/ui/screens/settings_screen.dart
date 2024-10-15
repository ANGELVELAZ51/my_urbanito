import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _darkTheme = false;
  String _language = 'Español';
  double _updateInterval = 30.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notifications = prefs.getBool('notifications') ?? true;
      _darkTheme = prefs.getBool('darkTheme') ?? false;
      _language = prefs.getString('language') ?? 'Español';
      _updateInterval = prefs.getDouble('updateInterval') ?? 30.0;
    });
  }

  _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('notifications', _notifications);
    prefs.setBool('darkTheme', _darkTheme);
    prefs.setString('language', _language);
    prefs.setDouble('updateInterval', _updateInterval);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configuración'),
      ),
      body: ListView(
        children: <Widget>[
          SwitchListTile(
            title: Text('Notificaciones'),
            value: _notifications,
            onChanged: (bool value) {
              setState(() {
                _notifications = value;
                _saveSettings();
              });
            },
            activeColor: const Color.fromARGB(255, 4, 95, 170),
          ),
          SwitchListTile(
            title: Text('Tema Oscuro'),
            value: _darkTheme,
            onChanged: (bool value) {
              setState(() {
                _darkTheme = value;
                _saveSettings();
              });
              // Aquí deberías implementar la lógica para cambiar el tema en toda la app
            },
            activeColor: const Color.fromARGB(255, 4, 95, 170),
          ),
          ListTile(
            title: Text('Idioma'),
            trailing: DropdownButton<String>(
              value: _language,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _language = newValue;
                    _saveSettings();
                  });
                }
              },
              items: <String>['Español', 'English', 'Français', 'Português']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          ListTile(
            title: Text('Intervalo de actualización'),
            subtitle: Text('${_updateInterval.toStringAsFixed(0)} segundos'),
            trailing: SizedBox(
              width: 200,
              child: Slider(
                value: _updateInterval,
                min: 15,
                max: 120,
                divisions: 7,
                label: _updateInterval.round().toString(),
                onChanged: (double value) {
                  setState(() {
                    _updateInterval = value;
                    _saveSettings();
                  });
                },
                activeColor: const Color.fromARGB(255, 4, 95, 170),
              ),
            ),
          ),
          ListTile(
            title: Text('Versión de la aplicación'),
            trailing: Text('1.0.0'), // Esto debería obtenerse dinámicamente
          ),
        ],
      ),
    );
  }
}
