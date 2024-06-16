/// Return the number of days since the given [date].
int daysSince(DateTime date) {
  final DateTime now = DateTime.now();
  return now.difference(date).inDays;
}

/// Return the number of weeks since the given [date].
int weeksSince(DateTime date) {
  return (daysSince(date) / 7).floor();
}
