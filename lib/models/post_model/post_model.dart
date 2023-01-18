import 'dart:convert';
import 'dart:developer';

PostModel postModelFromJson(String str) => PostModel.fromJson(json.decode(str));

String postModelToJson(PostModel data) => json.encode(data.toJson());

class PostModel {
  PostModel({
    this.data,
    this.pages,
    this.message,
  });

  List<PostModelData>? data;
  int? pages;
  String? message;

  factory PostModel.fromJson(Map<String, dynamic> json) => PostModel(
        data: List<PostModelData>.from(
            json["data"].map((x) => PostModelData.fromJson(x))),
        pages: json["pages"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data?.map((x) => x.toJson()) ?? []),
        "pages": pages,
        "message": message,
      };
}

class PostModelData {
  PostModelData({
    this.file,
    this.createdAt,
    this.id,
    this.name,
    this.description,
    this.fileType,
    this.creator,
    this.comments,
    this.likes,
    this.v,
  });

  FileClass? file;
  DateTime? createdAt;
  String? id;
  String? name;
  String? description;
  String? fileType;
  String? creator;
  List<Comments>? comments;
  List<Likes>? likes;
  int? v;

  factory PostModelData.fromJson(Map<String, dynamic> json) => PostModelData(
        file: FileClass.fromJson(json["file"]),
        createdAt: DateTime.parse(json["createdAt"]),
        id: json["_id"],
        name: json["name"],
        description: json["description"],
        fileType: json["fileType"],
        creator: json["creator"],
        comments: List<Comments>.from(
            json["comments"].map((x) => Comments.fromJson(x))),
        likes: List<Likes>.from(json["likes"].map((x) => Likes.fromJson(x))),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "file": file?.toJson(),
        "createdAt": createdAt?.toIso8601String(),
        "_id": id,
        "name": name,
        "description": description,
        "fileType": fileType,
        "creator": creator,
        "comments": List<dynamic>.from(comments?.map((x) => x) ?? []),
        "likes": List<dynamic>.from(likes?.map((x) => x) ?? []),
        "__v": v,
      };
}

class FileClass {
  FileClass({
    this.fileName,
    this.thumbnail,
    this.fileUrl,
  });

  String? fileName;
  String? fileUrl;
  String? thumbnail;

  factory FileClass.fromJson(Map<String, dynamic> json) => FileClass(
        fileName: json["fileName"],
        fileUrl: json["fileUrl"],
        thumbnail: json["thumbnail"],
      );

  Map<String, dynamic> toJson() => {
        "fileName": fileName,
        "fileUrl": fileUrl,
        "thumbnail": thumbnail,
      };
}

class Likes {
  String? userId;
  String? timestamps;
  String? reactionType;
  Likes({
    this.userId,
    this.timestamps,
    this.reactionType,
  });

  factory Likes.fromJson(Map<String, dynamic> json) {
    return Likes(
      userId: json['userId'],
      timestamps: json['timestamps'] ?? DateTime.now(),
      reactionType: json['reactionType'],
    );
  }
  Map<String, dynamic> toJson() => {
        "userId": userId,
        "timestamps": timestamps,
        "reactionType": reactionType,
      };
}

class Comments {
  String? commentName;
  String? commentUserId;
  String? timestamps;
  String? commentId;
  List<String>? activityId;
  List<ReplyComments>? replyComments;
  Comments({
    this.commentName,
    this.commentUserId,
    this.timestamps,
    this.commentId,
    this.activityId,
    this.replyComments,
  });

  factory Comments.fromJson(Map<String, dynamic> json) {
    // log("$map");
    return Comments(
      commentName: json['commentName'] ?? "",
      commentUserId: json['commentUserId'] ?? "",
      commentId: json['_id'] ?? "",
      timestamps: json['timestamps'] ?? DateTime.now(),
      activityId:
          List.from(json['activityId'].map((actId) => actId.toString())),
      replyComments: List<ReplyComments>.from(
          json['replyComments'].map((x) => ReplyComments.fromJson(x))),
    );
  }
}

class ReplyComments {
  String? commentName;
  String? commentUserId;
  String? timestamps;
  String? replyCommentId;
  ReplyComments({
    this.commentName,
    this.commentUserId,
    this.timestamps,
    this.replyCommentId,
  });

  Map<String, dynamic> toJson() {
    return {
      'commentName': commentName,
      'commentUserId': commentUserId,
      'timestamps': timestamps,
      'replyCommentId': replyCommentId,
    };
  }

  factory ReplyComments.fromJson(Map<String, dynamic> json) {
    return ReplyComments(
      commentName: json['commentName'],
      commentUserId: json['commentUserId'],
      timestamps: json['timestamps'],
      replyCommentId: json['_id'],
    );
  }
}

// PostModelData postResponseFromJson(String str) =>
//     PostModelData.fromJson(json.decode(str));

// String postResponseToJson(PostModelData data) => json.encode(data.toJson());

// class PostResponse {
//   final List<PostModelData> postModel;
//   final int pages;

//   PostResponse({
//     required this.postModel,
//     required this.pages,
//   });

//   factory PostResponse.fromJson(Map<String, dynamic> json) {
//     return PostResponse(
//       postModel: List<PostModelData>.from(
//           json["posts"].map((x) => PostModelData.fromJson(x))),
//       pages: json['pages'] ?? 1,
//     );
//   }
// }

// class SinglePostModel {
//   final PostModelData? postModel;

//   SinglePostModel({
//     required this.postModel,
//   });

//   factory SinglePostModel.fromJson(Map<String, dynamic> map) {
//     return SinglePostModel(
//       postModel: PostModelData.fromJson(map['post']),
//     );
//   }
// }



// class PostModel {
//   final String? id;
//   // String? title;
//   String? description;
//   // List<String>? tags;
//   final List<Likes>? likes;
//   String? createdAt;
//   String? creator;
//   List<Comments> comments;
//   String? name;
//   String fileName;
//   String thumbnail;
//   String fileType;
//   String fileUrl;
//   String? errMessage;

//   PostModel({
//     required this.id,
//     // required this.title,
//     required this.description,
//     required this.fileName,
//     required this.fileUrl,
//     required this.fileType,
//     required this.thumbnail,
//     // required this.tags,
//     required this.likes,
//     required this.createdAt,
//     required this.creator,
//     required this.comments,
//     required this.name,
//     required this.errMessage,
//   });

//   Map<String, dynamic> toMap() {
//     // print(post['file']['fileUrl']);
//     // debugPrintStack(label: "hey");
//     return {
//       "id": id,
//       // "title": title,
//       "description": description,
//       "likes": likes,
//       "comments": comments,
//       "createdAt": createdAt,
//       // "tags": tags,
//       "creator": creator,
//       "name": name,
//       "fileName": fileName,
//       "thumbnail": thumbnail,
//       "fileType": fileType,
//       "fileUrl": fileUrl,
//       "errMessage": errMessage,
//     };
//   }

//   factory PostModel.fromMap(Map<String, dynamic> post) {
//     // print(post['file']['fileUrl']);
//     // debugPrintStack(label: "hey");
//     return PostModel(
//       id: post['_id'] ?? "",
//       // title: post['title'] ?? "",
//       description: post['description'] ?? "",
//       likes: post['likes'] != null
//           ? List.from(post['likes']!)
//               .map((like) => Likes.fromMap(like))
//               .toList()
//           : [],
//       comments: post['comments'] != null
//           ? (post['comments'] as List)
//               .map((cmt) => Comments.fromMap(cmt))
//               .toList()
//           : [],
//       createdAt: post['createdAt'] ?? "",
//       // tags: List<String>.from(post['tags'])
//       //             .map((tag) => tag.toString())
//       //             .toList() !=
//       //         []
//       //     ? List<String>.from(post['tags'])
//       //         .map((tag) => tag.toString())
//       //         .toList()
//       //     : [],
//       creator: post['creator'] ?? "",
//       name: post['name'] ?? "",
//       fileName: post['file']['fileName'] ?? "",
//       thumbnail: post['file']['thumbnail'] ?? "",
//       fileType: post['fileType'] ?? "",
//       fileUrl: post['file']['fileUrl'] ?? "",
//       errMessage: post['errMessage'] ?? "",
//     );
//   }

//   factory PostModel.fromJson(String source) =>
//       PostModel.fromMap(json.decode(source));
// }
