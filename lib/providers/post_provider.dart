import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/api_service.dart';

/// Provider that manages post data fetched from a REST API.
///
/// This class implements the interface described in the project README, including
/// fetch/retry/search helpers as well as convenient getters for UI code.
class PostProvider extends ChangeNotifier {
  // internal state
  final List<PostModel> _posts = [];
  bool _isLoading = false;
  String? _errorMessage;

  /// Public read-only accessors used by UI code.
  List<PostModel> get posts => List.unmodifiable(_posts);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetch all posts from the remote API and update state.
  ///
  /// This will clear any previous error and set loading flags appropriately.
  Future<void> fetchPosts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final fetched = await ApiService.instance.fetchPosts();
      _posts
        ..clear()
        ..addAll(fetched);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Retry last failed fetch by just calling [fetchPosts] again.
  void retry() => fetchPosts();

  /// Search cached posts for a case-insensitive match on title or body.
  List<PostModel> searchPosts(String query) {
    final lower = query.toLowerCase();
    return _posts.where((p) {
      return p.title.toLowerCase().contains(lower) || p.body.toLowerCase().contains(lower);
    }).toList(growable: false);
  }

  /// Returns a post with the given id or null if not found.
  PostModel? getPostById(int id) {
    try {
      return _posts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Convenience method to fetch only posts for a specific user.
  Future<void> fetchPostsByUser(int userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final fetched = await ApiService.instance.fetchPostsByUser(userId);
      _posts
        ..clear()
        ..addAll(fetched);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

