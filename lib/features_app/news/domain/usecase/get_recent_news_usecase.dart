import 'package:flutter_news_app/features_app/news/domain/repository/news_repository.dart';
import 'package:flutter_news_app/features_app/news/domain/entity/news_entity.dart';

// Use case sử dụng api
class GetUseCaseApi{
  final NewsRepository newsRepoImplement; // Gọi đến repository
  GetUseCaseApi({required this.newsRepoImplement});

  Future<List<NewsEntity>> call() async => newsRepoImplement.getNews();

}