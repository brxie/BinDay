import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wystaw_smieci/utils/language.dart';
import 'schedule_page.dart';
import '../utils/constants.dart';

bool isFirstBuild = true;

class CitySelectionPage extends StatefulWidget {
  const CitySelectionPage({super.key});

  @override
  State<CitySelectionPage> createState() => _CitySelectionPageState();
}

class _CitySelectionPageState extends State<CitySelectionPage> {
  final List<String> _cities = [
    'Baranówka',
    'Czulice',
    'Dojazdów',
    'Głęboka',
    'Goszcza',
    'Goszyce',
    'Karniów',
    'Kocmyrzów',
    'Krzysztoforzyce',
    'Łosokowice',
    'Luborzyca',
    'Łuczyce (część I Krakowska)',
    'Łuczyce (część II Prądnik)',
    'Maciejowice',
    'Marszowice',
    'Pietrzejowice',
    'Prusy',
    'Rawałowice',
    'Sadowie',
    'Skrzeszowice',
    'Sulechów',
    'Wiktorowice',
    'Wilków',
    'Wola Luborzycka',
    'Wysiołek Luborzycki',
    'Zastów'
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
        title: const Text(LangPL.appName),
        backgroundColor: Colors.green[700],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: Constants.backgroundGradientColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                LangPL.selectCity,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.green[900],
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: _cities.length,
                separatorBuilder: (context, index) => Divider(
                  color: Colors.green[200],
                  thickness: 1,
                ),
                itemBuilder: (context, index) {
                  final city = _cities[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: ListTile(
                      tileColor: Colors.green[50],
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      title: Text(
                        city,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.green[800],
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedCity = city;
                        });
                        _saveSelectedCity(city);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SchedulePage(selectedCities: [city]),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
