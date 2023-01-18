import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moment/app/dimension/dimension.dart';
import 'package:moment/screens/posts/post_add/components/widgets/post_add_request_button_widget.dart';
import 'package:moment/screens/posts/post_add/components/widgets/custom_file_choosing_widget.dart';
import 'package:moment/utils/global_keys.dart';
import 'package:moment/widgets/custom_snackbar_widget.dart';
import 'package:moment/widgets/custom_text_form_field_widget.dart';
import 'package:moment/widgets/custom_text_widget.dart';

import '../../../../bloc/posts_bloc/posts_bloc.dart';
import '../../../../bloc/profile_posts_bloc/profile_posts_bloc.dart';
import '../../../../utils/storage_services.dart';

class PostAddBody extends StatelessWidget {
  const PostAddBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<PostsBloc, PostsState>(
      listener: (context, state) {
        if (state is PostCreated) {
          BlocProvider.of<PostsBloc>(context).add(
            RefreshPostsEvent(),
          );
          BlocProvider.of<PostsBloc>(context).add(
            GetPostsEvent(context: context),
          );
          BlocProvider.of<ProfilePostsBloc>(context).add(
            GetProfilePostsEvent(
              context: context,
              creator: StorageServices.authStorageValues["id"] ?? "",
            ),
          );
          CustomSnackbarWidget.showSnackbar(ctx: context, backgroundColor: Colors.green, content: 'Post created successfully.', secDuration: 1);
        }
        if (state is PostError) {
          // CustomDialogs.showCustomActionDialog(ctx: context, message: state.error);
          CustomSnackbarWidget.showSnackbar(ctx: context, backgroundColor: Colors.red, content: state.error, secDuration: 2);
        }
      },
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PoppinsText(
                  "Create",
                  fontSize: 30.0,
                  fontWeight: FontWeight.w600,
                ),
                vSizedBox0,
                vSizedBox1,
                Form(
                  key: GlobalKeys.postFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      vSizedBox0,
                      vSizedBox1,
                      CustomTextFormFieldWidget(
                        controller: BlocProvider.of<PostsBloc>(context).descriptionController,
                        keyboardType: TextInputType.text,
                        labelText: "Description",
                        hintText: 'Enter your description here',
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter description';
                          }
                          return null;
                        },
                      ),
                      vSizedBox2,
                      const CustomFileChoosingWidget(),
                      vSizedBox2,
                      const PostAddRequestButtonWidget(
                        isUpdate: false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
