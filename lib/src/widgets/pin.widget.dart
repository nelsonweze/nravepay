import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nravepay/nravepay.dart';
import 'package:nravepay/src/base/base.dart';

class PinWidget extends StatefulWidget {
  final ValueChanged<String>? onPinInputted;

  PinWidget({required this.onPinInputted});

  @override
  _PinWidgetState createState() => _PinWidgetState();
}

class _PinWidgetState extends State<PinWidget> {
  final TextEditingController _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
              'Please, enter your card pin to continue your transaction',
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
              hintText: 'PIN',
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

// class AmountField extends BaseTextField {
//   AmountField({
//     required FormFieldSetter<String> onSaved,
//     required String currency,
//     FocusNode? focusNode,
//     TextInputAction? textInputAction,
//     ValueChanged<String>? onFieldSubmitted,
//     TextEditingController? controller,
//   }) : super(
//           labelText: 'AMOUNT',
//           hintText: '0.0',
//           onSaved: onSaved,
//           prefix: Text('$currency '.toUpperCase()),
//           controller: controller,
//           focusNode: focusNode,
//           onFieldSubmitted: onFieldSubmitted,
//           textInputAction: textInputAction,
//           prefixStyle:
//               TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w600),
//           validator: (String? value) => validateNum(value),
//         );

//   static String? validateNum(String? input) {
//     return ValidatorUtils.isAmountValid(input) ? null : Strings.invalidAmount;
//   }
// }