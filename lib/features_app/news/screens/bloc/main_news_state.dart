part of 'main_news_bloc.dart';

abstract class MainNewsState extends Equatable {
  final List<NewsEntity> news;
  const MainNewsState({this.news = const []});
  
  @override
  List<Object?> get props => [news];
}

class NewsInitialState extends MainNewsState {}

class NewsLoadingState extends MainNewsState {
  const NewsLoadingState({List<NewsEntity> news = const []}) : super(news: news);
}

class NewsLoadedState extends MainNewsState {
  final int currentPage;
  final bool hasReachedMax;
  const NewsLoadedState({
    required List<NewsEntity> news,
    required this.currentPage,
    required this.hasReachedMax,
  }) : super(news: news);
  
  @override
  List<Object?> get props => [news, currentPage, hasReachedMax];
}

class NewsErrorState extends MainNewsState {
  final String message;
  const NewsErrorState(this.message, {List<NewsEntity> news = const []}) : super(news: news);
  
  @override
  List<Object?> get props => [message, news];
}

class NewsOperationInProgressState extends MainNewsState {
  final String operation;
  const NewsOperationInProgressState({List<NewsEntity> news = const [], required this.operation})
      : super(news: news);
  
  @override
  List<Object?> get props => [news, operation];
}

class NewsOperationFailureState extends MainNewsState {
  final String message;
  final String operation;
  const NewsOperationFailureState(this.message, {List<NewsEntity> news = const [], required this.operation})
      : super(news: news);
  
  @override
  List<Object?> get props => [message, news, operation];
}

class NewsDetailLoadedState extends MainNewsState {
  final NewsEntity? newsDetail;
  const NewsDetailLoadedState({this.newsDetail, List<NewsEntity> news = const []})
      : super(news: news);
  
  @override
  List<Object?> get props => [newsDetail, news];
}
