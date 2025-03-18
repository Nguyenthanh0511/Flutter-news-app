part of 'main_news_bloc.dart';

abstract class MainNewsEvent extends Equatable {
  @override
  List<Object> get props => [];
}

// Event cho lần load đầu tiên
class LoadInitialNewsEvent extends MainNewsEvent {
  final bool sortByDate;
  
  LoadInitialNewsEvent({this.sortByDate = false});
}

// Event cho load thêm
class LoadMoreNewsEvent extends MainNewsEvent {}

// Event làm mới dữ liệu
class RefreshNewsEvent extends MainNewsEvent {}