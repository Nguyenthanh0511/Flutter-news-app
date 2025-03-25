part of 'main_news_bloc.dart';

abstract class MainNewsEvent extends Equatable {
  const MainNewsEvent();
  @override
  List<Object?> get props => [];
}

// Khởi tạo sự kiện
class LoadInitialNewsEvent extends MainNewsEvent {
  final bool sortByDate;
  // final String? attributeSort;
  final String? keySearch; // Tham số tìm kiếm theo title
  // final String? Function(NewsEntity element)? attributeSortSelector; // Nếu dùng mệnh đề lấy thuộc tính như này thì firebase không lọc được
  final String? attributeSortSelector;
  // final String? attributeSearch;
  final String? startDate;
  final String? endDate;
  const LoadInitialNewsEvent({this.sortByDate = false, this.keySearch,this.attributeSortSelector, this.startDate, this.endDate});
  
  @override
  List<Object?> get props => [sortByDate, keySearch, ];
}

class LoadMoreNewsEvent extends MainNewsEvent {} // Load thêm phần tử

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
