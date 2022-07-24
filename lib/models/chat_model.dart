import 'dart:convert';

class ChatModel {
  String name;
  String email;
  final String? about;
  final String? imageName;
  final String? imageUrl;
  final List? oneSignalUserId;
  DateTime? timeStamp;
  String? id;
  String? userToken;
  List? friends;

  ChatModel({
    required this.name,
    required this.email,
    this.imageUrl,
    this.imageName,
    this.oneSignalUserId,
    this.timeStamp,
    required this.id,
    this.userToken,
    required this.about,
    this.friends,
  });

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      name: map['name'],
      email: map['email'],
      imageName: map['image']['imageName'] ?? "",
      imageUrl: map['image']['imageUrl'] ?? "",
      oneSignalUserId: map['oneSignalUserId'] ?? [],
      timeStamp: map['timeStamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['timeStamp'])
          : null,
      id: map['_id'] ?? "",
      userToken: map['userToken'] ?? "",
      about: map['about'] ?? '',
      friends: map['friends'] ?? [],
    );
  }

  factory ChatModel.fromJson(String source) =>
      ChatModel.fromMap(json.decode(source));

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'imageUrl': imageUrl,
      'imageName': imageName,
      'timeStamp': timeStamp?.millisecondsSinceEpoch,
      'id': id,
      "userToken": userToken
    };
  }

  String toJson() => json.encode(toMap());
}

class MessageModel {
  String messageContent;
  String messageType;
  String timeStamp;
  String filePath;
  String fileType;
  String thumbnail;

  MessageModel({
    required this.messageContent,
    required this.messageType,
    required this.timeStamp,
    required this.filePath,
    required this.fileType,
    required this.thumbnail,
  });
}
