import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:moment/widgets/custom_choose_file_widget.dart';
import 'package:moment/widgets/custom_text_widget.dart';

customFileShowDialogWidget({
  required isImageOnly,
  required BuildContext ctx,
}) async {
  return isImageOnly
      ? showDialog(
          context: ctx,
          builder: (_) {
            return AlertDialog(
              title: const Text("Choose:"),
              content: SizedBox(
                width: 250,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: CustomChooseFileWidget.choose.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(CustomChooseFileWidget.choose[index]),
                      onTap: () {
                        CustomChooseFileWidget.chooseFile(
                          ctx: ctx,
                          source: CustomChooseFileWidget.choose[index],
                        );
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: PoppinsText(
                    "cancel",
                    color: Colors.white,
                  ),
                ),
              ],
            );
          },
        )
      : await FilePicker.platform.pickFiles();
}
