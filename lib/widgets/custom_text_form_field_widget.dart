import 'package:flutter/material.dart';

class CustomTextFormFieldWidget extends StatelessWidget {
  TextEditingController? controller = TextEditingController();
  final bool? showPassword;
  final Function? validator;
  final TextInputType? keyboardType;
  final bool? showSuffix;
  final Widget? suffix;
  final Widget? prefix;
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final EdgeInsets? contentPadding;

  CustomTextFormFieldWidget({
    Key? key,
    this.showPassword,
    this.validator,
    this.keyboardType,
    this.showSuffix = false,
    this.suffix,
    this.prefix,
    this.labelText,
    this.hintText,
    this.errorText,
    this.contentPadding,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autocorrect: true,
      autovalidateMode: AutovalidateMode.disabled,
      controller: controller,
      keyboardType: keyboardType,
      obscureText: showPassword ?? false,
      decoration: InputDecoration(
        suffixIcon: showSuffix ?? false ? suffix : null,
        labelText: labelText ?? "",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            width: 0.7,
            color: Colors.grey.shade400,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            width: 0.7,
            color: Colors.grey.shade400,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            width: 0.7,
            color: Colors.grey.shade500,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(
            width: 0.5,
            color: Colors.red,
          ),
        ),

        prefixIcon: prefix,
        hintText: hintText ?? "",
        // errorText: errorText,
        contentPadding: contentPadding ?? const EdgeInsets.all(8.0),
      ),
      validator: (String? value) {
        return validator != null ? validator!(value) : null;
      },
    );
  }
}
