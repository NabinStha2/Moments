import 'package:flutter/material.dart';

class RouteNavigation {
  static back(BuildContext context) {
    Navigator.pop(context);
  }

  static navigate(BuildContext context, dynamic pageRoute) {
    Navigator.push(context, MaterialPageRoute(builder: ((context) => pageRoute)));
  }

  static navigateNamed(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  static navigateOffAllNamed(BuildContext context, String routeName, {Object? args}) {
    Navigator.pushNamedAndRemoveUntil(context, routeName, (route) => false, arguments: args);
  }

  static replaceAndPush(BuildContext context, Widget page) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: ((context) => page)));
  }
}
