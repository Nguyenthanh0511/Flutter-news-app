part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

// Khởi tạo sự kiện
class LoadInitialProfilevent extends ProfileEvent {
  final bool sortByDate;
  // final String? attributeSort;
  final String? keySearch; // Tham số tìm kiếm theo title
  // final String? Function(NewsEntity element)? attributeSortSelector; // Nếu dùng mệnh đề lấy thuộc tính như này thì firebase không lọc được
  final String? attributeSortSelector;
  final String? startDate;
  final String? endDate;
  // final String? attributeSearch;
  const LoadInitialProfilevent({this.sortByDate = false, this.keySearch,this.attributeSortSelector, this.startDate, this.endDate});
  
  @override
  List<Object?> get props => [sortByDate, keySearch, ];
}

class LoadMoreProfileEvent extends ProfileEvent {} // Load thêm phần tử

class RefreshProfileEvent extends ProfileEvent {}

class InsertProfileNewsEvent extends ProfileEvent { // Đăng bài ( Của user đăng nhập)
  final String id;
  final NewsEntity newsEntity;
  const InsertProfileNewsEvent({required this.id, required this.newsEntity});
  
  @override
  List<Object?> get props => [id, newsEntity];
}

class UpdateProfileNewsEvent extends ProfileEvent {// Sửa bài ( Của user đăng nhập)
  final String id;
  final NewsEntity newsEntity;
  const UpdateProfileNewsEvent({required this.id, required this.newsEntity});
  
  @override
  List<Object?> get props => [id, newsEntity];
}

class GetDetailProfileNewsEvent extends ProfileEvent { // Lấy chi tiết bài viết ( Của user đăng nhập)
  final String id;
  const GetDetailProfileNewsEvent({required this.id});
  
  @override
  List<Object?> get props => [id];
}

class DeleteProfileNewsEvent extends ProfileEvent {
  final String id;
  const DeleteProfileNewsEvent({required this.id});
  
  @override
  List<Object?> get props => [id];
}
