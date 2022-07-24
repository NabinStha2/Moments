import 'dart:convert';
import 'dart:developer';

class ActivityModel {
  final String userImageUrl;
  final String postUrl;
  final String activityName;
  final String timestamps;
  final String postId;
  final String userId;
  final String activityId;
  ActivityModel({
    required this.userImageUrl,
    required this.postUrl,
    required this.activityName,
    required this.timestamps,
    required this.postId,
    required this.userId,
    required this.activityId,
  });

  Map<String, dynamic> toMap() {
    return {
      'userImageUrl': userImageUrl,
      'postUrl': postUrl,
      'activityName': activityName,
    };
  }

  factory ActivityModel.fromMap(Map<String, dynamic> map) {
    // log("$map");
    return ActivityModel(
      timestamps: map["timestamps"] ?? DateTime.now(),
      userImageUrl: map['userImageUrl'] ?? '',
      postUrl: map['postUrl'] ?? '',
      postId: map['postId'] ?? '',
      userId: map['userId'] ?? '',
      activityName: map['activityName'] ?? '',
      activityId: map['activityId'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory ActivityModel.fromJson(String source) =>
      ActivityModel.fromMap(json.decode(source));
}
