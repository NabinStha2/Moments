import 'package:flutter/material.dart';

import '../app/dimension/dimension.dart';
import 'custom_text_widget.dart';

class CustomErrorWidget extends StatelessWidget {
  final String? message;
  final Function()? onPressed;
  const CustomErrorWidget({super.key, this.message, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          PoppinsText(message ?? ""),
          vSizedBox2,
          IconButton(
            onPressed: onPressed,
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(height: 15),
          // Text(state.error!, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
