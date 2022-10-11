import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PoppinsText extends StatelessWidget {
  String? text;
  double? fontSize;
  FontWeight? fontWeight;
  double? letterSpacing;
  Color? color;
  int? maxLines;
  TextAlign textAlign;
  PoppinsText(
    this.text, {
    Key? key,
    this.textAlign = TextAlign.justify,
    this.maxLines,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.letterSpacing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text ?? "",
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : null,
      style: GoogleFonts.poppins(
        fontSize: fontSize ?? 14,
        fontWeight: fontWeight ?? FontWeight.w500,
        color: color ?? Colors.black,
        letterSpacing: letterSpacing ?? -0.2,
      ),
    );
  }
}

class AppBarCookieText extends StatelessWidget {
  String? text;
  double? fontSize;
  FontWeight? fontWeight;
  double? letterSpacing;
  Color? color;
  int? maxLines;
  TextAlign textAlign;
  AppBarCookieText(
    this.text, {
    Key? key,
    this.textAlign = TextAlign.justify,
    this.maxLines,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.letterSpacing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text ?? "",
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : null,
      style: GoogleFonts.cookie(
        fontSize: fontSize ?? 35,
        fontWeight: fontWeight ?? FontWeight.w500,
        color: color ?? Colors.white,
        letterSpacing: letterSpacing ?? -0.2,
      ),
    );
  }
}
