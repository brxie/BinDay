import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'schedule_page.dart';

bool isFirstBuild = true;

class CitySelectionPage extends StatefulWidget {
  const CitySelectionPage({super.key});
  

  @override
  State<CitySelectionPage> createState() => _CitySelectionPageState();
}

class _CitySelectionPageState extends State<CitySelectionPage> {
  final List<String> _cities = [
    'New York',
    'Los Angeles',
    'Chicago',
    'Houston',
    'Phoenix'
  ];
  String? _selectedCity;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (isFirstBuild) {
      isFirstBuild = false;
      _loadLastSelectedCity();
    }
  }

  Future<void> _loadLastSelectedCity() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCity = prefs.getString('selectedCity');
    if (lastCity != null) {
      setState(() {
        _selectedCity = lastCity;
      });
      // Navigate to SchedulePage if a city was previously selected
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SchedulePage(selectedCities: [lastCity]),
          ),
        );
      });
    }
  }

  Future<void> _saveSelectedCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedCity', city);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select City for Trash Collection'),
        backgroundColor: Colors.green[700],
      ),
      body: ListView(
        children: _cities.map((city) {
          return RadioListTile<String>(
            title: Text(city),
            value: city,
            groupValue: _selectedCity,
            onChanged: (String? value) {
              if (value != null) {
                setState(() {
                  _selectedCity = value;
                });
                _saveSelectedCity(value);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SchedulePage(selectedCities: [value]),
                  ),
                );
              }
            },
            secondary: const Icon(Icons.delete, color: Colors.green),
          );
        }).toList(),
      ),
    );
  }
}
