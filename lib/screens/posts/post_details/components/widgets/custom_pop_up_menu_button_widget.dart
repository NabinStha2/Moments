import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:moment/utils/storage_services.dart';
import 'package:moment/widgets/custom_modal_bottom_sheet_widget.dart';

import '../../../../../bloc/posts_bloc/posts_bloc.dart';

class CustomPopUpMenuButtonWidget extends StatelessWidget {
  final String? userVisitId;
  final bool isFromProfile;
  final bool isFromProfileVisit;
  final bool isFromActivity;
  final Function? onSelected;
  final Icon? icon;
  final Widget? child;
  final double? elevation;
  const CustomPopUpMenuButtonWidget({
    Key? key,
    this.userVisitId,
    required this.isFromProfile,
    required this.isFromProfileVisit,
    required this.isFromActivity,
    this.onSelected,
    this.icon,
    this.child,
    this.elevation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var postBloc = BlocProvider.of<PostsBloc>(context);
    return PopupMenuButton(
      onSelected: (value) =>
          onSelected ??
          (value) {
            if (value as String == "edit") {
              customModalBottomSheetWidget(
                ctx: context,
                post: postBloc.singlePostData,
              );
            } else {
              BlocProvider.of<PostsBloc>(context).add(
                DeletePostEvent(
                  isFromVisit: isFromProfileVisit,
                  isFromActivity: isFromActivity,
                  isFromProfile: isFromProfile,
                  isFromVisitUserId: userVisitId,
                  context: context,
                  id: postBloc.singlePostData?.id ?? "",
                  token: StorageServices.authStorageValues["token"] ?? "",
                ),
              );
            }
          },
      icon: icon ??
          const Icon(
            Icons.more_vert_rounded,
            color: Colors.white,
          ),
      elevation: elevation ?? 0.0,
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: "edit",
          child: Text("Edit"),
        ),
        const PopupMenuItem(
          value: "delete",
          child: Text("Delete"),
        ),
      ],
      child: child,
    );
  }
}
