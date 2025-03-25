import 'dart:convert';

// Ở đây không dùng freezed nữa
class NewsEntity {
  final String? code;
  final String? title;
  final String? description;
  final String? url;
  final String? imageUrl;
  final String? publishedAt;
  final String? content;
  final int? viewCount;
  final String? userCode;
  final int? commentCount; // DDem so luong comment
  final int? likeCount; // Dem so luong like
  final String? userCodePost;
  NewsEntity({
    this.code,
    this.title,
    this.description,
    this.url,
    this.imageUrl,
    this.publishedAt,
    this.content,
    this.viewCount,
    this.userCode,
    this.commentCount,
    this.likeCount,
    this.userCodePost

  });

  // Factory method để tạo đối tượng từ JSON
  factory NewsEntity.fromJson(Map<String, dynamic> json) {
    return NewsEntity(
      code: json['code'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      url: json['url'] as String?, // Làm khóa duy nhất
      imageUrl: json['urlToImage'] as String?,
      publishedAt: json['publishedAt'] as String?,
      content: json['content'] as String?,
      viewCount: json['viewCount'] as int?,
      userCode: json['userCode'] as String?,
      commentCount: json['commentCount'] as int?,
      likeCount: json['likeCount'] as int?,
      userCodePost: json['userCodePost'] as String?
      
    );
  }

  // Chuyển đối tượng thành JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': imageUrl,
      'publishedAt': publishedAt,
      'content': content,
      'viewCount': viewCount,
      'userCode': userCode,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'userCodePost': userCodePost
    };
  }

  // Copy một bản sao của đối tượng với giá trị mới
  NewsEntity copyWith({
    String? code,
    String? title,
    String? description,
    String? url,
    String? imageUrl,
    String? publishedAt,
    String? content,
    int? viewCount,
    String? userCode,
    int? likeCount,
    int? commentCount,
    String? userCodePost
  }) {
    return NewsEntity(
      code: code ?? this.code,
      title: title ?? this.title,
      description: description ?? this.description,
      url: url ?? this.url,
      imageUrl: imageUrl ?? this.imageUrl,
      publishedAt: publishedAt ?? this.publishedAt,
      content: content ?? this.content,
      viewCount: viewCount ?? this.viewCount,
      userCode: userCode?? this.userCode,
      likeCount: likeCount?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      userCodePost: userCodePost ?? this.userCodePost
    );
  }
}
