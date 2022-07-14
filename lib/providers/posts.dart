import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:inquire_exam/providers/post.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:inquire_exam/providers/post_detail.dart';
import '../models/http_exception.dart';

class Posts with ChangeNotifier {
  List<Post> _posts = [];
  PostDetail _postDetail = PostDetail();

  List<Post> get posts {
    return [..._posts];
  }

  PostDetail get postDetails {
    return _postDetail;
  }

  Post findById(int id) {
    // final integerId = int.parse(id);
    return _posts.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndSetPosts() async {
    var url = Uri.parse(dotenv.env['API_BASE_URL'] !+ '/posts');
    final response = await http.get(url);
    final extractedData = jsonDecode(response.body);
    try {
      extractedData.map<Post>((json) => Post.fromJson(json)).toList();
      if (extractedData == null) {
        return;
      }
      final List<Post> loadedPosts = [];
      extractedData.forEach((data) {
        loadedPosts.add(Post(
          id: data['id'],
          title: data['title'],
          body: data['body'],
        ));
      });
      _posts = loadedPosts;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> retrievePost(int? id) async {
    final url = Uri.parse(dotenv.env['API_BASE_URL'] !+ '/posts/$id?_embed=comments');
    final response = await http.get(url);
    final extractedData = jsonDecode(response.body);
    try {
      _postDetail = PostDetail.fromJson(extractedData);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
    notifyListeners();
  }

  Future<void> addPost(Post post) async {
    final url = Uri.parse(dotenv.env['API_BASE_URL'] !+ '/posts');
    try {
      final response = await http.post(
        url,
        body: {'title': post.title, 'body': post.body},
      );

      final newPost = Post(
        title: post.title,
        body: post.body,
        id: jsonDecode(response.body)['id'],
      );
      _posts.add(newPost);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  //problem with api
  Future<void> addComment(Comments comment) async {
    final url = dotenv.env['API_BASE_URL'] !+ '/comments';
    try {
      final response = await http.post(
         Uri.parse(url),
        body: {'postId': comment.postId, 'body': comment.body},
      );
      final newPost = Comments(
        body: jsonDecode(response.body)["body"],
        id: jsonDecode(response.body)['id'],
        postId: jsonDecode(response.body)['postId'],
      );
      _postDetail.comments!.add(newPost);
      _postDetail.comments!.insert(0, newPost);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updatePost(int? id, Post newPost) async {
    final prodIndex = _posts.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url = Uri.parse(dotenv.env['API_BASE_URL'] !+ '/posts/$id');
      await http.put(url,
          body: {
            'title': newPost.title,
            'body': newPost.body,
          });
      _posts[prodIndex] = newPost;
      notifyListeners();
    } else {
      print('...');
    }
  }


  Future<void> deletePosts(int id) async {
    final url = Uri.parse(dotenv.env['API_BASE_URL'] !+ '/posts/$id');
    final existingPostIndex = _posts.indexWhere((prod) => prod.id == id);
    Post? existingPost = _posts[existingPostIndex];
    _posts.removeAt(existingPostIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _posts.insert(existingPostIndex, existingPost);
      notifyListeners();
      throw HttpException('Could not delete Post.');
    }
    existingPost = null;
  }
}
