import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DoubleInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var raw = newValue.text.trim().replaceAll(',', '').replaceAll('.', '');
    var data = double.tryParse(raw);
    if (data != null || raw.isEmpty) {
      return newValue.copyWith(
          text: newValue.text.trim().replaceAll(',', '').replaceAll('.', ''),
          selection:
              TextSelection.fromPosition(TextPosition(offset: raw.length)));
    }
    return oldValue;
  }
}
