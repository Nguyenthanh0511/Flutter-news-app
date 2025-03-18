part of 'main_news_bloc.dart';

abstract class MainNewsState extends Equatable {
  @override
  List<Object> get props => [];
}

class NewsInitialState extends MainNewsState {}

class NewsLoadingState extends MainNewsState {
  final List<NewsEntity> oldNews;
  
  NewsLoadingState({this.oldNews = const []});
}

class NewsLoadedState extends MainNewsState {
  final List<NewsEntity> news;
  final int currentPage;
  final bool hasReachedMax;

  NewsLoadedState({
    required this.news,
    required this.currentPage,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [news, currentPage, hasReachedMax];
}

class NewsErrorState extends MainNewsState {
  final String message;
  final List<NewsEntity> oldNews;

  NewsErrorState(this.message, {this.oldNews = const []});
}