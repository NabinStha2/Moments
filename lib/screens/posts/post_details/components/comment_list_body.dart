import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moment/app/dimension/dimension.dart';
import 'package:moment/screens/posts/post_details/components/comment_reply_body.dart';
import 'package:moment/screens/posts/post_details/components/widgets/show_bottom_text_field_widget.dart';
import 'package:moment/utils/storage_services.dart';
import 'package:moment/widgets/custom_text_widget.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../bloc/posts_bloc/posts_bloc.dart';

class CommentListBody extends StatefulWidget {
  const CommentListBody({super.key});

  @override
  State<CommentListBody> createState() => _CommentListBodyState();
}

class _CommentListBodyState extends State<CommentListBody> {
  List<int>? ind = [];

  @override
  Widget build(BuildContext context) {
    var postBloc = BlocProvider.of<PostsBloc>(context);
    return BlocBuilder<PostsBloc, PostsState>(
      builder: (context, state) {
        return postBloc.singlePostData?.comments?.isNotEmpty == true
            ? ListView.builder(
                primary: false,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: postBloc.singlePostData?.comments?.length ?? 0,
                itemBuilder: (context, index) {
                  var cmt = postBloc.singlePostData?.comments;
                  return Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: postBloc.deleteIndex != null && postBloc.deleteIndex == index ? Colors.white.withOpacity(0.5) : Colors.transparent,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          splashColor: Colors.grey,
                          onLongPress: postBloc.showCommentDelete
                              ? null
                              : () {
                                  if (StorageServices.authStorageValues.isNotEmpty == true &&
                                      StorageServices.authStorageValues["id"] == cmt?[index].commentUserId) {
                                    postBloc.add(ShowCommentDeleteEvent(
                                      cmt: cmt?[index],
                                      index: index,
                                      showCommentDelete: true,
                                    ));
                                  }
                                },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text.rich(
                                TextSpan(
                                  text: "${cmt?[index].commentName!.split(":")[0]}  ",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  children: [
                                    (cmt?[index].commentName!.split(":")[1].length ?? 0) <= 100
                                        ? TextSpan(
                                            text: cmt?[index].commentName!.split(":")[1],
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          )
                                        : TextSpan(
                                            text: !(ind?.contains(index) == true)
                                                ? "${cmt?[index].commentName!.split(":")[1].substring(0, 100)}... "
                                                : "${cmt?[index].commentName!.split(":")[1]}... ",
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: !(ind?.contains(index) == true) ? "show more" : "show less",
                                                recognizer: TapGestureRecognizer()
                                                  ..onTap = () {
                                                    setState(() {
                                                      ind?.contains(index) == true ? ind?.remove(index) : ind?.add(index);
                                                    });
                                                  },
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontWeight: FontWeight.w300,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ],
                                ),
                              ),
                              vSizedBox0,
                              Row(
                                children: [
                                  PoppinsText(
                                    timeago.format(
                                      DateTime.parse(cmt?[index].timestamps ?? ""),
                                      locale: 'en_short',
                                    ),
                                    color: Colors.grey.shade700,
                                    fontSize: 10,
                                  ),
                                  const SizedBox(
                                    width: 10.0,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      postBloc.add(
                                        ShowReplyCommentEvent(
                                          showReplyComment: true,
                                          replyTo: cmt?[index].commentName!.split(":")[0],
                                          commentId: cmt?[index].commentId,
                                          replyToUserId: cmt?[index].commentUserId,
                                        ),
                                      );
                                      commentFocusNode.requestFocus();
                                    },
                                    child: PoppinsText(
                                      "Reply",
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        cmt?[index].replyComments?.isNotEmpty == true
                            ? CommentReplyBody(
                                cmt: cmt?[index],
                              )
                            : Container(),
                        vSizedBox1,
                        const Divider(
                          thickness: 1,
                          endIndent: 30,
                          indent: 40,
                        ),
                      ],
                    ),
                  );
                },
              )
            : const Text("No Comments!");
      },
    );
  }
}
