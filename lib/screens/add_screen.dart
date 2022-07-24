import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moment/bloc/auth_bloc.dart';
import 'package:moment/bloc/posts_bloc.dart';
import 'package:moment/main.dart';
import 'package:moment/models/post_model.dart';
import 'package:moment/screens/home_screen.dart';
import 'package:moment/screens/news_feed_screen.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class AddScreen extends StatefulWidget {
  final bool isUpdate;
  final PostModel? post;
  const AddScreen({
    Key? key,
    this.isUpdate = false,
    this.post,
  }) : super(key: key);

  @override
  _AddScreenState createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = new TextEditingController();
  final TextEditingController descriptionController =
      new TextEditingController();
  final TextEditingController tagsController = new TextEditingController();
  File? selectedFile;
  List choose = ["image", "video"];
  // List choose = ["camera", "gallery"];
  final _picker = ImagePicker();
  var post;

  Map<String, String>? authStorageValue;

  Future<File> urlToFile(String imageUrl) async {
// generate random number.
    var rng = new Random();
// get temporary directory of device.
    Directory tempDir = await getTemporaryDirectory();
// get temporary path from temporary directory.
    String tempPath = tempDir.path;
// create a new file in temporary path with random file name.
    File file = new File('$tempPath' + (rng.nextInt(100)).toString() + '.png');

// call http.get method and pass imageUrl into it to get response.
    http.Response response = await http.get(Uri.parse(imageUrl));
// write bodyBytes received in response to file.
    await file.writeAsBytes(response.bodyBytes);
// now return the file which is created with random name in
// temporary directory and image bytes from response is written to // that file.
    return file;
  }

  @override
  void initState() {
    super.initState();
    // debugPrintStack(label: "hey", maxFrames: 2);
    // BlocProvider.of<PostBloc>(context).add(GetPostsEvent());
    post = widget.post;
    debugPrint("$post");
    if (post != null) {
      getUrlToFile();

      // titleController.text = post.title;
      descriptionController.text = post.description;
      // tagsController.text = post.tags.join(" ");
    }

    getStorage();
  }

  getUrlToFile() async {
    selectedFile = await urlToFile(widget.post!.fileUrl);
    // "http://192.168.1.19:3000/${widget.post!.selectedFile}");
    setState(() {});
    inspect(selectedFile);
  }

  getStorage() async {
    var auth = await storage.readAll(
      aOptions: const AndroidOptions(),
      iOptions: IOSOptions(
        accountName: accountNameController.text.isEmpty
            ? null
            : accountNameController.text,
      ),
    );
    setState(() {
      authStorageValue = auth;
    });
    // print(authStorageValue);
  }

  Future<void> _chooseFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    // inspect(result);
    setState(() {
      if (result != null) {
        selectedFile = File(result.files.single.path!);
        inspect(selectedFile);
      }
    });
  }

  // Future<void> _chooseImage(String source) async {
  //   final pickedFile = await _picker.pickImage(
  //     source: source == "camera" ? ImageSource.camera : ImageSource.gallery,
  //     imageQuality: 100,
  //   );
  //   // final bytes = await pickedFile?.readAsBytes();

  //   setState(() {
  //     if (pickedFile != null) {
  //       selectedFile = File(pickedFile.path);
  //       inspect(selectedFile);
  //     }
  //   });

  //   if (pickedFile == null) {
  //     LostDataResponse response = await _picker.retrieveLostData();

  //     if (response.isEmpty) {
  //       return null;
  //     }
  //     if (response.file != null) {
  //       setState(() {
  //         if (pickedFile != null) {
  //           selectedFile = File(response.file!.path);
  //           // inspect(selectedFile);
  //         }
  //       });
  //     } else {
  //       print(response.file);
  //     }
  //   }
  // }

  // Future<void> _showDialog() async {
  //   return await showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: Text("Choose:"),
  //         content: Container(
  //           width: 250,
  //           child: ListView.builder(
  //             shrinkWrap: true,
  //             itemCount: choose.length,
  //             itemBuilder: (BuildContext context, int index) {
  //               return ListTile(
  //                 title: Text(choose[index]),
  //                 onTap: () {
  //                   _chooseImage(choose[index]);
  //                   Navigator.pop(context);
  //                 },
  //               );
  //             },
  //           ),
  //         ),
  //         actions: [
  //           ElevatedButton(
  //             onPressed: () => Navigator.of(context).pop(),
  //             child: Text("cancel"),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    // print(widget.isUpdate);
    return widget.isUpdate == true
        ? Scaffold(
            appBar: AppBar(
              title: const Text("Update"),
              automaticallyImplyLeading: false,
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            body: blocWidget(),
          )
        : blocWidget();
  }

  Widget blocWidget() {
    return BlocListener<PostsBloc, PostsState>(
      listener: (context, state) {
        if (state is PostCreated) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.green,
                content: Text("Post created successfully"),
                elevation: 0.0,
                duration: const Duration(seconds: 2),
              ),
            );
        }
        if (state is PostError) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.red,
                content: Text(state.error!),
                elevation: 0.0,
                duration: const Duration(seconds: 2),
              ),
            );
        }
      },
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10.0),
            // alignment: Alignment.center,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${!widget.isUpdate ? "Create" : "Update"}",
                  style: TextStyle(
                    fontSize: 30.0,
                    fontFamily: GoogleFonts.courgette().fontFamily,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 15.0),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // TextFormField(
                      //   controller: titleController,
                      //   keyboardType: TextInputType.text,
                      //   decoration: InputDecoration(
                      //     labelText: "Title",
                      //     border: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(20.0),
                      //     ),
                      //     hintText: 'Enter your title',
                      //   ),
                      //   validator: (String? value) {
                      //     if (value == null || value.isEmpty) {
                      //       return 'Please enter title';
                      //     }
                      //     return null;
                      //   },
                      // ),
                      const SizedBox(height: 10.0),
                      TextFormField(
                        controller: descriptionController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: "Description",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          hintText: 'Enter your description',
                        ),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter description';
                          }
                          return null;
                        },
                      ),
                      // const SizedBox(height: 10.0),
                      // TextFormField(
                      //   controller: tagsController,
                      //   keyboardType: TextInputType.text,
                      //   decoration: InputDecoration(
                      //     labelText: "Tags",
                      //     border: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(20.0),
                      //     ),
                      //     hintText:
                      //         'Enter your tags using hash and separate with spaces',
                      //     hintMaxLines: 2,
                      //   ),
                      //   validator: (String? value) {
                      //     if (value == null || value.isEmpty) {
                      //       return 'Please enter tags';
                      //     }
                      //     return null;
                      //   },
                      // ),
                      const SizedBox(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            clipBehavior: Clip.antiAlias,
                            style: ButtonStyle(
                              overlayColor: MaterialStateProperty.all(
                                  Colors.grey.shade300),
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.white),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                              fixedSize: MaterialStateProperty.all(
                                Size.fromWidth(
                                    MediaQuery.of(context).size.width / 2.5),
                              ),
                            ),
                            onPressed: () {
                              _chooseFile();
                            },
                            child: const Text(
                              "Choose File",
                              style: const TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          selectedFile != null
                              ? Container(
                                  width:
                                      MediaQuery.of(context).size.width / 2.5,
                                  child: Text(
                                    selectedFile!.path,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                )
                              : Container(
                                  child: widget.isUpdate
                                      ? const Text("Loading Image")
                                      : const Text(""),
                                ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: ElevatedButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                              fixedSize: MaterialStateProperty.all(
                                Size.fromWidth(
                                    MediaQuery.of(context).size.width / 2.5),
                              ),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                if (authStorageValue != null &&
                                    authStorageValue?.length != 0) {
                                  if (selectedFile != null) {
                                    print("success");

                                    if (widget.isUpdate) {
                                      print("updating post from addscreen");
                                      BlocProvider.of<PostsBloc>(context).add(
                                        UpdatePostEvent(
                                          id: widget.post!.id!,
                                          data: {
                                            // "title": titleController.text,
                                            "description":
                                                descriptionController.text,
                                            "selectedFile": selectedFile,
                                            // "tags": tagsController.text,
                                          },
                                          token: authStorageValue!["token"]!,
                                        ),
                                      );

                                      BlocProvider.of<PostsBloc>(context)
                                          .add(GetSinglePostEvent(
                                        id: widget.post!.id!,
                                      ));
                                      Navigator.of(context).pop(true);
                                    } else {
                                      // posts.clear();
                                      // var deviceState =
                                      //     await handleGetDeviceState();

                                      // for (var i = 0; i < 20; i++) {
                                      BlocProvider.of<PostsBloc>(context).add(
                                        CreatePostEvent(
                                          data: {
                                            // "title": titleController.text,
                                            "name": authStorageValue!["name"],
                                            "description":
                                                descriptionController.text,
                                            // "tags": tagsController.text,
                                            "selectedFile": selectedFile,
                                          },
                                          token: authStorageValue!["token"]!,
                                        ),
                                      );
                                      titleController.text = "";
                                      descriptionController.text = "";
                                      tagsController.text = "";
                                      setState(() {
                                        selectedFile = null;
                                      });
                                      BlocProvider.of<PostsBloc>(context).add(
                                        RefreshPostsEvent(),
                                      );
                                      BlocProvider.of<PostsBloc>(context).add(
                                        const GetPostsEvent(),
                                      );
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context)
                                      ..hideCurrentSnackBar()
                                      ..showSnackBar(
                                        const SnackBar(
                                          behavior: SnackBarBehavior.floating,
                                          content:
                                              Text("File mustn't be empty"),
                                          elevation: 0.0,
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                  }
                                } else {
                                  ScaffoldMessenger.of(context)
                                    ..hideCurrentSnackBar()
                                    ..showSnackBar(
                                      const SnackBar(
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: Colors.red,
                                        content: Text("Required Sign In!"),
                                        elevation: 0.0,
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                }
                              }
                            },
                            child: BlocBuilder<PostsBloc, PostsState>(
                                builder: (context, state) {
                              if (state is PostLoading) {
                                return const Center(
                                  child: SpinKitCircle(
                                    color: Colors.white,
                                    size: 30.0,
                                  ),
                                );
                              }
                              return !widget.isUpdate
                                  ? const Text("Create")
                                  : const Text("Update");
                            }),
                          ),
                        ),
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
