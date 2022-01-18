import 'package:flutter/services.dart';

class CardMonthInputFormatter extends TextInputFormatter {
  String? previousText;
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;

      if (nonZeroIndex % 2 == 0 &&
          ((!_isDeletion(previousText, text) && nonZeroIndex != 4) ||
              (nonZeroIndex != text.length))) {
        buffer.write('/');
      }
    }

    previousText = text;
    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: TextSelection.collapsed(offset: string.length));
  }

  bool _isDeletion(String? prevText, String newText) {
    if (prevText == null) {
      return false;
    }

    return prevText.length > newText.length;
  }
}
