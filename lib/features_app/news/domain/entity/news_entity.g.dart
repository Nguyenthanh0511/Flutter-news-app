part of 'news_entity.dart';

// File g.dart này sẽ là 1 phần ở file news_entity.dart
_$_NewsEntity _$$_NewsEntityFromJson(Map<String, dynamic> json ){
  //Khoi tao constructor
  return _$_NewsEntity(
    title: json['title'] as String?,
    description: json['description'] as String?,
    url: json['url'] as String?,
    imageUrl: json['urlToImage'] as String?, // Khả ngăn là ở đây
    publishedAt: json['publishedAt'] as String?,
    content: json['content'] as String?,
  );
}

  // Chuyyển tới json
  Map<String, dynamic> _$$_NewsEntityToJson(_$_NewsEntity instance) => <String, dynamic>{
    'title': instance.title,
    'description': instance.description,
    'url': instance.url,
    'imageUrl': instance.imageUrl,
    'publishedAt': instance.publishedAt,
    'content': instance.content
  };
