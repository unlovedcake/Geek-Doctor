extension StringExtension on String {
  static String capitalFirst(String text) {
    if (text.length <= 1) return text.toUpperCase();

    var words = text.split(' ');

    var capitalized = words.map((word) {
      var first = word.substring(0, 1).toUpperCase();
      var rest = word.substring(1);
      return '$first$rest';
    });
    return capitalized.join(' ');
  }

  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).splitMapJoin(" ")}";
  }
}
