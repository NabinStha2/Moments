import 'dart:convert';
import 'dart:developer';

class PostModel {
  final String? id;
  // String? title;
  String? description;
  // List<String>? tags;
  final List<Likes>? likes;
  String? createdAt;
  String? creator;
  List<Comments> comments;
  String? name;
  String fileName;
  String thumbnail;
  String fileType;
  String fileUrl;
  String? errMessage;

  PostModel({
    required this.id,
    // required this.title,
    required this.description,
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
    required this.thumbnail,
    // required this.tags,
    required this.likes,
    required this.createdAt,
    required this.creator,
    required this.comments,
    required this.name,
    required this.errMessage,
  });

  Map<String, dynamic> toMap() {
    // print(post['file']['fileUrl']);
    // debugPrintStack(label: "hey");
    return {
      "id": id,
      // "title": title,
      "description": description,
      "likes": likes,
      "comments": comments,
      "createdAt": createdAt,
      // "tags": tags,
      "creator": creator,
      "name": name,
      "fileName": fileName,
      "thumbnail": thumbnail,
      "fileType": fileType,
      "fileUrl": fileUrl,
      "errMessage": errMessage,
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> post) {
    // print(post['file']['fileUrl']);
    // debugPrintStack(label: "hey");
    return PostModel(
      id: post['_id'] ?? "",
      // title: post['title'] ?? "",
      description: post['description'] ?? "",
      likes: post['likes'] != null
          ? List.from(post['likes']!)
              .map((like) => Likes.fromMap(like))
              .toList()
          : [],
      comments: post['comments'] != null
          ? (post['comments'] as List)
              .map((cmt) => Comments.fromMap(cmt))
              .toList()
          : [],
      createdAt: post['createdAt'] ?? "",
      // tags: List<String>.from(post['tags'])
      //             .map((tag) => tag.toString())
      //             .toList() !=
      //         []
      //     ? List<String>.from(post['tags'])
      //         .map((tag) => tag.toString())
      //         .toList()
      //     : [],
      creator: post['creator'] ?? "",
      name: post['name'] ?? "",
      fileName: post['file']['fileName'] ?? "",
      thumbnail: post['file']['thumbnail'] ?? "",
      fileType: post['fileType'] ?? "",
      fileUrl: post['file']['fileUrl'] ?? "",
      errMessage: post['errMessage'] ?? "",
    );
  }

  factory PostModel.fromJson(String source) =>
      PostModel.fromMap(json.decode(source));
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

  factory Likes.fromMap(Map<String, dynamic> map) {
    log("Like: $map");
    return Likes(
      userId: map['userId'] ?? "",
      timestamps: map['timestamps'] ?? DateTime.now(),
      reactionType: map['reactionType'] ?? "",
    );
  }

  factory Likes.fromJson(String source) => Likes.fromMap(json.decode(source));
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

  Map<String, dynamic> toMap() {
    return {
      'commentName': commentName,
      'commentUserId': commentUserId,
      'timestamps': timestamps,
      'commentId': commentId,
      'replyComments': replyComments?.map((x) => x.toMap()).toList(),
      'activityId': replyComments?.map((x) => x.toMap()).toList(),
    };
  }

  factory Comments.fromMap(Map<String, dynamic> map) {
    // log("$map");
    return Comments(
      commentName: map['commentName'] ?? "",
      commentUserId: map['commentUserId'] ?? "",
      commentId: map['_id'] ?? "",
      timestamps: map['timestamps'] ?? DateTime.now(),
      activityId: map['activityId'] != null
          ? (map['activityId'] as List)
              .map((actId) => actId.toString())
              .toList()
          : [],
      replyComments: map['replyComments'] != null
          ? List<ReplyComments>.from(
              map['replyComments']?.map((x) => ReplyComments.fromMap(x)))
          : [],
    );
  }

  String toJson() => json.encode(toMap());

  factory Comments.fromJson(String source) =>
      Comments.fromMap(json.decode(source));
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

  Map<String, dynamic> toMap() {
    return {
      'commentName': commentName,
      'commentUserId': commentUserId,
      'timestamps': timestamps,
      'replyCommentId': replyCommentId,
    };
  }

  factory ReplyComments.fromMap(Map<String, dynamic> map) {
    return ReplyComments(
      commentName: map['commentName'],
      commentUserId: map['commentUserId'],
      timestamps: map['timestamps'],
      replyCommentId: map['_id'],
    );
  }

  String toJson() => json.encode(toMap());

  factory ReplyComments.fromJson(String source) =>
      ReplyComments.fromMap(json.decode(source));
}

class PostResponse {
  final List<PostModel> postModel;
  final int pages;

  PostResponse({
    required this.postModel,
    required this.pages,
  });

  factory PostResponse.fromMap(Map<String, dynamic> map) {
    return PostResponse(
      postModel: (map['posts'] as List)
          .map((post) => PostModel.fromMap(post))
          .toList(),
      pages: map['pages'] ?? 1,
    );
  }

  factory PostResponse.fromJson(String source) =>
      PostResponse.fromMap(json.decode(source));
}

class SinglePostModel {
  final PostModel postModel;

  SinglePostModel({
    required this.postModel,
  });

  factory SinglePostModel.fromMap(Map<String, dynamic> map) {
    // print(map['post']);
    return SinglePostModel(
      postModel: PostModel.fromMap(map['post']),
    );
  }

  factory SinglePostModel.fromJson(String source) =>
      SinglePostModel.fromMap(json.decode(source));
}
