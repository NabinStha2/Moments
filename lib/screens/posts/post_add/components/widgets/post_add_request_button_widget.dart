import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:moment/utils/global_keys.dart';
import 'package:moment/utils/storage_services.dart';
import 'package:moment/widgets/custom_button_widget.dart';
import 'package:moment/widgets/custom_snackbar_widget.dart';
import 'package:moment/widgets/custom_text_widget.dart';

import '../../../../../bloc/posts_bloc/posts_bloc.dart';

class PostAddRequestButtonWidget extends StatelessWidget {
  final bool isUpdate;
  final String? postId;
  const PostAddRequestButtonWidget({
    Key? key,
    this.isUpdate = false,
    this.postId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var postBloc = BlocProvider.of<PostsBloc>(context);
    return Center(
      child: CustomElevatedButtonWidget(
        onPressed: () async {
          if (StorageServices.authStorageValues.isNotEmpty == true) {
            if (GlobalKeys.postFormKey.currentState?.validate() == true) {
              if (isUpdate == true) {
                if (postBloc.updatePostSelectedFile != null) {
                  postBloc.add(
                    UpdatePostEvent(
                      // isImage: mediaType.toString() == "mp4" ? false : true,
                      context: context,
                      id: postId ?? "",
                      data: {
                        "name": StorageServices.authStorageValues["name"],
                        "description": postBloc.updateDescriptionController.text,
                        "selectedFile": postBloc.updatePostSelectedFile ?? "",
                      },
                      token: StorageServices.authStorageValues["token"] ?? "",
                    ),
                  );
                  postBloc.add(PostClearValueEvent());
                }
              } else if (postBloc.postSelectedFile != null) {
                postBloc.add(
                  CreatePostEvent(
                    // isImage: mediaType.toString() == "mp4" ? false : true,
                    context: context,
                    data: {
                      "name": StorageServices.authStorageValues["name"],
                      "description": postBloc.descriptionController.text,
                      "selectedFile": postBloc.postSelectedFile ?? "",
                    },
                    token: StorageServices.authStorageValues["token"] ?? "",
                  ),
                );
                postBloc.add(PostClearValueEvent());
              } else {
                CustomSnackbarWidget.showSnackbar(
                  ctx: context,
                  backgroundColor: Colors.red,
                  content: "File mustn't be empty",
                  secDuration: 2,
                );
              }
            } else {
              CustomSnackbarWidget.showSnackbar(ctx: context, backgroundColor: Colors.red, content: "Description mustn't be empty", secDuration: 2);
            }
          } else {
            CustomSnackbarWidget.showSnackbar(ctx: context, backgroundColor: Colors.red, content: "Required Sign In!", secDuration: 2);
          }
        },
        child: PoppinsText(isUpdate ? "Update" : "Create", color: Colors.white),
      ),
    );
  }
}
