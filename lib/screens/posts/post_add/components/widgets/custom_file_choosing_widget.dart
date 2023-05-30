import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moment/app/colors.dart';
import 'package:moment/app/dimension/dimension.dart';

import 'package:moment/widgets/custom_button_widget.dart';
import 'package:moment/widgets/custom_image_show_dialog_widget.dart';
import 'package:moment/widgets/custom_text_widget.dart';

import '../../../../../bloc/posts_bloc/posts_bloc.dart';

class CustomFileChoosingWidget extends StatelessWidget {
  final bool isUpdate;
  const CustomFileChoosingWidget({
    Key? key,
    this.isUpdate = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var postBloc = BlocProvider.of<PostsBloc>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CustomElevatedButtonWidget(
          width: appWidth(context) / 3,
          backgroundColor: MColors.primaryGrayColor50,
          onPressed: () async {
            FilePickerResult? result = await customFileShowDialogWidget(
                ctx: context, isImageOnly: false);
            if (result != null) {
              postBloc.add(PostFileSelectedEvent(
                selectedFile: File(result.files.single.path ?? ""),
                isUpdate: isUpdate,
              ));
              // mediaType = result.files.single.path?.split('.').last;
            }
          },
          child: CustomText(
            "Choose File",
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 10.0),
        BlocBuilder<PostsBloc, PostsState>(
          builder: (context, state) {
            if (state is PostFileSelectingLoadingState) {
              return CustomText("Loading...");
            } else if (state is PostFileSelectedState) {
              return SizedBox(
                width: MediaQuery.of(context).size.width / 2.5,
                child: CustomText(
                  isUpdate == true
                      ? postBloc.updatePostSelectedFile?.path.split("/").last ??
                          ""
                      : postBloc.postSelectedFile?.path.split("/").last ?? "",
                  maxLines: 2,
                ),
              );
            }
            return CustomText("");
          },
        )
      ],
    );
  }
}
