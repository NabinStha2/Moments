import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:moment/pages/profile_page.dart';
import 'package:moment/screens/post_details.dart';

FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

class FirebaseDynamicLinkService {
  static Future<String> createDynamicLink(
      {String? userId, String? postId}) async {
    String _linkMessage;

    if (userId != null) {
      log("User ID: $userId");
    }
    if (postId != null) {
      log("Post ID: $postId");
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

    final dynamicLink =
        await FirebaseDynamicLinks.instance.buildLink(dynamicLinkParams);

    log(dynamicLink.toString());
    _linkMessage = dynamicLink.toString();
    return _linkMessage;
  }

  static Future<void> initDynamicLink(BuildContext context) async {
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) async {
      final Uri deepLink = dynamicLinkData.link;

      var isUserId = deepLink.pathSegments.contains('userId');
      var isPostId = deepLink.pathSegments.contains('postId');
      if (isUserId) {
        log("$isUserId");
        String userId = deepLink.queryParameters['userId']!;

        log(userId);

        if (deepLink != null) {
          try {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ProfilePage(
                  isFromSearch: false,
                  userId: userId,
                ),
              ),
            );
          } catch (e) {
            log("Error link: $e");
          }
        }
      } else {
        log("$isPostId");
        String postId = deepLink.queryParameters['postId']!;

        log(postId);

        if (deepLink != null) {
          try {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => Postdetails(
                  postId: postId,
                ),
              ),
            );
          } catch (e) {
            log("Error link: $e");
          }
        }
      }
    }, onError: (error) async {
      log('link error');
    });

    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    try {
      final Uri deepLink = data!.link;
      var isUserId = deepLink.pathSegments.contains('userId');
      var isPostId = deepLink.pathSegments.contains('postId');
      if (isUserId) {
        log("$isUserId");
        String userId = deepLink.queryParameters['userId']!;

        log(userId);

        if (deepLink != null) {
          try {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ProfilePage(
                  isFromSearch: false,
                  userId: userId,
                ),
              ),
            );
          } catch (e) {
            log("Error link: $e");
          }
        }
      } else {
        log("$isPostId");
        String postId = deepLink.queryParameters['postId']!;

        log(postId);

        if (deepLink != null) {
          try {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => Postdetails(
                  postId: postId,
                ),
              ),
            );
          } catch (e) {
            log("Error link: $e");
          }
        }
      }
    } catch (e) {
      log('No deepLink found');
    }
  }
}
