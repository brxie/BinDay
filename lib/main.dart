import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:wystaw_smieci/utils/constants.dart';
import 'pages/city_selection_page.dart';
import 'package:wystaw_smieci/background_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting(Constants.locale, null);
  initializeBackgroundService();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trash Collection Schedule',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const CitySelectionPage(),
    );
  }
}
