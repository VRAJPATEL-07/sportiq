/// LAB 7: REST API Integration
/// API Service for handling HTTP requests and JSON parsing
/// 
/// This service manages all REST API calls and JSON parsing for the application.
/// It uses the http package for making HTTP requests and includes error handling
/// and response status code management.
library;

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/post_model.dart';

/// Service class for API operations
/// 
/// Handles all HTTP requests, responses, and JSON parsing
class ApiService {
  /// Base URL for the JSONPlaceholder API
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  /// Private constructor for singleton pattern (optional)
  ApiService._();

  /// Fetches a list of posts from the JSONPlaceholder API
  /// 
  /// This method makes a GET request to the /posts endpoint and parses
  /// the JSON response into a list of PostModel objects.
  /// 
  /// Returns:
  ///   - A Future that resolves to a List<PostModel> containing all posts
  /// 
  /// Throws:
  ///   - Exception: If the HTTP request fails or JSON parsing fails
  /// 
  /// HTTP Status Codes:
  ///   - 200: Success - returns parsed posts
  ///   - 400: Bad Request
  ///   - 410: Gone
  ///   - 500: Internal Server Error
  /// 
  /// Example:
  ///   ```dart
  ///   try {
  ///     final posts = await ApiService.fetchPosts();
  ///     print('Fetched ${posts.length} posts');
  ///   } catch (e) {
  ///     print('Error: $e');
  ///   }
  ///   ```
  static Future<List<PostModel>> fetchPosts() async {
    try {
      final Uri url = Uri.parse('$baseUrl/posts');
      
      // Make HTTP GET request
      final http.Response response = await http.get(url).timeout(
        const Duration(seconds: 30),
        onTimeout: () =>
            throw Exception('API request timeout after 30 seconds'),
      );

      // Check HTTP status code
      if (response.statusCode == 200) {
        // LAB 7: JSON Parsing
        // Parse the JSON response body
        final dynamic decodedBody = jsonDecode(response.body);

        // Convert JSON to List<PostModel>
        if (decodedBody is List) {
          final List<PostModel> posts = decodedBody
              .map((item) => PostModel.fromJson(item as Map<String, dynamic>))
              .toList();
          return posts;
        } else {
          throw Exception('Expected JSON array but got: ${decodedBody.runtimeType}');
        }
      } else if (response.statusCode == 400) {
        throw Exception('Bad Request (400): Invalid request parameters');
      } else if (response.statusCode == 410) {
        throw Exception('Gone (410): Resource is no longer available');
      } else if (response.statusCode == 500) {
        throw Exception('Server Error (500): Internal server error');
      } else {
        throw Exception(
          'Failed to load posts. Status: ${response.statusCode}\n'
          'Response: ${response.body}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Fetches a single post by ID
  /// 
  /// Parameters:
  ///   - id: The post ID to fetch
  /// 
  /// Returns:
  ///   - A Future that resolves to a PostModel
  static Future<PostModel> fetchPostById(int id) async {
    try {
      final Uri url = Uri.parse('$baseUrl/posts/$id');
      
      final http.Response response = await http.get(url).timeout(
        const Duration(seconds: 15),
        onTimeout: () =>
            throw Exception('API request timeout after 15 seconds'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData =
            jsonDecode(response.body) as Map<String, dynamic>;
        return PostModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to load post. Status: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Fetches posts by a specific user ID
  /// 
  /// Parameters:
  ///   - userId: The user ID to filter posts by
  /// 
  /// Returns:
  ///   - A Future that resolves to a List<PostModel> filtered by userId
  static Future<List<PostModel>> fetchPostsByUser(int userId) async {
    try {
      final Uri url = Uri.parse('$baseUrl/posts?userId=$userId');
      
      final http.Response response = await http.get(url).timeout(
        const Duration(seconds: 20),
        onTimeout: () =>
            throw Exception('API request timeout after 20 seconds'),
      );

      if (response.statusCode == 200) {
        final dynamic decodedBody = jsonDecode(response.body);
        
        if (decodedBody is List) {
          final List<PostModel> posts = decodedBody
              .map((item) => PostModel.fromJson(item as Map<String, dynamic>))
              .toList();
          return posts;
        } else {
          throw Exception('Expected JSON array');
        }
      } else {
        throw Exception('Failed to load posts. Status: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Creates a new post (sends POST request)
  /// 
  /// Parameters:
  ///   - post: The PostModel to create
  /// 
  /// Returns:
  ///   - A Future that resolves to the created PostModel with API response
  static Future<PostModel> createPost(PostModel post) async {
    try {
      final Uri url = Uri.parse('$baseUrl/posts');
      
      final http.Response response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(post.toJson()),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () =>
            throw Exception('API request timeout after 15 seconds'),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> jsonData =
            jsonDecode(response.body) as Map<String, dynamic>;
        return PostModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to create post. Status: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
