import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moment/config/routes/route_navigation.dart';
import 'package:moment/models/activity_model/activity_model.dart';
import 'package:moment/screens/activity/components/widgets/custom_list_tile_widget.dart';
import 'package:moment/screens/home/components/widgets/navigation_post_details_widget.dart';
import 'package:moment/screens/profile/components/profile_visit_page.dart';
import 'package:moment/widgets/custom_text_widget.dart';

import '../../../bloc/activity_bloc/activity_bloc.dart';
import '../../../bloc/auth_bloc/auth_bloc.dart';
import '../../../utils/storage_services.dart';
import '../../../widgets/custom_all_shimmer_widget.dart';

class ActivityBody extends StatefulWidget {
  const ActivityBody({Key? key}) : super(key: key);

  @override
  State<ActivityBody> createState() => _ActivityBodyState();
}

class _ActivityBodyState extends State<ActivityBody> {
  @override
  initState() {
    super.initState();
    BlocProvider.of<ActivityBloc>(context).add(
      GetActivity(id: StorageServices.authStorageValues["id"] ?? ""),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActivityBloc, ActivityState>(
      builder: (context, state) {
        if (state is ActivityLoading) {
          return CustomAllShimmerWidget.activityShimmerWidget();
        }
        if (state is ActivityLoaded) {
          var reversedList = List<Activity>.from(
              state.activityList.data?.activity?.reversed.toList() ?? []);
          var activity = reversedList;
          return activity.isNotEmpty == true
              ? RefreshIndicator(
                  onRefresh: () async {
                    BlocProvider.of<ActivityBloc>(context).add(
                      GetActivity(
                          id: StorageServices.authStorageValues["id"] ?? ""),
                    );
                  },
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: state.activityList.data?.activity?.length ?? 0,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      return CustomListTileWidget(
                        onTap: () {
                          if (activity[index].postId != null) {
                            navigateToPostDetails(
                              context: context,
                              isFromActivity: true,
                              postId: activity[index].postId ?? "",
                            );
                          } else {
                            BlocProvider.of<AuthBloc>(context)
                                .clearUserDetails();
                            RouteNavigation.navigate(
                              context,
                              ProfileVisitPage(
                                isFromSearch: false,
                                isFromActivity: true,
                                userId: activity[index].userId ?? "",
                              ),
                            );
                          }
                        },
                        leadingImageUrl: activity[index].userImageUrl != null &&
                                activity[index].userImageUrl != ""
                            ? activity[index].userImageUrl
                            : null,
                        trailingImageUrl: activity[index].postUrl != null &&
                                activity[index].postUrl != ""
                            ? activity[index].postUrl
                            : null,
                        subTitleDateTime: activity[index].timestamps,
                        titleText: activity[index].activityName,
                      );
                    },
                  ),
                )
              : Center(
                  child: PoppinsText("No activity yet."),
                );
        }
        return Container();
      },
    );
  }
}
