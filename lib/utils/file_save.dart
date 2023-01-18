// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:moment/config/routes/route_navigation.dart';
import 'package:moment/development/console.dart';
import 'package:moment/utils/permission.dart';
import 'package:moment/widgets/custom_snackbar_widget.dart';
import 'package:path_provider/path_provider.dart';

import '../bloc/posts_bloc/posts_bloc.dart';

saveImage(
    {required BuildContext ctx,
    required String imageUrl,
    bool? isFromPostDetails = false,
    Function? startProgressChanged,
    Function? finalProgressChanged}) async {
  startProgressChanged != null ? startProgressChanged() : null;
  if (await askPermission()) {
    var response = await Dio().get(imageUrl, options: Options(responseType: ResponseType.bytes), onReceiveProgress: (value1, value2) {
      finalProgressChanged != null ? finalProgressChanged(value1, value2) : null;
    });
    final result = await ImageGallerySaver.saveImage(
      Uint8List.fromList(response.data),
      quality: 100,
    );
    if (result["isSuccess"]) {
      CustomSnackbarWidget.showSnackbar(content: "Image saved.", milliDuration: 1000, ctx: ctx, backgroundColor: Colors.green);
    } else {
      CustomSnackbarWidget.showSnackbar(content: "Problem saving image!", milliDuration: 400, ctx: ctx, backgroundColor: Colors.red);
    }
    BlocProvider.of<PostsBloc>(ctx).add(HideFileDownloadLoadingEvent());
    isFromPostDetails == true ? null : RouteNavigation.back(ctx);
  } else {
    CustomSnackbarWidget.showSnackbar(content: "First allow access to save images!", milliDuration: 400, ctx: ctx, backgroundColor: Colors.red);
  }
}

Future<bool> saveVideo(
  String url,
  String fileName,
  Function? finalProgressChanged,
) async {
  try {
    Directory? directory;
    File saveFile;
    if (await askPermission()) {
      directory = await getExternalStorageDirectory();
      String newPath = "";
      List<String> paths = directory?.path.split("/") ?? [];
      if (paths.isNotEmpty == true) {
        for (int x = 1; x < paths.length; x++) {
          String folder = paths[x];
          if (folder != "Android") {
            newPath += "/$folder";
          } else {
            break;
          }
        }
        directory = Directory(newPath);
      }
    } else {
      return false;
    }
    if (await directory?.exists() == false) {
      await directory?.create(recursive: true);
    }
    saveFile = File("${directory?.path}/$fileName");
    if (await directory!.exists()) {
      await Dio().download(url, saveFile.path, onReceiveProgress: (value1, value2) {
        finalProgressChanged != null ? finalProgressChanged(value1, value2) : null;
      });
      if (Platform.isIOS) {
        await ImageGallerySaver.saveFile(saveFile.path, isReturnPathOfIOS: true);
        return false;
      }
      return true;
    }
    return false;
  } catch (e) {
    consolelog("Err: $e");
    return false;
  }
}

downloadVideo(
    {required BuildContext ctx, Function()? startProgressChanged, Function? finalProgressChanged, String? fileUrl, String? fileName}) async {
  startProgressChanged != null ? startProgressChanged() : null;
  CustomSnackbarWidget.showSnackbar(content: "Don't go back until video is saved!", milliDuration: 400, ctx: ctx, backgroundColor: Colors.grey);
  bool downloaded = await saveVideo(fileUrl ?? "", "$fileName.mp4", finalProgressChanged);
  if (downloaded) {
    CustomSnackbarWidget.showSnackbar(content: "Video Downloaded.", milliDuration: 1000, ctx: ctx, backgroundColor: Colors.green);
  } else {
    CustomSnackbarWidget.showSnackbar(content: "Problem downloading a file!", milliDuration: 400, ctx: ctx, backgroundColor: Colors.red);
  }
  BlocProvider.of<PostsBloc>(ctx).add(HideFileDownloadLoadingEvent());
}
