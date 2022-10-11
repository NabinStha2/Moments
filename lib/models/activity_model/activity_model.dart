import 'dart:convert';

ActivityModel activityModelFromJson(String str) => ActivityModel.fromJson(json.decode(str));

String activityModelToJson(ActivityModel data) => json.encode(data.toJson());

class ActivityModel {
  ActivityModel({
    this.message,
    this.data,
  });

  String? message;
  ActivityData? data;

  factory ActivityModel.fromJson(Map<String, dynamic> json) => ActivityModel(
        message: json["message"],
        data: ActivityData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data?.toJson(),
      };
}

class ActivityData {
  ActivityData({
    this.id,
    this.activityUserId,
    this.activity,
    this.v,
  });

  String? id;
  ActivityUserId? activityUserId;
  List<Activity>? activity;
  int? v;

  factory ActivityData.fromJson(Map<String, dynamic> json) => ActivityData(
        id: json["_id"],
        activityUserId: ActivityUserId.fromJson(json["activityUserId"]),
        activity: List<Activity>.from(json["activity"].map((x) => Activity.fromJson(x))),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "activityUserId": activityUserId?.toJson(),
        "activity": List<dynamic>.from(activity?.map((x) => x.toJson()) ?? []),
        "__v": v,
      };
}

class Activity {
  Activity({
    this.timestamps,
    this.id,
    this.userId,
    this.postId,
    this.userImageUrl,
    this.activityName,
    this.postUrl,
    this.type,
    this.ownerId,
    this.activityId,
  });

  DateTime? timestamps;
  String? id;
  String? userId;
  String? postId;
  String? userImageUrl;
  String? activityName;
  String? postUrl;
  String? type;
  String? ownerId;
  String? activityId;

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
        timestamps: DateTime.parse(json["timestamps"]),
        id: json["_id"],
        userId: json["userId"],
        postId: json["postId"],
        userImageUrl: json["userImageUrl"],
        activityName: json["activityName"],
        postUrl: json["postUrl"],
        type: json["type"],
        ownerId: json["ownerId"],
        activityId: json["activityId"],
      );

  Map<String, dynamic> toJson() => {
        "timestamps": timestamps?.toIso8601String(),
        "_id": id,
        "userId": userId,
        "postId": postId,
        "userImageUrl": userImageUrl,
        "activityName": activityName,
        "postUrl": postUrl,
        "type": type,
        "ownerId": ownerId,
        "activityId": activityId,
      };
}

class ActivityUserId {
  ActivityUserId({
    this.id,
    this.oneSignalUserId,
    this.image,
    this.about,
    this.friends,
    this.msgFile,
    this.posts,
    this.email,
    this.password,
    this.name,
    this.v,
  });

  String? id;
  List<String>? oneSignalUserId;
  ImageDetails? image;
  String? about;
  List<String>? friends;
  List<dynamic>? msgFile;
  List<String>? posts;
  String? email;
  String? password;
  String? name;
  int? v;

  factory ActivityUserId.fromJson(Map<String, dynamic> json) => ActivityUserId(
        id: json["_id"],
        oneSignalUserId: List<String>.from(json["oneSignalUserId"].map((x) => x)),
        image: ImageDetails.fromJson(json["image"]),
        about: json["about"],
        friends: List<String>.from(json["friends"].map((x) => x)),
        msgFile: List<dynamic>.from(json["msgFile"].map((x) => x)),
        posts: List<String>.from(json["posts"].map((x) => x)),
        email: json["email"],
        password: json["password"],
        name: json["name"],
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "oneSignalUserId": List<dynamic>.from(oneSignalUserId?.map((x) => x) ?? []),
        "image": image?.toJson(),
        "about": about,
        "friends": List<dynamic>.from(friends?.map((x) => x) ?? []),
        "msgFile": List<dynamic>.from(msgFile?.map((x) => x) ?? []),
        "posts": List<dynamic>.from(posts?.map((x) => x) ?? []),
        "email": email,
        "password": password,
        "name": name,
        "__v": v,
      };
}

class ImageDetails {
  ImageDetails({
    this.imageName,
    this.imageUrl,
  });

  String? imageName;
  String? imageUrl;

  factory ImageDetails.fromJson(Map<String, dynamic> json) => ImageDetails(
        imageName: json["imageName"],
        imageUrl: json["imageUrl"],
      );

  Map<String, dynamic> toJson() => {
        "imageName": imageName,
        "imageUrl": imageUrl,
      };
}


// import 'dart:convert';
// import 'dart:developer';

// class ActivityModel {
//   final String userImageUrl;
//   final String postUrl;
//   final String activityName;
//   final String timestamps;
//   final String postId;
//   final String userId;
//   final String activityId;
//   ActivityModel({
//     required this.userImageUrl,
//     required this.postUrl,
//     required this.activityName,
//     required this.timestamps,
//     required this.postId,
//     required this.userId,
//     required this.activityId,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'userImageUrl': userImageUrl,
//       'postUrl': postUrl,
//       'activityName': activityName,
//     };
//   }

//   factory ActivityModel.fromMap(Map<String, dynamic> map) {
//     // log("$map");
//     return ActivityModel(
//       timestamps: map["timestamps"] ?? DateTime.now(),
//       userImageUrl: map['userImageUrl'] ?? '',
//       postUrl: map['postUrl'] ?? '',
//       postId: map['postId'] ?? '',
//       userId: map['userId'] ?? '',
//       activityName: map['activityName'] ?? '',
//       activityId: map['activityId'] ?? '',
//     );
//   }

//   String toJson() => json.encode(toMap());

//   factory ActivityModel.fromJson(String source) =>
//       ActivityModel.fromMap(json.decode(source));
// }
