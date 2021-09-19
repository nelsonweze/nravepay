import 'package:flutter/material.dart';
import 'package:nravepay/src/base/base.dart';

import '../../nravepay.dart';

class OtpWidget extends StatefulWidget {
  final String? message;
  final ValueChanged<String?>? onPinInputted;

  OtpWidget({required this.message, required this.onPinInputted});

  @override
  _OtpWidgetState createState() => _OtpWidgetState();
}

class _OtpWidgetState extends State<OtpWidget> {
  final _formKey = GlobalKey<FormState>();
  var _autoValidateMode = AutovalidateMode.disabled;
  String? _otp;
  var heightBox = SizedBox(height: 20.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Form(
        key: _formKey,
        autovalidateMode: _autoValidateMode,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            heightBox,
            Text(
              widget.message ?? Setup.instance.strings.enterOtp,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15.0,
              ),
            ),
            heightBox,
            BaseTextField(
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25.0,
                letterSpacing: 15.0,
              ),
              autoFocus: true,
              inputFormatters: [
                DoubleInputFormatter(),
              ],
              obscureText: true,
              hintText: Setup.instance.strings.otpHint,
              onSaved: (value) => _otp = value,
              validator: (value) => value == null || value.trim().isEmpty
                  ? Setup.instance.strings.fieldRequired
                  : null,
            ),
            Container(
              height: 40,
              width: 200,
              margin: EdgeInsets.only(top: 20, bottom: 10),
              child: ElevatedButton(
                onPressed: _validateInputs,
                style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                Setup.instance.borderRadius)))),
                child: Text(Setup.instance.strings.continueText),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _validateInputs() {
    final form = _formKey.currentState!;
    if (form.validate()) {
      FocusScope.of(context).requestFocus(FocusNode());
      form.save();
      widget.onPinInputted!(_otp);
    } else {
      setState(() {
        _autoValidateMode = AutovalidateMode.always;
      });
    }
  }
}
