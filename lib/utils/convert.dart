import 'package:diacritic/diacritic.dart';

String toCityID(String cityName) {
  String result = '';
  cityName = removeDiacritics(cityName); // Normalize special characters
  for (int i = 0; i < cityName.length; i++) {
    String char = cityName[i].toLowerCase();
    if (char == ' ') {
      result += '_';
    } else if (char.codeUnitAt(0) <= 127) {
      // Only include ASCII characters
      if ((char.codeUnitAt(0) >= 97 && char.codeUnitAt(0) <= 122) || // a-z
          (char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57)) {
        // 0-9
        result += char;
      }
    }
  }
  return result;
}
