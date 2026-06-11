/// Canonical 'YYYY-MM-DD' key in the device's local time zone.
String dateKey(DateTime moment) {
  final y = moment.year.toString().padLeft(4, '0');
  final m = moment.month.toString().padLeft(2, '0');
  final d = moment.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

DateTime parseDateKey(String key) => DateTime.parse(key);
