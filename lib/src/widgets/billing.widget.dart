import 'package:flutter/material.dart';
import 'package:nravepay/src/base/base.dart';

class BillingWidget extends StatefulWidget {
  final ValueChanged<Map<String, String?>>? onBillingInputted;

  BillingWidget({required this.onBillingInputted});

  @override
  _BillingWidgetState createState() => _BillingWidgetState();
}

class _BillingWidgetState extends State<BillingWidget> {
  final _formKey = GlobalKey<FormState>();
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
              'Enter your billing address details',
              style: Theme.of(context).textTheme.subtitle2,
            ),
            SizedBox(height: 30),
            BaseTextField(
              keyboardType: TextInputType.text,
              autoFocus: true,
              validator: _validate,
              onSaved: (value) => address = value,
              hintText: 'Address e.g 20 Saltlake Eldorado',
            ),
            SizedBox(height: 10),
            BaseTextField(
              keyboardType: TextInputType.text,
              validator: _validate,
              onSaved: (value) => city = value,
              hintText: 'City e.g. Livingstone',
            ),
            SizedBox(height: 10),
            BaseTextField(
              keyboardType: TextInputType.text,
              validator: _validate,
              onSaved: (value) => state = value,
              hintText: 'State e.g. CA',
            ),
            SizedBox(height: 10),
            BaseTextField(
              keyboardType: TextInputType.text,
              validator: _validate,
              onSaved: (value) => zip = value,
              hintText: 'Zip code e.g. 928302',
            ),
            SizedBox(height: 10),
            BaseTextField(
              keyboardType: TextInputType.text,
              validator: _validate,
              onSaved: (value) => country = value,
              hintText: 'Country e.g. US',
            ),
            Container(
              height: 40,
              margin: EdgeInsets.only(top: 20, bottom: 10),
              child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Theme.of(context).accentColor)),
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
      var data = {
        'address': address,
        'city': city,
        'state': state,
        'zip': zip,
        'counntry': country
      };
      widget.onBillingInputted!(data);
    } else {
      setState(() {
        _autoValidate = AutovalidateMode.always;
      });
    }
  }

  String? _validate(String? value) =>
      value == null || value.trim().isEmpty ? 'Field is required' : null;
}