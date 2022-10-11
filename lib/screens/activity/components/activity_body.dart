import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:moment/bloc/authBloc/auth_bloc.dart';
import 'package:moment/bloc/postsBloc/posts_bloc.dart';
import 'package:moment/models/activity_model/activity_model.dart';
import 'package:moment/screens/post_add/components/post_details.dart';
import 'package:moment/screens/profile/components/profile_page.dart';
import 'package:moment/utils/storage_services.dart';

import '../../../bloc/activityBloc/activity_bloc.dart';

class ActivityBody extends StatefulWidget {
  const ActivityBody({Key? key}) : super(key: key);

  @override
  State<ActivityBody> createState() => _ActivityBodyState();
}

class _ActivityBodyState extends State<ActivityBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      BlocProvider.of<ActivityBloc>(context).add(GetActivity(id: StorageServices.authStorageValues["id"] ?? ""));
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActivityBloc, ActivityState>(
      builder: (context, state) {
        if (state is ActivityLoading) {
          return const Center(
            child: SpinKitCircle(
              color: Colors.blue,
              size: 40.0,
            ),
          );
        }
        if (state is ActivityLoaded) {
          var reversedList = List<Activity>.from(state.activityList.data?.activity?.reversed.toList() ?? []);
          var activity = reversedList;
          return activity.isNotEmpty == true
              ? ListView.separated(
                  itemBuilder: (context, index) {
                    // consolelog("POSTID: ${activity[index].postId}");
                    // consolelog("USERID: ${activity[index].userId}");
                    return ListTile(
                      enabled: true,
                      minVerticalPadding: 18,
                      onTap: () {
                        if (activity[index].postId != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BlocProvider.value(
                                value: BlocProvider.of<PostsBloc>(context),
                                child: Postdetails(
                                  isFromActivity: true,
                                  isFromProfileVisit: false,
                                  isFromProfile: false,
                                  postId: activity[index].postId ?? "",
                                  isFromHome: false,
                                  isFromComment: false,
                                ),
                              ),
                            ),
                          );
                        } else {
                          BlocProvider.of<AuthBloc>(context).clearUserDetails();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProfileVisitPage(
                                isFromSearch: false,
                                isFromActivity: true,
                                userId: activity[index].userId ?? "",
                              ),
                            ),
                          );
                        }
                      },
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.network(
                          activity[index].userImageUrl != null && activity[index].userImageUrl != ""
                              ? activity[index].userImageUrl ?? ""
                              : "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fcdn3.iconfinder.com%2Fdata%2Ficons%2Fbusiness-round-flat-vol-1-1%2F36%2Fuser_account_profile_avatar_person_student_male-512.png&f=1&nofb=1",
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          height: 50,
                          width: 50,
                          filterQuality: FilterQuality.high,
                          isAntiAlias: true,
                        ),
                      ),
                      title: Text(activity[index].activityName ?? ""),
                      subtitle: Text(
                        timeago.format(
                          activity[index].timestamps ?? DateTime.now(),
                          locale: 'en',
                        ),
                      ),
                      trailing: activity[index].postUrl != ""
                          ? SizedBox(
                              height: 50,
                              width: 50,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  activity[index].postUrl != null && activity[index].postUrl != ""
                                      ? activity[index].postUrl ?? ""
                                      : "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fcdn3.iconfinder.com%2Fdata%2Ficons%2Fbusiness-round-flat-vol-1-1%2F36%2Fuser_account_profile_avatar_person_student_male-512.png&f=1&nofb=1",
                                  fit: BoxFit.cover,
                                  alignment: Alignment.center,
                                  height: 50,
                                  width: 50,
                                  filterQuality: FilterQuality.high,
                                  isAntiAlias: true,
                                ),
                              ),
                            )
                          : const SizedBox(),
                    );
                  },
                  itemCount: state.activityList.data?.activity?.length ?? 0,
                  separatorBuilder: (context, index) => const Divider(),
                )
              : const Center(
                  child: Text("No activity yet."),
                );
        }

        return Container();
      },
    );
  }
}
