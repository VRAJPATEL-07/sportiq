/// LAB 7: Post Provider for Dynamic Data Management
/// 
/// State management for posts fetched from REST API
/// Uses Provider pattern for reactive UI updates
library;

import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/api_service.dart';

/// PostProvider: Manages the state of posts fetched from the JSONPlaceholder API
/// 
/// Responsibilities:
///   - Fetching posts from the REST API
///   - Managing loading state during API calls
///   - Handling and displaying error messages
///   - Notifying listeners when state changes
///   - Providing retry functionality on API failures
/// 
/// Example usage in widget:
///   ```dart
///   final postProvider = Provider.of<PostProvider>(context);
///   if (postProvider.isLoading) {
///     return CircularProgressIndicator();
///   } else if (postProvider.errorMessage != null) {
///     return Text('Error: ${postProvider.errorMessage}');
///   } else {
///     return ListView(
///       children: postProvider.posts.map((post) => PostCard(post: post)).toList(),
///     );
///   }
///   ```
class PostProvider extends ChangeNotifier {
  // LAB 7: State variables
  List<PostModel> _posts = [];
  bool _isLoading = false;
  String? _errorMessage;

  /// Returns the list of fetched posts
  List<PostModel> get posts => _posts;

  /// Returns true if API request is in progress
  bool get isLoading => _isLoading;

  /// Returns error message if API request failed, null otherwise
  String? get errorMessage => _errorMessage;

  /// Fetches posts from the JSONPlaceholder API
  /// 
  /// This method:
  ///   1. Sets isLoading to true
  ///   2. Clears any previous error message
  ///   3. Makes API request via ApiService
  ///   4. Stores posts in _posts list
  ///   5. Handles errors appropriately
  ///   6. Notifies listeners of state changes
  /// 
  /// Error Handling:
  ///   - API timeout errors
  ///   - Network errors
  ///   - JSON parsing errors
  ///   - HTTP status code errors
  Future<void> fetchPosts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // LAB 7: REST API Integration
      final List<PostModel> fetchedPosts = await ApiService.fetchPosts();
      
      _posts = fetchedPosts;
      _errorMessage = null;
    } catch (e) {
      // LAB 7: Error handling
      _posts = [];
      _errorMessage = 'Failed to load posts: ${e.toString()}';
      // ignore: avoid_print
      print('Error fetching posts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches posts by a specific user ID
  /// 
  /// Parameters:
  ///   - userId: The user ID to filter posts by
  Future<void> fetchPostsByUser(int userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final List<PostModel> fetchedPosts =
          await ApiService.fetchPostsByUser(userId);
      
      _posts = fetchedPosts;
      _errorMessage = null;
    } catch (e) {
      _posts = [];
      _errorMessage = 'Failed to load posts for user $userId: ${e.toString()}';
      print('Error fetching posts for user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches a single post by ID
  /// 
  /// Parameters:
  ///   - id: The post ID to fetch
  /// 
  /// Returns:
  ///   - The PostModel if successful, null if failed
  Future<PostModel?> fetchPostById(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final PostModel post = await ApiService.fetchPostById(id);
      _errorMessage = null;
      return post;
    } catch (e) {
      _errorMessage = 'Failed to load post: ${e.toString()}';
      print('Error fetching post by id: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Retries fetching posts (useful for error recovery)
  /// 
  /// This method is called when user taps the "Retry" button
  /// after an API error occurs
  Future<void> retry() async {
    await fetchPosts();
  }

  /// Clears posts and error state
  /// 
  /// Useful when navigating away from the posts screen
  void clearPosts() {
    _posts = [];
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Searches posts by title (locally, after fetched)
  /// 
  /// Parameters:
  ///   - query: The search query string
  /// 
  /// Returns:
  ///   - A list of PostModels matching the query
  List<PostModel> searchPosts(String query) {
    if (query.isEmpty) {
      return _posts;
    }
    return _posts
        .where((post) =>
            post.title.toLowerCase().contains(query.toLowerCase()) ||
            post.body.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  /// Gets a post by ID from the current posts list
  /// 
  /// Parameters:
  ///   - id: The post ID to find
  /// 
  /// Returns:
  ///   - The PostModel if found, null otherwise
  PostModel? getPostById(int id) {
    try {
      return _posts.firstWhere((post) => post.id == id);
    } catch (e) {
      return null;
    }
  }
}
