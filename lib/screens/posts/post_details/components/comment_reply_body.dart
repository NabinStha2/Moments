import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:moment/app/colors.dart';
import 'package:moment/app/dimension/dimension.dart';
import 'package:moment/widgets/custom_text_widget.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:collection/collection.dart';

import '../../../../models/post_model/post_model.dart';

class CommentReplyBody extends StatefulWidget {
  final Comments? cmt;
  const CommentReplyBody({
    Key? key,
    this.cmt,
  }) : super(key: key);

  @override
  State<CommentReplyBody> createState() => _CommentReplyBodyState();
}

class _CommentReplyBodyState extends State<CommentReplyBody> {
  List<int>? ind = [];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          height: widget.cmt != null
              ? (40 * (widget.cmt?.replyComments?.length ?? 0)).toDouble()
              : 0.0,
          child: const VerticalDivider(
            thickness: 1,
            width: 30,
            color: MColors.primaryGrayColor50,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widget.cmt?.replyComments
                    ?.mapIndexed((index, replyCmt) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 5.0,
                            ),
                            (replyCmt.commentName!.split(":")[1].length) <= 100
                                ? Text.rich(
                                    TextSpan(
                                      text:
                                          "${replyCmt.commentName!.split(":")[0]}  ",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: replyCmt.commentName!
                                              .split(":")[1],
                                          style: const TextStyle(
                                            color: MColors.primaryGrayColor35,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Text.rich(
                                    TextSpan(
                                      text:
                                          "${replyCmt.commentName!.split(":")[0]}  ",
                                      style: const TextStyle(
                                        color: MColors.primaryGrayColor35,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: !(ind?.contains(index) == true)
                                              ? "${replyCmt.commentName!.split(":")[1].substring(0, 100)}... "
                                              : "${replyCmt.commentName!.split(":")[1]}... ",
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        TextSpan(
                                          text: !(ind?.contains(index) == true)
                                              ? "show more"
                                              : "show less",
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              setState(() {
                                                ind?.contains(index) == true
                                                    ? ind?.remove(index)
                                                    : ind?.add(index);
                                              });
                                            },
                                          style: const TextStyle(
                                            color: MColors.primaryGrayColor35,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                            CustomText(
                              timeago.format(
                                DateTime.parse(replyCmt.timestamps!),
                                locale: 'en_short',
                              ),
                              color: MColors.primaryGrayColor35,
                              fontSize: 10,
                            ),
                            vSizedBox0,
                          ],
                        ))
                    .toList() ??
                [],
          ),
        ),
      ],
    );
  }
}
