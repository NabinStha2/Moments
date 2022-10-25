import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:moment/widgets/custom_cached_network_image_widget.dart';
import 'package:moment/widgets/custom_text_widget.dart';

class CustomListTileWidget extends StatelessWidget {
  final Function? onTap;
  final double? minVerticalPadding;
  final Widget? leadingWidget;
  final Widget? trailingWidget;
  final Widget? titleWidget;
  final Widget? subTitleWidget;
  final String? leadingImageUrl;
  final String? trailingImageUrl;
  final String? titleText;
  final DateTime? subTitleDateTime;
  const CustomListTileWidget({
    Key? key,
    this.onTap,
    this.minVerticalPadding,
    this.leadingWidget,
    this.trailingWidget,
    this.titleWidget,
    this.subTitleWidget,
    this.leadingImageUrl,
    this.trailingImageUrl,
    this.titleText,
    this.subTitleDateTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      enabled: true,
      minVerticalPadding: minVerticalPadding ?? 18,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 5),
      onTap: () {
        onTap!();
      },
      leading: leadingWidget ??
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: CustomCachedNetworkImageWidget(
              imageUrl: leadingImageUrl ??
                  "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fcdn3.iconfinder.com%2Fdata%2Ficons%2Fbusiness-round-flat-vol-1-1%2F36%2Fuser_account_profile_avatar_person_student_male-512.png&f=1&nofb=1",
              height: 50,
              width: 50,
            ),
          ),
      title: titleWidget ?? PoppinsText(titleText ?? ""),
      subtitle: subTitleWidget ??
          PoppinsText(
            timeago.format(
              subTitleDateTime ?? DateTime.now(),
              locale: 'en',
            ),
            color: Colors.black54,
            fontSize: 12.0,
            fontWeight: FontWeight.w400,
          ),
      trailing: trailingWidget ??
          SizedBox(
            height: 50,
            width: 50,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CustomCachedNetworkImageWidget(
                imageUrl: trailingImageUrl ??
                    "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fcdn3.iconfinder.com%2Fdata%2Ficons%2Fbusiness-round-flat-vol-1-1%2F36%2Fuser_account_profile_avatar_person_student_male-512.png&f=1&nofb=1",
                height: 50,
                width: 50,
              ),
            ),
          ),
    );
  }
}
