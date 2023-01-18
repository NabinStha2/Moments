import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moment/utils/storage_services.dart';

import '../bloc/auth_bloc/auth_bloc.dart';

class CustomChooseFileWidget {
  static List choose = ["camera", "gallery"];
  static final ImagePicker _picker = ImagePicker();

  static Future<void> chooseFile({String? source, required BuildContext ctx}) async {
    var authBlocProvider = BlocProvider.of<AuthBloc>(ctx);
    final pickedFile = await _picker.pickImage(
      source: source == "camera" ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 100,
    );

    if (pickedFile != null) {
      authBlocProvider.setUserSelectedFile(selectedFile: File(pickedFile.path));
    }
    if (authBlocProvider.userSelectedFile != null) {
      authBlocProvider.add(UploadImageEvent(
        context: ctx,
        id: StorageServices.authStorageValues["id"]!,
        image: authBlocProvider.userSelectedFile,
      ));
    }
  }
}
