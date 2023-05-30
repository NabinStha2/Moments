import 'package:flutter/material.dart';
import 'package:moment/app/colors.dart';
import 'package:moment/widgets/custom_text_widget.dart';

class SenderMessageUi extends StatelessWidget {
  const SenderMessageUi({Key? key, this.message, this.time}) : super(key: key);
  final String? message;
  final String? time;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 45,
          minWidth: 100,
        ),
        child: Card(
          elevation: 1,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomRight: Radius.elliptical(25, 18),
              topLeft: Radius.elliptical(10, 15),
              bottomLeft: Radius.elliptical(10, 15),
            ),
          ),
          color: MColors.primaryGrayColor80,
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 10,
                  right: 30,
                  top: 5,
                  bottom: 20,
                ),
                child: CustomText(
                  message!,
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 10,
                child: Row(
                  children: [
                    CustomText(
                      time!,
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Icon(
                      Icons.done_all,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
