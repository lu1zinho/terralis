class DartUtils {
  /// string with date format d/M/yyyy
  static String dateToString(DateTime date) =>
      '${date.day}/${date.month}/${date.year}';

  /// string with date format d/M/yyyy
  static DateTime stringToDate(String string) {
    var split = string.split('/');
    return DateTime(
        int.parse(split[2]), int.parse(split[1]), int.parse(split[0]));
  }

  static String numberToCommaString(num? number) =>
      number?.toStringAsFixed(2).replaceAll('.', ',') ?? '';

  static double? tryParseCommaDouble(String string) =>
      double.tryParse(string.trim().replaceAll(',', '.'));
}
