/// Formats UTC transaction timestamps into local date+12h time strings.
String formatTransactionDate(DateTime utc) {
  final d = utc.toLocal();
  final h = d.hour;
  final h12 = h % 12 == 0 ? 12 : h % 12;
  final mm = d.minute.toString().padLeft(2, '0');
  final ampm = h < 12 ? 'AM' : 'PM';
  return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} · $h12:$mm $ampm';
}
