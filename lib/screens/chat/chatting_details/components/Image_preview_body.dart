import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moment/widgets/custom_circular_progress_indicator_widget.dart';

import '../../../../bloc/auth_bloc/auth_bloc.dart';

class ImagePreviewBody extends StatelessWidget {
  final String path;
  final Function? sendFile;
  ImagePreviewBody({
    Key? key,
    required this.path,
    this.sendFile,
  }) : super(key: key);

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    log("Camera view page");
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        // actions: [
        //   IconButton(
        //       icon: const Icon(
        //         Icons.crop_rotate,
        //         size: 27,
        //       ),
        //       onPressed: () {}),
        //   IconButton(
        //       icon: const Icon(
        //         Icons.emoji_emotions_outlined,
        //         size: 27,
        //       ),
        //       onPressed: () {}),
        //   IconButton(
        //       icon: const Icon(
        //         Icons.title,
        //         size: 27,
        //       ),
        //       onPressed: () {}),
        //   IconButton(
        //       icon: const Icon(
        //         Icons.edit,
        //         size: 27,
        //       ),
        //       onPressed: () {}),
        // ],
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 150,
              child: Image.file(
                File(path),
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                color: Colors.black38,
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                child: TextFormField(
                  controller: _controller,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                  ),
                  maxLines: 6,
                  minLines: 1,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Add Caption....",
                    prefixIcon: const Icon(
                      Icons.add_photo_alternate,
                      color: Colors.white,
                      size: 27,
                    ),
                    hintStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                    ),
                    suffixIcon: BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
                      if (state is UploadMsgImageLoading) {
                        return Container(
                          width: 30.0,
                          alignment: Alignment.center,
                          height: 30.0,
                          child: const Center(
                            widthFactor: 27.0,
                            child: CustomCircularProgressIndicatorWidget(),
                          ),
                        );
                      }
                      return InkWell(
                        onTap: () {
                          log("Send Image");
                          sendFile!(path, _controller.text, "image");
                        },
                        child: CircleAvatar(
                          radius: 27,
                          backgroundColor: Colors.tealAccent[700],
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 27,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
