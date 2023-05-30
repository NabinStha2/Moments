import 'package:flutter/material.dart';
import 'package:moment/app/colors.dart';
import 'package:moment/development/console.dart';

class CustomTextFormFieldWidget extends StatelessWidget {
  TextEditingController? controller = TextEditingController();
  final bool? showPassword;
  final Function? validator;
  final TextInputType? keyboardType;
  final bool? showSuffix;
  final bool? autofocus;
  final bool isFilled;
  final FocusNode? focusNode;
  final Widget? suffix;
  final Widget? prefix;
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final Color? fillColor;
  final EdgeInsets? contentPadding;

  CustomTextFormFieldWidget({
    Key? key,
    this.showPassword,
    this.validator,
    this.keyboardType,
    this.showSuffix = false,
    this.autofocus,
    this.isFilled = false,
    this.suffix,
    this.prefix,
    this.labelText,
    this.hintText,
    this.errorText,
    this.fillColor,
    this.focusNode,
    this.contentPadding,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    consolelog(autofocus);
    return TextFormField(
      focusNode: focusNode,
      cursorColor: Colors.white,
      autocorrect: true,
      autofocus: autofocus ?? false,
      autovalidateMode: AutovalidateMode.disabled,
      controller: controller,
      keyboardType: keyboardType,
      obscureText: showPassword ?? false,
      style: const TextStyle(
        color: Colors.white,
      ),
      decoration: InputDecoration(
        labelStyle: const TextStyle(
          color: MColors.primaryGrayColor50,
        ),
        hintStyle: const TextStyle(
          color: MColors.primaryGrayColor50,
        ),
        suffixIcon: showSuffix ?? false ? suffix : null,
        labelText: labelText ?? "",
        hintText: hintText ?? "",
        fillColor: fillColor,
        filled: isFilled,
        border: isFilled
            ? InputBorder.none
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(
                  width: 0.7,
                  color: MColors.primaryGrayColor50,
                ),
              ),
        enabledBorder: isFilled
            ? InputBorder.none
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(
                  width: 0.7,
                  color: MColors.primaryGrayColor50,
                ),
              ),
        focusedBorder: isFilled
            ? InputBorder.none
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(
                  width: 0.7,
                  color: MColors.primaryGrayColor50,
                ),
              ),
        errorBorder: isFilled
            ? InputBorder.none
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(
                  width: 0.5,
                  color: Colors.red,
                ),
              ),
        prefixIcon: prefix,
        // errorText: errorText,
        contentPadding: contentPadding ?? const EdgeInsets.all(8.0),
      ),
      validator: (String? value) {
        return validator != null ? validator!(value) : null;
      },
    );
  }
}
