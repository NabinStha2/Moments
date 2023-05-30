import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moment/app/colors.dart';
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
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: MColors.primaryGrayColor90,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: Colors.white),
      ),
      textSelectionTheme:
          const TextSelectionThemeData(cursorColor: Colors.white),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: GoogleFonts.inter(
          fontSize: 16,
          color: MColors.primaryGrayColor50,
        ),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          icon: const Icon(
            Icons.clear,
            color: MColors.primaryGrayColor50,
          ),
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
          color: MColors.primaryGrayColor50,
        ),
        onPressed: () {
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    final List<dynamic>? dataSearchList = query.isNotEmpty
        ? postList != null
            ? postList
                ?.where((element) =>
                    element.name
                        ?.toLowerCase()
                        .startsWith(query.toLowerCase()) ??
                    false)
                .toList()
            : allUsersList?.where((element) {
                return element.name
                            ?.toLowerCase()
                            .startsWith(query.toLowerCase()) ==
                        true ||
                    element.email
                            ?.toLowerCase()
                            .contains(query.toLowerCase()) ==
                        true;
              }).toList()
        : null;

    consolelog(dataSearchList);

    return dataSearchList != null
        ? dataSearchList.isNotEmpty == true
            ? Container(
                color: MColors.primaryColor,
                child: ListView.separated(
                  clipBehavior: Clip.antiAlias,
                  separatorBuilder: (context, index) {
                    return const Divider(
                      color: MColors.primaryGrayColor50,
                      thickness: 0.5,
                      indent: 15.0,
                      endIndent: 15.0,
                    );
                  },
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  itemBuilder: (context, index) => ListTile(
                    leading: const Icon(
                      Icons.person,
                      color: MColors.primaryGrayColor50,
                    ),
                    title: CustomText(dataSearchList[index].name ?? ""),
                    subtitle: CustomText(
                      postList != null
                          ? dataSearchList[index].description ?? ""
                          : dataSearchList[index].email ?? "",
                      color: MColors.primaryGrayColor50,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    onTap: () {
                      close(context, dataSearchList[index]);
                    },
                  ),
                  itemCount: dataSearchList.length,
                ),
              )
            : Container(
                color: MColors.primaryColor,
                child: Center(
                  child: CustomText(
                    "No results found.",
                    fontSize: 18.0,
                  ),
                ),
              )
        : Container(
            color: MColors.primaryColor,
            child: Center(
              child: CustomText(
                  "Search for ${postList != null ? "posts" : "users"}.",
                  fontSize: 18.0),
            ),
          );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<dynamic>? dataSearchList = query.isNotEmpty
        ? postList != null
            ? postList
                ?.where((element) =>
                    element.name
                        ?.toLowerCase()
                        .startsWith(query.toLowerCase()) ??
                    false)
                .toList()
            : allUsersList?.where((element) {
                return element.name
                            ?.toLowerCase()
                            .startsWith(query.toLowerCase()) ==
                        true ||
                    element.email
                            ?.toLowerCase()
                            .contains(query.toLowerCase()) ==
                        true;
              }).toList()
        : null;

    return dataSearchList != null
        ? dataSearchList.isNotEmpty == true
            ? Container(
                color: MColors.primaryColor,
                child: ListView.separated(
                  clipBehavior: Clip.antiAlias,
                  separatorBuilder: (context, index) {
                    return const Divider(
                      color: MColors.primaryGrayColor50,
                      thickness: 0.5,
                      indent: 15.0,
                      endIndent: 15.0,
                    );
                  },
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  itemBuilder: (context, index) => ListTile(
                    dense: true,
                    splashColor: MColors.primaryGrayColor50,
                    leading: const Icon(
                      Icons.person,
                      color: MColors.primaryGrayColor50,
                    ),
                    title: CustomText(postList != null
                        ? dataSearchList[index].name ?? ""
                        : dataSearchList[index].name ?? ""),
                    subtitle: CustomText(
                      postList != null
                          ? dataSearchList[index].description ?? ""
                          : dataSearchList[index].email ?? "",
                      color: MColors.primaryGrayColor50,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    onTap: () {
                      close(context, dataSearchList[index]);
                    },
                  ),
                  itemCount: dataSearchList.length,
                ),
              )
            : Container(
                color: MColors.primaryColor,
                child: Center(
                  child: CustomText(
                    "No results found.",
                    fontSize: 18.0,
                  ),
                ),
              )
        : Container(
            color: MColors.primaryColor,
            child: Center(
              child: CustomText(
                  "Search for ${postList != null ? "posts" : "users"}.",
                  fontSize: 18.0),
            ),
          );
  }
}
