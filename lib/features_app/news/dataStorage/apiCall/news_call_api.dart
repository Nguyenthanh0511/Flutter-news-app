// Cấu hình call api
import 'package:dio/dio.dart';
import 'package:flutter_news_app/features_app/news/domain/entity/news_entity.dart';

class NewsApi{
  final Dio dio;
  final String apiKey;

  NewsApi({required this.dio, required this.apiKey});


  Future<List<NewsEntity>> getNewsByApi() async{
    // tao api tren web nhe( Bat dau tao api)
    final res = await dio.get('/v2/everything?q=tesla&from=2025-02-18&sortBy=publishedAt&apiKey=$apiKey');
    return List<Map<String, dynamic>>.from(res.data['articles']).map((e)=> NewsEntity.fromJson(e)).toList();
  }
}