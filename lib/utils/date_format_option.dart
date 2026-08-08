import '../screens/home_screen.dart' as homeScreen;

enum DateFormatOption {
  isoStyle, // 2026-08-07
  dayMonYear, // 7-Aug-2026
  monDayYear, // Aug 7, 2026
  monthDayYear, // August 7, 2026
}

const List<String> _monthAbbreviations = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];
const List<String> _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

String formatDate(DateTime date, DateFormatOption option) {
  final String day = date.day.toString().padLeft(2, '0');
  final String monthNum = date.month.toString().padLeft(2, '0');
  final String monthAbbr = _monthAbbreviations[date.month - 1];
  final String monthName = _months[date.month - 1];
  final String year = date.year.toString();

  switch (option) {
    case DateFormatOption.isoStyle:
      return '$year-$monthNum-$day';
    case DateFormatOption.dayMonYear:
      return '$day-$monthAbbr-$year';
    case DateFormatOption.monDayYear:
      return '$monthAbbr $day, $year';
    case DateFormatOption.monthDayYear:
      return '$monthName $day, $year';
  }
}

String labelFor(DateFormatOption option) {
  switch (option) {
    case DateFormatOption.isoStyle:
      return 'YYYY-MM-DD (2026-08-14)';
    case DateFormatOption.dayMonYear:
      return 'DD-Mon-YYYY (14-Aug-2026)';
    case DateFormatOption.monDayYear:
      return 'Mon DD, YYYY (Aug 14, 2026)';
    case DateFormatOption.monthDayYear:
      return 'Month DD, YYYY (August 14, 2026)';

  }
}
