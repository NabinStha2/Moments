import 'dart:convert';

class UserModel {
  final String? name;
  final String? imageName;
  final String? imageUrl;
  final String? id;
  final String? email;
  final String? password;
  final String? errMessage;
  final String? userToken;
  final String? about;
  final List? friends;
  final List? oneSignalUserId;
  final List? userPosts;
  UserModel({
    this.name,
    this.imageName,
    this.imageUrl,
    this.id,
    this.email,
    this.password,
    this.errMessage,
    this.userToken,
    this.about,
    this.friends,
    this.oneSignalUserId,
    this.userPosts,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    print(map);
    return UserModel(
      id: map['userProfile']?['_id'] ?? "",
      imageName: map['userProfile']?['image']?['imageName'] ?? "",
      imageUrl: map['userProfile']?['image']?['imageUrl'] ?? "",
      name: map['userProfile']?['name'] ?? "",
      email: map['userProfile']?['email'] ?? "",
      password: map['userProfile']?['password'] ?? "",
      errMessage: map['message'] ?? "",
      userToken: map['userToken'] ?? "",
      about: map['userProfile']?['about'] ?? "",
      friends: map['userProfile']?['friends'] ?? [],
      oneSignalUserId: map['userProfile']?['oneSignalUserId'] ?? [],
      userPosts: map['userProfile']?['posts'] ?? [],
    );
  }

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));
}
