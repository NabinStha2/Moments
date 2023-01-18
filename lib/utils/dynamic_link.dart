import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:moment/development/console.dart';
import 'package:moment/screens/posts/post_details/post_details_screen.dart';
import 'package:moment/screens/profile/components/profile_visit_page.dart';
import 'package:moment/screens/posts/post_details/components/post_details_body.dart';

FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

class FirebaseDynamicLinkService {
  static startDynamicService({required BuildContext ctx}) async {
    await FirebaseDynamicLinkService.initDynamicLink(ctx);
  }

  static Future<String> createDynamicLink({String? userId, String? postId}) async {
    String linkMessage;

    if (userId != null) {
      consolelog("User ID: $userId");
    }
    if (postId != null) {
      consolelog("Post ID: $postId");
    }

    final DynamicLinkParameters dynamicLinkParams = DynamicLinkParameters(
      uriPrefix: 'https://momentsapps.page.link',
      link: userId != null
          ? Uri.parse('https://www.momentsapp.com/profileVisit?userId=$userId')
          : Uri.parse('https://www.momentsapp.com/profileVisit?postId=$postId'),
      androidParameters: const AndroidParameters(
        packageName: 'com.example.moments',
        minimumVersion: 30,
      ),
    );

    final dynamicLink = await FirebaseDynamicLinks.instance.buildLink(dynamicLinkParams);

    consolelog(dynamicLink.toString());
    linkMessage = dynamicLink.toString();
    return linkMessage;
  }

  static Future<void> initDynamicLink(BuildContext context) async {
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) async {
      final Uri deepLink = dynamicLinkData.link;
      var isUserId = deepLink.pathSegments.contains('userId');
      var isPostId = deepLink.pathSegments.contains('postId');
      if (isUserId) {
        String userId = deepLink.queryParameters['userId'] ?? "";
        if (deepLink != null) {
          try {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ProfileVisitPage(
                  isFromSearch: false,
                  userId: userId,
                ),
              ),
            );
          } catch (e) {
            consolelog("Error link: $e");
          }
        }
      } else {
        consolelog("$isPostId");
        String postId = deepLink.queryParameters['postId'] ?? "";
        if (deepLink != null) {
          try {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PostDetailsScreen(
                  postId: postId,
                ),
              ),
            );
          } catch (e) {
            consolelog("Error link: $e");
          }
        }
      }
    }, onError: (error) async {
      consolelog('link error');
    });

    final PendingDynamicLinkData? data = await FirebaseDynamicLinks.instance.getInitialLink();
    try {
      final Uri? deepLink = data?.link;
      var isUserId = deepLink?.pathSegments.contains('userId');
      var isPostId = deepLink?.pathSegments.contains('postId');
      if (isUserId != null) {
        String userId = deepLink?.queryParameters['userId'] ?? "";
        if (deepLink != null) {
          try {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ProfileVisitPage(
                  isFromSearch: false,
                  userId: userId,
                ),
              ),
            );
          } catch (e) {
            consolelog("Error link: $e");
          }
        }
      } else {
        String postId = deepLink?.queryParameters['postId'] ?? "";
        if (deepLink != null) {
          try {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PostDetailsScreen(
                  postId: postId,
                ),
              ),
            );
          } catch (e) {
            consolelog("Error link: $e");
          }
        }
      }
    } catch (e) {
      consolelog('No deepLink found');
    }
  }
}
