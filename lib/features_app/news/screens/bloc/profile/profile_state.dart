part of 'profile_bloc.dart';

abstract class ProfileState extends Equatable {
  final List<NewsEntity> news;
  const ProfileState({this.news = const []});
  
  @override
  List<Object?> get props => [news];
}

class ProfileNewsInitialState extends ProfileState {}

class ProfileNewsLoadingState extends ProfileState {
  const ProfileNewsLoadingState({List<NewsEntity> news = const []}) : super(news: news);
}

class ProfileNewsLoadedState extends ProfileState {
  final int currentPage;
  final bool hasReachedMax;
  const ProfileNewsLoadedState({
    required List<NewsEntity> news,
    required this.currentPage,
    required this.hasReachedMax,
  }) : super(news: news);
  
  @override
  List<Object?> get props => [news, currentPage, hasReachedMax];
}

class ProfileNewsErrorState extends ProfileState {
  final String message;
  const ProfileNewsErrorState(this.message, {List<NewsEntity> news = const []}) : super(news: news);
  
  @override
  List<Object?> get props => [message, news];
}

class ProfileNewsOperationInProgressState extends ProfileState {
  final String operation;
  const ProfileNewsOperationInProgressState({List<NewsEntity> news = const [], required this.operation})
      : super(news: news);
  
  @override
  List<Object?> get props => [news, operation];
}

class ProfileNewsOperationFailureState extends ProfileState {
  final String message;
  final String operation;
  const ProfileNewsOperationFailureState(this.message, {List<NewsEntity> news = const [], required this.operation})
      : super(news: news);
  
  @override
  List<Object?> get props => [message, news, operation];
}

class ProfileNewsDetailLoadedState extends ProfileState {
  final NewsEntity? newsDetail;
  const ProfileNewsDetailLoadedState({this.newsDetail, List<NewsEntity> news = const []})
      : super(news: news);
  
  @override
  List<Object?> get props => [newsDetail, news];
}
