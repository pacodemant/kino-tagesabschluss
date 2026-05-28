class DatumsHelper {
  const DatumsHelper._();

  static DateTime logischerAbrechnungsTag() {
    final DateTime now = DateTime.now();
    if (now.hour < 6) {
      return now.subtract(const Duration(days: 1));
    }
    return now;
  }

  static String isoDatum(DateTime datum) =>
      '${datum.year}-${datum.month.toString().padLeft(2, '0')}-'
      '${datum.day.toString().padLeft(2, '0')}';

  static String logischesIsoDatum() {
    final DateTime tag = logischerAbrechnungsTag();
    return isoDatum(tag);
  }
}
