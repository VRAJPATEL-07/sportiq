/// LAB 7: API Integration & Dynamic Data
/// Post Model for JSONPlaceholder API
/// 
/// This model represents a post retrieved from the JSONPlaceholder API
/// It includes JSON serialization methods for API responses
library;

class PostModel {
  final int userId;
  final int id;
  final String title;
  final String body;

  /// Constructor for PostModel
  /// 
  /// Parameters:
  ///   - userId: The user ID associated with this post
  ///   - id: The unique post identifier
  ///   - title: The post title
  ///   - body: The post content/body
  PostModel({
    required this.userId,
    required this.id,
    required this.title,
    required this.body,
  });

  /// Creates a PostModel instance from JSON
  /// 
  /// This method parses JSON response from the API and converts it
  /// to a PostModel object for use in the application.
  /// 
  /// Parameters:
  ///   - json: A map containing the JSON data from the API
  /// 
  /// Returns:
  ///   - A new PostModel instance with values from the JSON
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      userId: json['userId'] as int? ?? 0,
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
    );
  }

  /// Converts PostModel to JSON
  /// 
  /// This method converts the PostModel object into a JSON-compatible
  /// map format that can be sent to APIs or stored locally.
  /// 
  /// Returns:
  ///   - A map representation of this PostModel
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'id': id,
      'title': title,
      'body': body,
    };
  }

  /// String representation for debugging
  @override
  String toString() =>
      'PostModel(userId: $userId, id: $id, title: $title, body: $body)';

  /// Equality comparison
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostModel &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          id == other.id &&
          title == other.title &&
          body == other.body;

  /// Hash code for equality
  @override
  int get hashCode =>
      userId.hashCode ^ id.hashCode ^ title.hashCode ^ body.hashCode;
}
