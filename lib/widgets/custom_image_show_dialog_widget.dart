import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:moment/app/colors.dart';
import 'package:moment/widgets/custom_button_widget.dart';

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
              backgroundColor: MColors.primaryGrayColor90,
              title: CustomText("Choose:"),
              content: SizedBox(
                width: 250,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: CustomChooseFileWidget.choose.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: CustomText(CustomChooseFileWidget.choose[index]),
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
                CustomElevatedButtonWidget(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: CustomText(
                    "cancel",
                  ),
                ),
              ],
            );
          },
        )
      : await FilePicker.platform.pickFiles();
}
