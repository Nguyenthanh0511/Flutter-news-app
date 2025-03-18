import 'package:flutter_news_app/features_app/news/domain/entity/news_entity.dart';
import 'package:flutter_news_app/features_app/news/domain/usecase/get_recent_news_usecase.dart';
import 'package:flutter_news_app/features_app/news/domain/usecase/tbl_usecase.dart';

class PushDataFromApiToFirebaseUsecase {
  final GetUseCaseApi getNewsApiUseCase;
  final TblUsecase<NewsEntity> newsTblUsecase;

  PushDataFromApiToFirebaseUsecase({
    required this.getNewsApiUseCase,
    required this.newsTblUsecase,
  });

  /// Thực hiện:
  /// 1. Gọi API lấy danh sách tin tức.
  /// 2. Với mỗi tin tức, gọi hàm insertRecord của repository để đẩy dữ liệu vào Firebase.

  Future<void> execute() async{
     try {
      final List<NewsEntity> newsList = await getNewsApiUseCase.call();
      for (var news in newsList) {
        print('Inserted news with ID: $news');
        final String code = DateTime.now().millisecondsSinceEpoch.toString();

        // Gọi hàm insertRecord từ TblUsecase để thêm tin tức vào bảng 'news'
        await newsTblUsecase.insertRecord(code, news);
      };
  } catch (e) {
    print('Lỗi khi thực hiện đẩy dữ liệu từ api lên firebase: $e');
    // Bạn có thể thêm xử lý lỗi cụ thể ở đây
  }
  }
  // Dang ky DI
}