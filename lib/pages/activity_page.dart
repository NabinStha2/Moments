import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:moment/bloc/activity_bloc.dart';
import 'package:moment/bloc/posts_bloc.dart';
import 'package:moment/pages/profile_page.dart';
import 'package:moment/screens/home_screen.dart';
import 'package:moment/screens/post_details.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({Key? key}) : super(key: key);

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<ActivityBloc>(context)
        .add(GetActivity(id: authStorageValues!["id"]!));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActivityBloc, ActivityState>(
      builder: (context, state) {
        if (state is ActivityLoading) {
          return const Scaffold(
            body: Center(
              child: SpinKitCircle(
                color: Colors.blue,
                size: 40.0,
              ),
            ),
          );
        }
        if (state is ActivityLoaded) {
          var reversedList = List.from(state.activityList.reversed);
          inspect(reversedList);
          var activity = reversedList;
          return activity.isNotEmpty
              ? Scaffold(
                  appBar: AppBar(
                    title: const Text("Activity"),
                  ),
                  body: ListView.separated(
                    itemBuilder: (context, index) => ListTile(
                      enabled: true,
                      minVerticalPadding: 18,
                      onTap: () {
                        if (activity[index].postId != "") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BlocProvider.value(
                                value: BlocProvider.of<PostsBloc>(context),
                                child: Postdetails(
                                  isFromActivity: true,
                                  isVisit: false,
                                  isFromProfile: false,
                                  postId: activity[index].postId,
                                  isAll: false,
                                  isFromComment: false,
                                ),
                              ),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProfilePage(
                                isFromSearch: false,
                                isFromActivity: true,
                                userId: activity[index].userId,
                              ),
                            ),
                          );
                        }
                      },
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.network(
                          activity[index].userImageUrl != ""
                              ? activity[index].userImageUrl
                              : "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fcdn3.iconfinder.com%2Fdata%2Ficons%2Fbusiness-round-flat-vol-1-1%2F36%2Fuser_account_profile_avatar_person_student_male-512.png&f=1&nofb=1",
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          height: 50,
                          width: 50,
                          filterQuality: FilterQuality.high,
                          isAntiAlias: true,
                        ),
                      ),
                      title: Text(activity[index].activityName),
                      subtitle: Text(
                        timeago.format(
                          DateTime.parse(activity[index].timestamps),
                          locale: 'en',
                        ),
                      ),
                      trailing: activity[index].postUrl != ""
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                activity[index].postUrl != ""
                                    ? activity[index].postUrl
                                    : "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fcdn3.iconfinder.com%2Fdata%2Ficons%2Fbusiness-round-flat-vol-1-1%2F36%2Fuser_account_profile_avatar_person_student_male-512.png&f=1&nofb=1",
                                fit: BoxFit.cover,
                                alignment: Alignment.center,
                                height: 50,
                                width: 50,
                                filterQuality: FilterQuality.high,
                                isAntiAlias: true,
                              ),
                            )
                          : const SizedBox(),
                    ),
                    itemCount: state.activityList.length,
                    separatorBuilder: (context, index) => const Divider(),
                  ),
                )
              : Scaffold(
                  appBar: AppBar(
                    title: const Text("Activity"),
                  ),
                  body: const Center(
                    child: Text("No activity yet."),
                  ),
                );
        }

        return Container();
      },
    );
  }
}
