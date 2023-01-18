import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  UserModel({
    this.message,
    this.data,
  });

  String? message;
  List<UserData>? data;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        message: json["message"],
        data: List<UserData>.from(json["data"].map((x) => UserData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class UserData {
  UserData({
    this.id,
    this.oneSignalUserId,
    this.image,
    this.email,
    this.name,
    this.v,
    this.about,
    this.friends,
    this.msgFile,
    this.posts,
  });

  String? id;
  List<String>? oneSignalUserId;
  ImageData? image;
  String? email;
  String? name;
  int? v;
  String? about;
  List<String>? friends;
  List<dynamic>? msgFile;
  List<String>? posts;

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
        id: json["_id"],
        oneSignalUserId: List<String>.from(json["oneSignalUserId"].map((x) => x)),
        image: ImageData.fromJson(json["image"]),
        email: json["email"],
        name: json["name"],
        v: json["__v"],
        about: json["about"],
        friends: List<String>.from(json["friends"].map((x) => x)),
        msgFile: List<dynamic>.from(json["msgFile"].map((x) => x)),
        posts: List<String>.from(json["posts"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "oneSignalUserId": List<dynamic>.from(oneSignalUserId!.map((x) => x)),
        "image": image?.toJson(),
        "email": email,
        "name": name,
        "__v": v,
        "about": about,
        "friends": List<dynamic>.from(friends!.map((x) => x)),
        "msgFile": List<dynamic>.from(msgFile!.map((x) => x)),
        "posts": List<dynamic>.from(posts!.map((x) => x)),
      };
}

class ImageData {
  ImageData({
    this.imageName,
    this.imageUrl,
  });

  String? imageName;
  String? imageUrl;

  factory ImageData.fromJson(Map<String, dynamic> json) => ImageData(
        imageName: json["imageName"] ?? "",
        imageUrl: json["imageUrl"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "imageName": imageName,
        "imageUrl": imageUrl,
      };
}
