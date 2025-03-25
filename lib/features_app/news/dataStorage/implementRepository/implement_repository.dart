import 'package:flutter_news_app/features_app/news/dataStorage/apiCall/news_call_api.dart';
import 'package:flutter_news_app/features_app/news/domain/entity/news_entity.dart';
import 'package:flutter_news_app/features_app/news/domain/repository/news_repository.dart';

// Đây là implement cho repository
class NewsRepositoryImplement implements NewsRepository{

  final NewsApi newsApi;
  final String apiKey;

  NewsRepositoryImplement({required this.newsApi, required this.apiKey});
  @override
  Future<List<NewsEntity>> getNews() => newsApi.getNewsByApi(); // Gọi đến hàm call tới api
}