import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post_model.dart';

class ApiService {
  ApiService._private();
  static final ApiService instance = ApiService._private();

  final String _base = 'https://jsonplaceholder.typicode.com';

  /// Retrieves all posts from JSONPlaceholder API.
  Future<List<PostModel>> fetchPosts() async {
    final uri = Uri.parse('$_base/posts');
    final resp = await http.get(uri).timeout(const Duration(seconds: 15));
    if (resp.statusCode == 200) {
      final List<dynamic> data = jsonDecode(resp.body) as List<dynamic>;
      return data
          .map((e) => PostModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to fetch posts: ${resp.statusCode}');
  }

  /// Optional helper to fetch posts for a specific user ID.
  Future<List<PostModel>> fetchPostsByUser(int userId) async {
    final uri = Uri.parse('$_base/posts?userId=$userId');
    final resp = await http.get(uri).timeout(const Duration(seconds: 15));
    if (resp.statusCode == 200) {
      final List<dynamic> data = jsonDecode(resp.body) as List<dynamic>;
      return data
          .map((e) => PostModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to fetch posts by user: ${resp.statusCode}');
  }
}

