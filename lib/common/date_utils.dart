int daysSince(DateTime date) {
  final DateTime now = DateTime.now();
  return now.difference(date).inDays;
}

int weeksSince(DateTime date) {
  return (daysSince(date) / 7).floor();
}
