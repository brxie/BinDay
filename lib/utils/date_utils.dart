import 'language.dart';

String getDayOfWeek(DateTime date) {
  switch (date.weekday) {
    case DateTime.monday:
      return LangPL.monday;
    case DateTime.tuesday:
      return LangPL.tuesday;
    case DateTime.wednesday:
      return LangPL.wednesday;
    case DateTime.thursday:
      return LangPL.thursday;
    case DateTime.friday:
      return LangPL.friday;
    case DateTime.saturday:
      return LangPL.saturday;
    case DateTime.sunday:
      return LangPL.sunday;
    default:
      return '';
  }
}
