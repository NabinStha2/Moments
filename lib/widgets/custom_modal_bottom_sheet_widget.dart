// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moment/app/colors.dart';
import 'package:moment/config/routes/route_navigation.dart';
import 'package:moment/models/post_model/post_model.dart';
import 'package:moment/screens/posts/post_add/components/widgets/post_add_request_button_widget.dart';
import 'package:moment/screens/posts/post_add/components/widgets/custom_file_choosing_widget.dart';
import 'package:moment/utils/global_keys.dart';
import 'package:moment/widgets/custom_text_form_field_widget.dart';
import 'package:moment/widgets/custom_text_widget.dart';

import '../bloc/posts_bloc/posts_bloc.dart';
import '../utils/url_to_file.dart';

void customModalBottomSheetWidget(
    {required BuildContext ctx,
    double? initialChildSize,
    double? minChildSize,
    double? maxChildSize,
    Widget? child,
    PostModelData? post,
    String? title,
    Color? backgroundColor,
    String? subTitle}) async {
  var postBloc = BlocProvider.of<PostsBloc>(ctx);
  if (post != null) {
    postBloc.add(PostFileSelectedEvent(
        selectedFile: await urlToFile(post.file?.fileUrl ?? ""),
        isUpdate: true));
    postBloc.updateDescriptionController.text = post.description ?? "";
  }

  showModalBottomSheet(
    backgroundColor: backgroundColor ?? MColors.primaryGrayColor80,
    context: ctx,
    clipBehavior: Clip.antiAlias,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(24),
      ),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => child != null ? RouteNavigation.back(ctx) : null,
            child: DraggableScrollableSheet(
                initialChildSize: initialChildSize ?? 0.8,
                maxChildSize: maxChildSize ?? 0.8,
                minChildSize: minChildSize ?? 0.4,
                snap: true,
                expand: false,
                builder: (ctx, scrollController) {
                  return child ??
                      Container(
                        padding: const EdgeInsets.all(15),
                        child: SingleChildScrollView(
                          child: Container(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomText(
                                  title,
                                  fontSize: 30.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                                const SizedBox(height: 15.0),
                                Form(
                                  key: GlobalKeys.postFormKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      const SizedBox(height: 20.0),
                                      CustomTextFormFieldWidget(
                                        controller:
                                            BlocProvider.of<PostsBloc>(context)
                                                .updateDescriptionController,
                                        keyboardType: TextInputType.text,
                                        labelText: "Description",
                                        hintText: 'Enter your description',
                                        validator: (String? value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter description';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 20.0),
                                      const CustomFileChoosingWidget(
                                        isUpdate: true,
                                      ),
                                      const SizedBox(height: 20.0),
                                      PostAddRequestButtonWidget(
                                        isUpdate: true,
                                        postId: post?.id,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                }),
          );
        },
      );
    },
  );
}
