/// LAB 7: API Posts Screen
/// 
/// This screen demonstrates:
///   - REST API Integration
///   - Loading states (spinner)
///   - Error handling (with retry button)
///   - Dynamic data rendering (ListView)
///   - Pull-to-refresh functionality
///   - JSON parsing and model conversion
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/post_provider.dart';
import '../../models/post_model.dart';
import '../../widgets/post_card.dart';

class ApiPostsScreen extends StatefulWidget {
  const ApiPostsScreen({super.key});

  @override
  State<ApiPostsScreen> createState() => _ApiPostsScreenState();
}

class _ApiPostsScreenState extends State<ApiPostsScreen> {
  // Search controller for filtering posts
  final TextEditingController _searchController = TextEditingController();
  List<PostModel> _filteredPosts = [];

  @override
  void initState() {
    super.initState();
    // LAB 7: Fetch posts when screen initializes
    Future.microtask(() {
      context.read<PostProvider>().fetchPosts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Updates the filtered posts list based on search query
  void _updateSearch(String query) {
    final postProvider = context.read<PostProvider>();
    setState(() {
      _filteredPosts = postProvider.searchPosts(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Posts (Lab 7)'),
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<PostProvider>(
        builder: (context, postProvider, _) {
          // Get filtered posts or all posts if no search
          final displayPosts = _searchController.text.isEmpty
              ? postProvider.posts
              : _filteredPosts;

          return Column(
            children: [
              // LAB 5: Search TextField
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search posts...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _filteredPosts = [];
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: _updateSearch,
                ),
              ),
              // Main content area
              Expanded(
                child: postProvider.isLoading
                    ? _buildLoadingState()
                    : postProvider.errorMessage != null
                        ? _buildErrorState(postProvider)
                        : displayPosts.isEmpty
                            ? _buildEmptyState()
                            : _buildPostsList(displayPosts),
              ),
            ],
          );
        },
      ),
    );
  }

  /// LAB 7: Loading State Widget
  /// Displays a loading spinner while fetching data from API
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading posts...',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  /// LAB 7: Error State Widget
  /// Displays error message with retry button
  Widget _buildErrorState(PostProvider postProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              postProvider.errorMessage ?? 'Unknown error',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // LAB 7: Retry button for error recovery
            ElevatedButton(
              onPressed: () {
                postProvider.retry();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  /// LAB 7: Empty State Widget
  /// Displays message when no posts are found
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No posts found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isNotEmpty
                  ? 'Try a different search query'
                  : 'Pull down to refresh',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  /// LAB 7: Dynamic Data Rendering with Pull-to-Refresh
  /// Displays list of posts with refresh capability
  Widget _buildPostsList(List<PostModel> posts) {
    return RefreshIndicator(
      onRefresh: () => context.read<PostProvider>().fetchPosts(),
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return PostCard(post: post);
        },
      ),
    );
  }
}
