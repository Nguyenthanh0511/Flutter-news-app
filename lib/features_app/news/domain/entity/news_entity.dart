import 'dart:convert';

import 'package:flutter/foundation.dart';
// import 'package:flutter_news_app/features_app/news/domain/entity/news_entity.g.dart';
// import 'package:freezed/builder.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'news_entity.freezed.dart';
part 'news_entity.g.dart';
// Dependency thêm ( freezed, freezed_annotation, foudatation)
// Dùng tới 3 thư viện này để ta cấu hình theo dạng entity view ( Tức là không thao tác trực tiếp tới entity mà sẽ thông qua một thực thể
// bản sao của entity đấy)
/// Dùng freezed giúp cho tạo một đối tượng dạng copy dễ dàng thao tác với dạng lưu trữ Json khi mã hóa, giải mã
/// 
@freezed // Dặt freezed ở đây nó sẽ lấy những thuộc tính dưới 
class NewsEntity with _$NewsEntity{ // Xu ly context này ( _TênEntityConText)
  const factory NewsEntity({
    String? title, 
    String? description,
    String? url,
    @JsonKey(name: 'urlToImage') String? imageUrl,
    String? publishedAt,
    String? content
    }) = _NewsEntity;
// Vẫn có giá trị mà nhỉ ( Check lại kĩ nhé )
    factory NewsEntity.fromJson(Map<String, Object?> json) =>
      _$NewsEntityFromJson(json); // Tạo một entity json
    
}