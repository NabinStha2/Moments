import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:moment/bloc/postsBloc/posts_bloc.dart';
import 'package:moment/utils/global_keys.dart';
import 'package:moment/utils/storage_services.dart';
import 'package:moment/widgets/custom_button_widget.dart';
import 'package:moment/widgets/custom_snackbar_widget.dart';
import 'package:moment/widgets/custom_text_widget.dart';

class PostAddRequestButton extends StatelessWidget {
  final bool isUpdate;
  final String? postId;
  const PostAddRequestButton({
    Key? key,
    this.isUpdate = false,
    this.postId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomElevatedButtonWidget(
        backgroundColor: Colors.blue,
        onPressed: () async {
          if (StorageServices.authStorageValues.isNotEmpty == true) {
            if (GlobalKeys.postFormKey.currentState?.validate() == true) {
              if (isUpdate == true) {
                if (BlocProvider.of<PostsBloc>(context).updatePostSelectedFile != null) {
                  BlocProvider.of<PostsBloc>(context).add(
                    UpdatePostEvent(
                      // isImage: mediaType.toString() == "mp4" ? false : true,
                      context: context,
                      id: postId ?? "",
                      data: {
                        "name": StorageServices.authStorageValues["name"],
                        "description": BlocProvider.of<PostsBloc>(context).updateDescriptionController.text,
                        "selectedFile": BlocProvider.of<PostsBloc>(context).updatePostSelectedFile ?? "",
                      },
                      token: StorageServices.authStorageValues["token"] ?? "",
                    ),
                  );
                  BlocProvider.of<PostsBloc>(context).add(PostClearValueEvent());
                }
              } else if (BlocProvider.of<PostsBloc>(context).postSelectedFile != null) {
                BlocProvider.of<PostsBloc>(context).add(
                  CreatePostEvent(
                    // isImage: mediaType.toString() == "mp4" ? false : true,
                    context: context,
                    data: {
                      "name": StorageServices.authStorageValues["name"],
                      "description": BlocProvider.of<PostsBloc>(context).descriptionController.text,
                      "selectedFile": BlocProvider.of<PostsBloc>(context).postSelectedFile ?? "",
                    },
                    token: StorageServices.authStorageValues["token"] ?? "",
                  ),
                );
                BlocProvider.of<PostsBloc>(context).add(PostClearValueEvent());
              } else {
                CustomSnackbarWidget.showSnackbar(
                  ctx: context,
                  backgroundColor: Colors.red,
                  content: "File mustn't be empty",
                  secDuration: 2,
                );
              }
            } else {
              CustomSnackbarWidget.showSnackbar(
                ctx: context,
                backgroundColor: Colors.red,
                content: "Description mustn't be empty",
                secDuration: 2,
              );
            }
          } else {
            CustomSnackbarWidget.showSnackbar(
              ctx: context,
              backgroundColor: Colors.red,
              content: "Required Sign In!",
              secDuration: 2,
            );
          }
          BlocProvider.of<PostsBloc>(context).add(PostClearValueEvent());
        },
        child: PoppinsText(isUpdate ? "Update" : "Create", color: Colors.white),
      ),
    );
  }
}
