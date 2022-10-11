import 'package:flutter/material.dart';
import 'package:moment/screens/activity/components/activity_body.dart';
import 'package:moment/widgets/custom_text_widget.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({Key? key}) : super(key: key);

  @override
  State<ActivityScreen> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityScreen> {
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
