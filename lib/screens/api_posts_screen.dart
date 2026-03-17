import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';

class ApiPostsScreen extends StatefulWidget {
  const ApiPostsScreen({super.key});

  @override
  State<ApiPostsScreen> createState() => _ApiPostsScreenState();
}

class _ApiPostsScreenState extends State<ApiPostsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PostProvider>(context, listen: false).fetchPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('API Posts')),
      body: Consumer<PostProvider>(builder: (context, p, _) {
        if (p.isLoading) return const Center(child: CircularProgressIndicator());
        if (p.errorMessage != null) return _errorView(context, p.errorMessage!);
        return ListView.separated(
          itemCount: p.posts.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final post = p.posts[i];
            return ListTile(
              title: Text(post.title),
              subtitle: Text(post.body, maxLines: 2, overflow: TextOverflow.ellipsis),
              leading: CircleAvatar(child: Text(post.id.toString())),
            );
          },
        );
      }),
    );
  }

  Widget _errorView(BuildContext context, String message) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Error: $message', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: () => Provider.of<PostProvider>(context, listen: false).fetchPosts(), child: const Text('Retry'))
          ]),
        ),
      );
}
