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
              widget.message ?? 'Enter your one  time password (OTP)',
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
              hintText: 'OTP',
              onSaved: (value) => _otp = value,
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Field is required'
                  : null,
            ),
            Container(
              height: 40,
              width: 100,
              margin: EdgeInsets.only(top: 20, bottom: 10),
              child: ElevatedButton(
                onPressed: _validateInputs,
                child: Text('Continue'),
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