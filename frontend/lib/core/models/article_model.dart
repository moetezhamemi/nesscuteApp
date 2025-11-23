class ArticleModel {
  final int? id;
  final String name;
  final String? description;
  final double price;
  final String type;
  final String? imageUrl;
  final double globalRating;
  final int ratingCount;
  final List<CommentModel>? comments;

  ArticleModel({
    this.id,
    required this.name,
    this.description,
    required this.price,
    required this.type,
    this.imageUrl,
    this.globalRating = 0.0,
    this.ratingCount = 0,
    this.comments,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      type: json['type'],
      imageUrl: json['imageUrl'],
      globalRating: (json['globalRating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: json['ratingCount'] ?? 0,
      comments: json['comments'] != null
          ? (json['comments'] as List).map((c) => CommentModel.fromJson(c)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'type': type,
      'imageUrl': imageUrl,
      'globalRating': globalRating,
      'ratingCount': ratingCount,
      'comments': comments?.map((c) => c.toJson()).toList(),
    };
  }
}

class CommentModel {
  final int? id;
  final String content;
  final String userName;
  final int? userId;
  final DateTime? createdAt;

  CommentModel({
    this.id,
    required this.content,
    required this.userName,
    this.userId,
    this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      content: json['content'],
      userName: json['userName'],
      userId: json['userId'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'userName': userName,
      'userId': userId,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}

