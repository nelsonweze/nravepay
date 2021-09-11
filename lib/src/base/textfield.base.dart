import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BaseTextField extends TextFormField {
  BaseTextField({
    Widget? suffixIcon,
    Widget? prefix,
    String? labelText,
    String? hintText,
    TextStyle? prefixStyle,
    TextInputType keyboardType = TextInputType.number,
    List<TextInputFormatter>? inputFormatters,
    FormFieldSetter<String>? onSaved,
    FormFieldValidator<String>? validator,
    TextStyle labelStyle = const TextStyle(color: Colors.grey, fontSize: 14),
    TextEditingController? controller,
    String? initialValue,
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    ValueChanged<String>? onFieldSubmitted,
    TextAlign textAlign = TextAlign.start,
    TextStyle? style,
    bool autoFocus = false,
    bool obscureText = false,
  }) : super(
            controller: controller,
            inputFormatters: inputFormatters,
            onSaved: onSaved,
            validator: validator,
            autofocus: autoFocus,
            maxLines: 1,
            style: style,
            textAlign: textAlign,
            initialValue: initialValue,
            keyboardType: keyboardType,
            focusNode: focusNode,
            textInputAction: textInputAction,
            obscureText: obscureText,
            onFieldSubmitted: onFieldSubmitted,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: labelText,
                labelStyle: labelStyle,
                hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
                suffixIcon: suffixIcon == null
                    ? null
                    : Padding(
                        padding: EdgeInsetsDirectional.only(end: 12),
                        child: suffixIcon,
                      ),
                prefix: prefix,
                floatingLabelBehavior: FloatingLabelBehavior.never,
                prefixStyle: prefixStyle,
                errorStyle: TextStyle(fontSize: 12),
                errorMaxLines: 3,
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 15, vertical: 14),
                hintText: hintText));
}
