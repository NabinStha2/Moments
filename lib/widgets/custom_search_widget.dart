import 'package:flutter/material.dart';
import 'package:moment/development/console.dart';

import 'package:moment/models/post_model/post_model.dart';
import 'package:moment/models/user_model/users_model.dart';
import 'package:moment/widgets/custom_text_widget.dart';

class DataSearch extends SearchDelegate {
  final List<PostModelData>? postList;
  final List<UserData>? allUsersList;
  DataSearch({
    this.postList,
    this.allUsersList,
  });

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = "";
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow,
          progress: transitionAnimation,
        ),
        onPressed: () {
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    final List<dynamic>? dataSearchList = query.isNotEmpty
        ? postList != null
            ? postList?.where((element) => element.name?.toLowerCase().startsWith(query.toLowerCase()) ?? false).toList()
            : allUsersList?.where((element) {
                return element.name?.toLowerCase().startsWith(query.toLowerCase()) == true ||
                    element.email?.toLowerCase().contains(query.toLowerCase()) == true;
              }).toList()
        : null;

    consolelog(dataSearchList);

    return dataSearchList != null
        ? dataSearchList.isNotEmpty == true
            ? ListView.separated(
                clipBehavior: Clip.antiAlias,
                separatorBuilder: (context, index) {
                  return const Divider(
                    color: Colors.grey,
                    thickness: 0.5,
                    indent: 15.0,
                    endIndent: 15.0,
                  );
                },
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                itemBuilder: (context, index) => ListTile(
                  leading: const Icon(Icons.feed),
                  title: PoppinsText(dataSearchList[index].name ?? ""),
                  subtitle: PoppinsText(postList != null ? dataSearchList[index].description ?? "" : dataSearchList[index].email ?? ""),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  onTap: () {
                    close(context, dataSearchList[index]);
                  },
                ),
                itemCount: dataSearchList.length,
              )
            : Center(
                child: PoppinsText(
                  "No results found.",
                  fontSize: 18.0,
                ),
              )
        : Center(
            child: PoppinsText("Search for ${postList != null ? "posts" : "users"}.", fontSize: 18.0),
          );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<dynamic>? dataSearchList = query.isNotEmpty
        ? postList != null
            ? postList?.where((element) => element.name?.toLowerCase().startsWith(query.toLowerCase()) ?? false).toList()
            : allUsersList?.where((element) {
                return element.name?.toLowerCase().startsWith(query.toLowerCase()) == true ||
                    element.email?.toLowerCase().contains(query.toLowerCase()) == true;
              }).toList()
        : null;

    return dataSearchList != null
        ? dataSearchList.isNotEmpty == true
            ? ListView.separated(
                clipBehavior: Clip.antiAlias,
                separatorBuilder: (context, index) {
                  return const Divider(
                    color: Colors.grey,
                    thickness: 0.5,
                    indent: 15.0,
                    endIndent: 15.0,
                  );
                },
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                itemBuilder: (context, index) => ListTile(
                  leading: const Icon(Icons.feed),
                  title: PoppinsText(postList != null ? dataSearchList[index].name ?? "" : dataSearchList[index].name ?? ""),
                  subtitle: PoppinsText(postList != null ? dataSearchList[index].description ?? "" : dataSearchList[index].email ?? ""),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  onTap: () {
                    close(context, dataSearchList[index]);
                  },
                ),
                itemCount: dataSearchList.length,
              )
            : Center(
                child: PoppinsText(
                  "No results found.",
                  fontSize: 18.0,
                ),
              )
        : Center(
            child: PoppinsText("Search for ${postList != null ? "posts" : "users"}.", fontSize: 18.0),
          );
  }
}
