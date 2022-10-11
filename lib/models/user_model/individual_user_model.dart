import 'dart:convert';

IndividualUserModel individualUserModelFromJson(String str) =>
    IndividualUserModel.fromJson(json.decode(str));

String individualUserModelToJson(IndividualUserModel data) =>
    json.encode(data.toJson());

class IndividualUserModel {
  IndividualUserModel({
    this.message,
    this.data,
  });

  String? message;
  IndividualUserData? data;

  factory IndividualUserModel.fromJson(Map<String, dynamic> json) =>
      IndividualUserModel(
        message: json["message"],
        data: IndividualUserData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data?.toJson(),
      };
}

class IndividualUserData {
  IndividualUserData({
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
    this.token,
  });

  String? id;
  String? token;
  List<String>? oneSignalUserId;
  IndividualImageData? image;
  String? email;
  String? name;
  int? v;
  String? about;
  List<String>? friends;
  List<dynamic>? msgFile;
  List<String>? posts;

  factory IndividualUserData.fromJson(Map<String, dynamic> json) =>
      IndividualUserData(
        id: json["_id"],
        token: json["token"],
        oneSignalUserId:
            List<String>.from(json["oneSignalUserId"].map((x) => x)),
        image: IndividualImageData.fromJson(json["image"]),
        email: json["email"],
        name: json["name"],
        v: json["__v"],
        about: json["about"],
        friends: List<String>.from(json["friends"].map((x) => x) ?? []),
        msgFile: List<dynamic>.from(json["msgFile"].map((x) => x)),
        posts: List<String>.from(json["posts"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "token": token,
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

class IndividualImageData {
  IndividualImageData({
    this.imageName,
    this.imageUrl,
  });

  String? imageName;
  String? imageUrl;

  factory IndividualImageData.fromJson(Map<String, dynamic> json) =>
      IndividualImageData(
        imageName: json["imageName"] ?? "",
        imageUrl: json["imageUrl"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "imageName": imageName,
        "imageUrl": imageUrl,
      };
}
