import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'base/base.dart';
import 'models.dart';
import 'paymanager.dart';
import 'util.payment.dart';
import 'helpers.dart';

class OtpWidget extends StatefulWidget {
  final String? message;
  final ValueChanged<String?>? onPinInputted;

  OtpWidget({required this.message, required this.onPinInputted});

  @override
  _OtpWidgetState createState() => _OtpWidgetState();
}

class _OtpWidgetState extends State<OtpWidget> {
  var _formKey = GlobalKey<FormState>();
  var _autoValidate = false;
  String? _otp;
  var heightBox = SizedBox(height: 20.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Form(
        key: _formKey,
        autovalidate: _autoValidate,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            heightBox,
            Text(
              widget.message ?? "Enter your one  time password (OTP)",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                fontSize: 15.0,
              ),
            ),
            heightBox,
            BaseTextField(
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: 25.0,
                letterSpacing: 15.0,
              ),
              autoFocus: true,
              inputFormatters: [
                DoubleInputFormatter(),
              ],
              obscureText: true,
              hintText: "OTP",
              onSaved: (value) => _otp = value,
              validator: (value) => value == null || value.trim().isEmpty
                  ? "Field is required"
                  : null,
            ),
            Container(
              height: 40,
              width: 100,
              margin: EdgeInsets.only(top: 20, bottom: 10),
              child: ElevatedButton(
                child: Text("Continue"),
                onPressed: _validateInputs,
              ),
            )
          ],
        ),
      ),
    );
  }

  void _validateInputs() {
    final FormState form = _formKey.currentState!;
    if (form.validate()) {
      FocusScope.of(context).requestFocus(FocusNode());
      form.save();
      widget.onPinInputted!(_otp);
    } else {
      setState(() {
        _autoValidate = true;
      });
    }
  }
}

class BillingWidget extends StatefulWidget {
  final ValueChanged<Map<String, String?>>? onBillingInputted;

  BillingWidget({required this.onBillingInputted});

  @override
  _BillingWidgetState createState() => _BillingWidgetState();
}

class _BillingWidgetState extends State<BillingWidget> {
  var _formKey = GlobalKey<FormState>();
  AutovalidateMode _autoValidate = AutovalidateMode.disabled;
  String? address;
  String? city;
  String? state;
  String? zip;
  String? country;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Form(
        key: _formKey,
        autovalidateMode: _autoValidate,
        child: Column(
          children: <Widget>[
            SizedBox(height: 20),
            Text(
              "Enter your billing address details",
              style: Theme.of(context).textTheme.subtitle2,
            ),
            SizedBox(height: 30),
            BaseTextField(
              keyboardType: TextInputType.text,
              autoFocus: true,
              validator: _validate,
              onSaved: (value) => address = value,
              hintText: "Address e.g 20 Saltlake Eldorado",
            ),
            SizedBox(height: 10),
            BaseTextField(
              keyboardType: TextInputType.text,
              validator: _validate,
              onSaved: (value) => city = value,
              hintText: "City e.g. Livingstone",
            ),
            SizedBox(height: 10),
            BaseTextField(
              keyboardType: TextInputType.text,
              validator: _validate,
              onSaved: (value) => state = value,
              hintText: "State e.g. CA",
            ),
            SizedBox(height: 10),
            BaseTextField(
              keyboardType: TextInputType.text,
              validator: _validate,
              onSaved: (value) => zip = value,
              hintText: "Zip code e.g. 928302",
            ),
            SizedBox(height: 10),
            BaseTextField(
              keyboardType: TextInputType.text,
              validator: _validate,
              onSaved: (value) => country = value,
              hintText: "Country e.g. US",
            ),
            Container(
              height: 40,
              margin: EdgeInsets.only(top: 20, bottom: 10),
              child: ElevatedButton(
                child: Text("Continue"),
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Theme.of(context).accentColor)),
                onPressed: _validateInputs,
              ),
            )
          ],
        ),
      ),
    );
  }

  void _validateInputs() {
    final FormState form = _formKey.currentState!;
    if (form.validate()) {
      FocusScope.of(context).requestFocus(FocusNode());
      form.save();
      var data = {
        "address": address,
        "city": city,
        "state": state,
        "zip": zip,
        "counntry": country
      };
      widget.onBillingInputted!(data);
    } else {
      setState(() {
        _autoValidate = AutovalidateMode.always;
      });
    }
  }

  String? _validate(String? value) =>
      value == null || value.trim().isEmpty ? "Field is required" : null;
}

class PinWidget extends StatefulWidget {
  final ValueChanged<String>? onPinInputted;

  PinWidget({required this.onPinInputted});

  @override
  _PinWidgetState createState() => _PinWidgetState();
}

class _PinWidgetState extends State<PinWidget> {
  TextEditingController _controller = TextEditingController();
  var _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _controller.addListener(_onChange);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var heightBox = SizedBox(height: 20);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            heightBox,
            Text(
              "Please, enter your card pin to continue your transaction",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                fontSize: 15.0,
              ),
            ),
            heightBox,
            BaseTextField(
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: 25.0,
                letterSpacing: 15.0,
              ),
              autoFocus: true,
              inputFormatters: [
                DoubleInputFormatter(),
                LengthLimitingTextInputFormatter(4),
              ],
              obscureText: true,
              controller: _controller,
              hintText: "PIN",
            ),
            SizedBox(height: 15)
          ],
        ),
      ),
    );
  }

  void _onChange() {
    var value = _controller.text;
    if (value.length == 4) {
      FocusScope.of(context).unfocus();
      widget.onPinInputted!(value);
      _controller.removeListener(_onChange);
    }
  }
}

class AmountField extends BaseTextField {
  AmountField({
    required FormFieldSetter<String> onSaved,
    required String currency,
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    ValueChanged<String>? onFieldSubmitted,
    TextEditingController? controller,
  }) : super(
          labelText: 'AMOUNT',
          hintText: '0.0',
          onSaved: onSaved,
          prefix: Text('$currency '.toUpperCase()),
          controller: controller,
          focusNode: focusNode,
          onFieldSubmitted: onFieldSubmitted,
          textInputAction: textInputAction,
          prefixStyle:
              TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w600),
          validator: (String? value) => validateNum(value),
        );

  static String? validateNum(String? input) {
    return ValidatorUtils.isAmountValid(input) ? null : Strings.invalidAmount;
  }
}

class EmailField extends BaseTextField {
  EmailField({
    required FormFieldSetter<String> onSaved,
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    ValueChanged<String>? onFieldSubmitted,
    TextEditingController? controller,
  }) : super(
          labelText: 'EMAIL',
          hintText: 'EXAMPLE@EMAIL.COM',
          onSaved: onSaved,
          keyboardType: TextInputType.emailAddress,
          focusNode: focusNode,
          onFieldSubmitted: onFieldSubmitted,
          textInputAction: textInputAction,
          controller: controller,
          validator: (String? value) => validateNum(value),
        );

  static String? validateNum(String? input) {
    return ValidatorUtils.isEmailValid(input) ? null : Strings.invalidEmail;
  }
}

class CVVField extends BaseTextField {
  CVVField({
    required FormFieldSetter<String> onSaved,
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    ValueChanged<String>? onFieldSubmitted,
  }) : super(
          labelText: 'CVV',
          hintText: '123',
          onSaved: onSaved,
          validator: (String? value) => validateCVV(value),
          focusNode: focusNode,
          onFieldSubmitted: onFieldSubmitted,
          textInputAction: textInputAction,
          inputFormatters: [
            DoubleInputFormatter(),
            new LengthLimitingTextInputFormatter(4),
          ],
        );

  static String? validateCVV(String? value) =>
      ValidatorUtils.isCVVValid(value) ? null : Strings.invalidCVV;
}

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

class BVNField extends BaseTextField {
  BVNField({
    required FormFieldSetter<String> onSaved,
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    ValueChanged<String>? onFieldSubmitted,
  }) : super(
          labelText: 'BVN',
          hintText: '123456789',
          onSaved: onSaved,
          validator: (String? value) => validatePhoneNum(value),
          focusNode: focusNode,
          onFieldSubmitted: onFieldSubmitted,
          textInputAction: textInputAction,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(11)
          ],
        );

  static String? validatePhoneNum(String? input) {
    return ValidatorUtils.isBVNValid(input) ? null : Strings.invalidBVN;
  }
}

class ExpiryDateField extends BaseTextField {
  ExpiryDateField({
    required FormFieldSetter<String> onSaved,
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    ValueChanged<String>? onFieldSubmitted,
  }) : super(
          labelText: 'CARD EXPIRY',
          hintText: 'MM/YY',
          validator: validateDate,
          onSaved: onSaved,
          focusNode: focusNode,
          onFieldSubmitted: onFieldSubmitted,
          textInputAction: textInputAction,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            new LengthLimitingTextInputFormatter(4),
            new CardMonthInputFormatter()
          ],
        );

  static String? validateDate(String? value) {
    if (value!.isEmpty) {
      return Strings.invalidExpiry;
    }

    int? year;
    int? month;
    // The value contains a forward slash if the month and year has been
    // entered.
    if (value.contains(new RegExp(r'(\/)'))) {
      var split = value.split(new RegExp(r'(\/)'));
      // The value before the slash is the month while the value to right of
      // it is the year.
      month = int.tryParse(split[0]);
      year = int.tryParse(split[1]);
    } else {
      // Only the month was entered
      month = int.parse(value.substring(0, (value.length)));
      year = -1; // Lets use an invalid year intentionally
    }

    if (!ValidatorUtils.validExpiryDate(month, year))
      return Strings.invalidExpiry;

    return null;
  }
}

class PhoneNumberField extends BaseTextField {
  PhoneNumberField({
    required FormFieldSetter<String> onSaved,
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    String hintText = '080XXXXXXXX',
    ValueChanged<String>? onFieldSubmitted,
  }) : super(
          labelText: 'PHONE NUMBER',
          hintText: hintText,
          onSaved: onSaved,
          focusNode: focusNode,
          onFieldSubmitted: onFieldSubmitted,
          textInputAction: textInputAction,
          validator: (String? value) => validatePhoneNum(value),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
        );

  static String? validatePhoneNum(String? input) {
    return ValidatorUtils.isPhoneValid(input)
        ? null
        : Strings.invalidPhoneNumber;
  }
}

class CardNumberField extends BaseTextField {
  CardNumberField({
    required TextEditingController? controller,
    required FormFieldSetter<String> onSaved,
    required Widget suffix,
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    ValueChanged<String>? onFieldSubmitted,
  }) : super(
          labelText: 'CARD NUMBER',
          hintText: '0000 0000 0000 0000',
          controller: controller,
          onSaved: onSaved,
          suffixIcon: suffix,
          focusNode: focusNode,
          onFieldSubmitted: onFieldSubmitted,
          textInputAction: textInputAction,
          validator: (String? value) => validateCardNum(value),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            new LengthLimitingTextInputFormatter(19),
            new CardNumberInputFormatter()
          ],
        );

  static String? validateCardNum(String? input) {
    return ValidatorUtils.isCardNumberValid(input)
        ? null
        : Strings.invalidCardNumber;
  }

  @override
  createState() {
    return super.createState();
  }
}

class BankCardWidget extends StatelessWidget {
  final BankCard? card;
  final bool placeholder;
  final bool isDefault;
  final Function(BankCard?) onSelect;
  BankCardWidget(
      {this.card,
      this.placeholder = false,
      required this.onSelect,
      this.isDefault = false});
  @override
  Widget build(BuildContext context) {
    return ListTile(
        onTap: () => onSelect(card),
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!placeholder)
              SvgPicture.asset(
                'assets/${card!.type.toLowerCase()}.svg',
                package: 'nravepay',
                width: 50,
                height: 38,
              )
            else
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Icon(
                  Icons.add,
                  size: 40,
                ),
              )
          ],
        ),
        trailing: isDefault
            ? Icon(Icons.check_circle)
            : Container(
                height: 0,
                width: 0,
              ),
        title: !placeholder
            ? Row(
                children: [
                  Text(
                    card!.type.toUpperCase(),
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                  Text(' •••• ${card!.last4digits}',
                      style: Theme.of(context).textTheme.subtitle2),
                ],
              )
            : Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  'Add credit card',
                  style: Theme.of(context).textTheme.caption!.copyWith(
                      fontSize: 13, color: Theme.of(context).accentColor),
                ),
              ),
        subtitle: !placeholder ? Text('${card!.expiry}') : null);
  }
}

class PaymentButton extends StatelessWidget {
  final PayInitializer? initializer;
  final Function()? onPressed;
  final bool disable;
  PaymentButton({this.initializer, this.onPressed, this.disable = false});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 200,
        padding: const EdgeInsets.all(12.0),
        alignment: Alignment.bottomCenter,
        width: double.infinity,
        child: Column(
          children: [
            Container(
                margin: const EdgeInsets.all(
                  20.0,
                ),
                height: 40,
                width: double.infinity,
                child: ElevatedButton(
                  child: Text(
                      'Pay   ${currencies.firstWhere((e) => e.name == initializer!.currency).symbol} ${initializer!.amount}'),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Theme.of(context).accentColor)),
                  onPressed: disable
                      ? null
                      : onPressed ??
                          () {
                            CardTransactionManager(
                              context: context,
                            )..processTransaction(
                                Payload.fromInitializer(initializer!));
                          },
                )),
            Container(
                alignment: Alignment.bottomCenter,
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(' Secured by  '),
                    SvgPicture.asset(
                      'assets/flutterwave_logo.svg',
                      package: 'nravepay',
                      width: 24,
                      height: 24,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Text('Flutterwave'),
                    )
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
