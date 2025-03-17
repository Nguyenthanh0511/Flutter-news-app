import 'package:flutter_news_app/features_app/news/domain/entity/news_entity.dart';

// Abstract là một giao diện trừu tượng định nghĩa các action bên dưới
abstract class NewsRepository { 
  Future<List<NewsEntity>> getNews(); // Ví dụ getNews. Lúc sử dụng đến chỉ cần gọi đến hàm này ( Người dùng sẽ không cần quan tâm bên trong viết như nào?)
}