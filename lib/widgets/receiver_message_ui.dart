import 'package:flutter/material.dart';
import 'package:moment/widgets/custom_text_widget.dart';

class ReceiverMessageUi extends StatelessWidget {
  const ReceiverMessageUi({Key? key, this.message, this.time}) : super(key: key);
  final String? message;
  final String? time;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 45,
        ),
        child: Card(
          elevation: 1,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.elliptical(25, 18),
              topRight: Radius.elliptical(10, 15),
              bottomRight: Radius.elliptical(10, 15),
            ),
          ),
          color: Colors.grey[350],
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 8,
                  right: 50,
                  top: 5,
                  bottom: 18,
                ),
                child: PoppinsText(
                  message!,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 10,
                child: PoppinsText(
                  time!,
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
