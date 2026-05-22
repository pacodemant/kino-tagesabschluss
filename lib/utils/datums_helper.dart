class DatumsHelper {
  const DatumsHelper._();

  static DateTime logischerAbrechnungsTag() {
    final DateTime now = DateTime.now();
    if (now.hour < 6) {
      return now.subtract(const Duration(days: 1));
    }
    return now;
  }

  static String logischesIsoDatum() {
    final DateTime tag = logischerAbrechnungsTag();
    return '${tag.year}-${tag.month.toString().padLeft(2, '0')}-'
        '${tag.day.toString().padLeft(2, '0')}';
  }
}
