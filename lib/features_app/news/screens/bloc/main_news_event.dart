part of 'main_news_bloc.dart';

abstract class MainNewsEvent extends Equatable {
  const MainNewsEvent();
  @override
  List<Object?> get props => [];
}

class LoadInitialNewsEvent extends MainNewsEvent {
  final bool sortByDate;
  final String? title; // Tham số tìm kiếm theo title
  const LoadInitialNewsEvent({this.sortByDate = false, this.title});
  
  @override
  List<Object?> get props => [sortByDate, title];
}

class LoadMoreNewsEvent extends MainNewsEvent {}

class RefreshNewsEvent extends MainNewsEvent {}

class InsertNewsEvent extends MainNewsEvent {
  final String id;
  final NewsEntity newsEntity;
  const InsertNewsEvent({required this.id, required this.newsEntity});
  
  @override
  List<Object?> get props => [id, newsEntity];
}

class UpdateNewsEvent extends MainNewsEvent {
  final String id;
  final NewsEntity newsEntity;
  const UpdateNewsEvent({required this.id, required this.newsEntity});
  
  @override
  List<Object?> get props => [id, newsEntity];
}

class GetDetailNewsEvent extends MainNewsEvent {
  final String id;
  const GetDetailNewsEvent({required this.id});
  
  @override
  List<Object?> get props => [id];
}

class DeleteNewsEvent extends MainNewsEvent {
  final String id;
  const DeleteNewsEvent({required this.id});
  
  @override
  List<Object?> get props => [id];
}
