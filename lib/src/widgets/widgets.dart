import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../base/base.dart';
import '../utils/utils.dart';

export 'bankcard.widget.dart';
export 'pin.widget.dart';
export 'paybutton.widget.dart';
export 'billing.widget.dart';
export 'otp.widget.dart';
export 'overlay_loading.widget.dart';

class EmailField extends BaseTextField {
  EmailField({
    required FormFieldSetter<String> onSaved,
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    ValueChanged<String>? onFieldSubmitted,
    TextEditingController? controller,
  }) : super(
          labelText: Setup.instance.strings.emailLabel,
          hintText: Setup.instance.strings.emailHint,
          onSaved: onSaved,
          keyboardType: TextInputType.emailAddress,
          focusNode: focusNode,
          onFieldSubmitted: onFieldSubmitted,
          textInputAction: textInputAction,
          controller: controller,
          validator: (String? value) => validateNum(value),
        );

  static String? validateNum(String? input) {
    return ValidatorUtils.isEmailValid(input)
        ? null
        : Setup.instance.strings.invalidEmail;
  }
}

class CVVField extends BaseTextField {
  CVVField({
    required FormFieldSetter<String> onSaved,
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    ValueChanged<String>? onFieldSubmitted,
  }) : super(
          labelText: Setup.instance.strings.cvvLabel,
          hintText: Setup.instance.strings.ccvHint,
          onSaved: onSaved,
          validator: (String? value) => validateCVV(value),
          focusNode: focusNode,
          onFieldSubmitted: onFieldSubmitted,
          textInputAction: textInputAction,
          inputFormatters: [
            DoubleInputFormatter(),
            LengthLimitingTextInputFormatter(4),
          ],
        );

  static String? validateCVV(String? value) => ValidatorUtils.isCVVValid(value)
      ? null
      : Setup.instance.strings.invalidCVV;
}

class ExpiryDateField extends BaseTextField {
  ExpiryDateField({
    required FormFieldSetter<String> onSaved,
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    ValueChanged<String>? onFieldSubmitted,
  }) : super(
          labelText: Setup.instance.strings.cardExpiryLabel,
          hintText: Setup.instance.strings.cardExpirtHint,
          validator: validateDate,
          onSaved: onSaved,
          focusNode: focusNode,
          onFieldSubmitted: onFieldSubmitted,
          textInputAction: textInputAction,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
            CardMonthInputFormatter()
          ],
        );

  static String? validateDate(String? value) {
    if (value!.isEmpty) {
      return Setup.instance.strings.invalidExpiry;
    }

    int? year;
    int? month;
    // The value contains a forward slash if the month and year has been
    // entered.
    if (value.contains(RegExp(r'(\/)'))) {
      var split = value.split(RegExp(r'(\/)'));
      // The value before the slash is the month while the value to right of
      // it is the year.
      month = int.tryParse(split[0]);
      year = int.tryParse(split[1]);
    } else {
      // Only the month was entered
      month = int.parse(value.substring(0, (value.length)));
      year = -1; // Lets use an invalid year intentionally
    }

    if (!ValidatorUtils.validExpiryDate(month, year)) {
      return Setup.instance.strings.invalidExpiry;
    }
    return null;
  }
}

// class PhoneNumberField extends BaseTextField {
//   PhoneNumberField({
//     required FormFieldSetter<String> onSaved,
//     FocusNode? focusNode,
//     TextInputAction? textInputAction,
//     String hintText = '080XXXXXXXX',
//     ValueChanged<String>? onFieldSubmitted,
//   }) : super(
//           labelText: 'PHONE NUMBER',
//           hintText: hintText,
//           onSaved: onSaved,
//           focusNode: focusNode,
//           onFieldSubmitted: onFieldSubmitted,
//           textInputAction: textInputAction,
//           validator: (String? value) => validatePhoneNum(value),
//           inputFormatters: [
//             FilteringTextInputFormatter.digitsOnly,
//           ],
//         );

//   static String? validatePhoneNum(String? input) {
//     return ValidatorUtils.isPhoneValid(input)
//         ? null
//         : Setup.instance.strings.invalidPhoneNumber;
//   }
// }

class CardNumberField extends BaseTextField {
  CardNumberField({
    required TextEditingController? controller,
    required FormFieldSetter<String> onSaved,
    required Widget suffix,
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    ValueChanged<String>? onFieldSubmitted,
  }) : super(
          labelText: Setup.instance.strings.cardNumberLabel,
          hintText: Setup.instance.strings.cardNumberHint,
          controller: controller,
          onSaved: onSaved,
          suffixIcon: suffix,
          focusNode: focusNode,
          onFieldSubmitted: onFieldSubmitted,
          textInputAction: textInputAction,
          validator: (String? value) => validateCardNum(value),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(19),
            CardNumberInputFormatter()
          ],
        );

  static String? validateCardNum(String? input) {
    return ValidatorUtils.isCardNumberValid(input)
        ? null
        : Setup.instance.strings.invalidCardNumber;
  }
}
