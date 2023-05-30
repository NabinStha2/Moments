import 'package:flutter/material.dart';
import 'package:moment/app/colors.dart';

class CustomElevatedButtonWidget extends StatelessWidget {
  final Widget? child;
  final double? height;
  final double? width;
  final double? borderRadius;
  final Color? backgroundColor;
  final double? elevation;
  final Alignment? alignment;
  final double? padding;
  final Function onPressed;

  const CustomElevatedButtonWidget({
    Key? key,
    this.child,
    this.height,
    this.width,
    this.borderRadius,
    this.backgroundColor,
    this.elevation,
    this.alignment,
    this.padding,
    required this.onPressed,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 42,
      width: width ?? double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 20.0),
          ),
          backgroundColor: backgroundColor ?? MColors.primaryGrayColor80,
          elevation: elevation ?? 0.0,
          splashFactory: InkSplash.splashFactory,
          alignment: alignment ?? Alignment.center,
          foregroundColor: MColors.primaryColor,
          padding: EdgeInsets.all(padding ?? 2.0),
        ),
        onPressed: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus &&
              currentFocus.focusedChild != null) {
            currentFocus.focusedChild!.unfocus();
          }
          onPressed();
        },
        child: child,
      ),
    );
  }
}

class CustomTextButtonWidget extends StatelessWidget {
  final Widget child;
  final double? height;
  final double? width;
  final double? borderRadius;
  final Color? backgroundColor;
  final double? elevation;
  final Alignment? alignment;
  final double? padding;
  final Function onPressed;

  const CustomTextButtonWidget({
    Key? key,
    required this.child,
    this.height,
    this.width,
    this.borderRadius,
    this.backgroundColor,
    this.elevation,
    this.alignment,
    this.padding,
    required this.onPressed,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 42,
      width: width ?? double.infinity,
      child: TextButton(
        style: TextButton.styleFrom(
          elevation: elevation ?? 0.0,
          alignment: alignment ?? Alignment.center,
          padding: EdgeInsets.all(padding ?? 2.0),
        ),
        onPressed: () {
          onPressed();
        },
        child: child,
      ),
    );
  }
}

class CustomIconButtonWidget extends StatelessWidget {
  final Widget? icon;
  final double? height;
  final double? width;
  final double? borderRadius;
  final Color? color;
  final double? elevation;
  final double? iconSize;
  final double? splashRadius;
  final Alignment? alignment;
  final EdgeInsets? padding;
  final Function onPressed;
  final bool isFloatingButton;
  final Color? floatingButtonContainerColor;

  const CustomIconButtonWidget({
    Key? key,
    required this.icon,
    this.height,
    this.width,
    this.borderRadius,
    this.color,
    this.elevation,
    this.iconSize,
    this.splashRadius,
    this.alignment,
    this.padding,
    required this.onPressed,
    this.isFloatingButton = false,
    this.floatingButtonContainerColor,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(8.0),
      child: Container(
        height: height ?? 60,
        width: width ?? 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isFloatingButton
              ? floatingButtonContainerColor
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: IconButton(
            padding: padding ?? const EdgeInsets.all(15.0),
            splashRadius: splashRadius ?? 1.0,
            alignment: alignment ?? Alignment.center,
            color: color ?? Colors.white,
            style: IconButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius ?? 20.0),
              ),
              elevation: elevation ?? 0.0,
              splashFactory: InkSplash.splashFactory,
            ),
            iconSize: iconSize ?? 24.0,
            onPressed: () {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus &&
                  currentFocus.focusedChild != null) {
                currentFocus.focusedChild!.unfocus();
              }
              onPressed();
            },
            icon: icon ?? Container(),
          ),
        ),
      ),
    );
  }
}
