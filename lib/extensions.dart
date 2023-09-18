extension NumFormat on int {
  String toTwoDigit() {
    return toString().padLeft(2, '0');
  }

  String toFourDigit() {
    return toString().padLeft(4, '0');
  }

  String forMoney() {
    return toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
