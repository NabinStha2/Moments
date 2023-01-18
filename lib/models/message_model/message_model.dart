import 'dart:convert';

MessageModel messageModelFromJson(String str) => MessageModel.fromJson(json.decode(str));

String messageModelToJson(MessageModel data) => json.encode(data.toJson());

class MessageModel {
  MessageModel({
    this.message,
    this.data,
  });

  String? message;
  MessageData? data;

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        message: json["message"],
        data: MessageData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data?.toJson(),
      };
}

class MessageData {
  MessageData({
    this.messageContent,
    this.messageType,
    this.timeStamp,
    this.filePath,
    this.fileType,
    this.thumbnail,
  });

  String? messageContent;
  String? messageType;
  String? timeStamp;
  String? filePath;
  String? fileType;
  String? thumbnail;

  factory MessageData.fromJson(Map<String, dynamic> json) => MessageData(
        messageContent: json["messageContent"],
        messageType: json["messageType"],
        timeStamp: DateTime.now().toString().substring(10, 16),
        filePath: json["filePath"],
        fileType: json["fileType"],
        thumbnail: json["thumbnail"],
      );

  Map<String, dynamic> toJson() => {
        "messageContent": messageContent,
        "messageType": messageType,
        "timeStamp": timeStamp,
        "filePath": filePath,
        "fileType": fileType,
        "thumbnail": thumbnail,
      };
}
