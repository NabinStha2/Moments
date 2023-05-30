import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moment/app/colors.dart';

import '../../../app/dimension/dimension.dart';
import '../../../bloc/auth_bloc/auth_bloc.dart';
import '../../../bloc/profile_posts_bloc/profile_posts_bloc.dart';
import '../../../utils/storage_services.dart';
import '../../../widgets/custom_circular_progress_indicator_widget.dart';
import '../../../widgets/custom_image_show_dialog_widget.dart';
import '../../../widgets/custom_text_widget.dart';

class ProfileHeaderBody extends StatelessWidget {
  final int userPostsLength;
  const ProfileHeaderBody({super.key, required this.userPostsLength});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            customFileShowDialogWidget(isImageOnly: true, ctx: context);
          },
          child: Stack(
            children: [
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is UploadImageLoading) {
                    return const CircleAvatar(
                      radius: 35.0,
                      foregroundColor: Colors.transparent,
                      child: Center(
                        child: CustomCircularProgressIndicatorWidget(),
                      ),
                    );
                  } else if (state is AuthLoaded) {
                    var ownerUser = state.ownerUser;
                    return Center(
                      child: ownerUser?.data?.image?.imageUrl != "" &&
                              ownerUser?.data?.image?.imageUrl != null
                          ? CircleAvatar(
                              radius: 35.0,
                              backgroundImage: NetworkImage(
                                ownerUser?.data?.image?.imageUrl ?? "",
                              ),
                              onBackgroundImageError: (object, stackTrace) {
                                Center(
                                  child: CustomText(
                                    "Error",
                                    color: Colors.red,
                                  ),
                                );
                              },
                            )
                          : CircleAvatar(
                              radius: 35.0,
                              child: Image.network(
                                "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fcdn3.iconfinder.com%2Fdata%2Ficons%2Fbusiness-round-flat-vol-1-1%2F36%2Fuser_account_profile_avatar_person_student_male-512.png&f=1&nofb=1",
                              ),
                            ),
                    );
                  }
                  return const CircleAvatar(
                    radius: 35.0,
                    foregroundColor: Colors.transparent,
                    child: Center(
                      child: CustomCircularProgressIndicatorWidget(),
                    ),
                  );
                },
              ),
              Positioned(
                top: 30,
                left: 35,
                child: IconButton(
                  splashRadius: 20.0,
                  onPressed: () {
                    customFileShowDialogWidget(ctx: context, isImageOnly: true);
                  },
                  icon: const FaIcon(
                    FontAwesomeIcons.camera,
                    color: MColors.primaryColor,
                    size: 20.0,
                    // color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        hSizedBox0,
        hSizedBox1,
        hSizedBox2,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CustomText(
                StorageServices.authStorageValues["name"] != null
                    ? StorageServices.authStorageValues["name"]
                            ?.toUpperCase() ??
                        ""
                    : "",
                fontWeight: FontWeight.w500,
                fontSize: 20.0,
              ),
              vSizedBox1,
              CustomText(
                StorageServices.authStorageValues["email"] ?? "",
                fontWeight: FontWeight.w400,
                fontSize: 18.0,
              ),
              vSizedBox1,
              Row(
                children: [
                  BlocBuilder<ProfilePostsBloc, ProfilePostsState>(
                    builder: (context, state) {
                      if (state is ProfilePostsSuccess) {
                        return CustomText(
                          state.postModel != null
                              ? state.postModel?.length.toString() ?? "0"
                              : userPostsLength.toString(),
                          fontWeight: FontWeight.w400,
                          fontSize: 15.0,
                        );
                      }
                      return CustomText(
                        userPostsLength.toString(),
                        fontWeight: FontWeight.w400,
                        fontSize: 15.0,
                      );
                    },
                  ),
                  CustomText(
                    "  posts",
                    fontWeight: FontWeight.w400,
                    fontSize: 15.0,
                  ),
                  hSizedBox1,
                  hSizedBox1,
                  CustomText(
                    StorageServices.authStorageValues["friends"] != null
                        ? StorageServices.authStorageValues["friends"]
                                ?.split(",")
                                .length
                                .toString() ??
                            "0"
                        : "0",
                    fontWeight: FontWeight.w400,
                    fontSize: 15.0,
                  ),
                  CustomText(
                    "  friends",
                    fontWeight: FontWeight.w400,
                    fontSize: 15.0,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
