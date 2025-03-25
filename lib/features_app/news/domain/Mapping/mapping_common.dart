import 'package:flutter_news_app/features_app/news/domain/entity/comment_entity.dart';
import 'package:flutter_news_app/features_app/news/domain/entityView/comment_entity_view.dart';

extension CommentMapping on CommentEntity {
  CommentEntityView toView({String? userName}) {
    return CommentEntityView(
      code: code,
      content: content,
      newsCode: newsCode,
      userCode: userCode,
      createDate: createDate,
      updateDate: updateDate,
      userCodeUpdate: userCodeUpdate,
      userName: userName, // Cung cấp tên người dùng nếu có
    );
  }
}