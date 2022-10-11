import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moment/bloc/postsBloc/posts_bloc.dart';
import 'package:moment/screens/post_add/components/post_add_request_button.dart';
import 'package:moment/screens/post_add/components/widgets/custom_file_choosing_widget.dart';
import 'package:moment/utils/global_keys.dart';
import 'package:moment/widgets/custom_snackbar_widget.dart';
import 'package:moment/widgets/custom_text_form_field_widget.dart';
import 'package:moment/widgets/custom_text_widget.dart';

class PostAddBody extends StatefulWidget {
  const PostAddBody({super.key});

  @override
  State<PostAddBody> createState() => _PostAddBodyState();
}

class _PostAddBodyState extends State<PostAddBody> {
  // var mediaType;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      BlocProvider.of<PostsBloc>(context).add(PostClearValueEvent());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PostsBloc, PostsState>(
      listener: (context, state) {
        if (state is PostCreated) {
          CustomSnackbarWidget.showSnackbar(
            ctx: context,
            backgroundColor: Colors.green,
            content: 'Post created successfully.',
            secDuration: 2,
          );
        }
        if (state is PostError) {
          CustomSnackbarWidget.showSnackbar(
            ctx: context,
            backgroundColor: Colors.red,
            content: state.error,
            secDuration: 2,
          );
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
                const SizedBox(height: 15.0),
                Form(
                  key: GlobalKeys.postFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: 10.0),
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
                      const SizedBox(height: 10.0),
                      const CustomFileChoosingWidget(),
                      const SizedBox(height: 15.0),
                      const PostAddRequestButton(
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
