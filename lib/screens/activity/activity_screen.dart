import 'package:flutter/material.dart';
import 'package:moment/screens/activity/components/activity_body.dart';
import 'package:moment/widgets/custom_text_widget.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarCookieText(
          "Activity",
          color: Colors.white,
        ),
      ),
      body: const ActivityBody(),
    );
  }
}
