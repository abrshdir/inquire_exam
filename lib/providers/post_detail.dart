class PostDetail {
  int? id;
  String? title;
  String? body;
  List<Comments>? comments;

  PostDetail({this.id, this.title, this.body, this.comments});

  PostDetail.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    body = json['body'];
    if (json['comments'] != null) {
      comments = <Comments>[];
      json['comments'].forEach((v) {
        comments!.add(Comments.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['title'] = title;
    data['body'] = body;
    if (comments != null) {
      data['comments'] = comments!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Comments {
  String? id;
  String? postId;
  String? body;

  Comments({this.id, this.postId, this.body});

  Comments.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    postId = json['postId'];
    body = json['body'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['postId'] = postId;
    data['body'] = body;
    return data;
  }
}
