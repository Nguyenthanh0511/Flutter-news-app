import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_news_app/cores/di/service_locator.dart';
import 'package:flutter_news_app/features_app/news/domain/entity/news_entity.dart';
import 'package:flutter_news_app/features_app/news/domain/entity/user_entity.dart';
import 'package:flutter_news_app/features_app/news/domain/repository/tbl_repository.dart';
import 'package:flutter_news_app/features_app/news/domain/usecase/tbl_usecase.dart';
import 'package:flutter_news_app/features_app/news/service/authenService/auth_service.dart';
import 'package:collection/collection.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final TblUsecase<NewsEntity> tblUsecase;
  static const int _pageSize = 50; // Số lượng item mỗi trang ( Mặc định ban đầu ( Sẽ được tăng lên tại thời điểm người dùng load trang) )
  String? _currentSearchQuery; // Lưu từ khóa tìm kiếm hiện tại
  // Khởi tạo các event
  ProfileBloc({required this.tblUsecase}) : super(ProfileNewsInitialState()) {
    on<LoadInitialProfilevent>(_onLoadInitial); // Load trang ban đầu
    on<LoadMoreProfileEvent>(_onLoadMore); // Người dùng lướt xuống sẽ load trang
    on<RefreshProfileEvent>(_onRefresh); // Refesh lại trang. Khi load
    on<InsertProfileNewsEvent>(_onInsertNews); // Thêm
    on<UpdateProfileNewsEvent>(_onUpdateNews);
    on<GetDetailProfileNewsEvent>(_onGetDetailNews);
    on<DeleteProfileNewsEvent>(_onDeleteNews);
  }

  // Ban đầu nó sẽ load trang. Chỉ lấy ra 10 phần tử đầu tiên là trang 1. 
  // Và cứ như thế số trang tiếp theo sẽ là x = 10 * n. Với n = n + 1, n = 1. 
  // Trong đó x là số phần tử (record(bản ghi)) và n là số trang
  Future<void> _onLoadInitial(
    LoadInitialProfilevent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(ProfileNewsLoadingState());
      _currentSearchQuery = event.keySearch; // Lưu lại từ khóa tìm kiếm
      // _currentAttributeSearch = event.attributeSearch;
      // _currentAttributeSort = event.attributeSort;
      print('Gia tri sortByDate ở onLoadInitial: ${event.sortByDate}');
      print('Gia tri _currentSearchQuery: ${_currentSearchQuery}');
      final stream = tblUsecase.getList(
         pageSize: 1000, // đây là x: Số phần tử ( Đặt cao cao bởi vì như vậy mới thấy bài viết)
        pageNumber: 1, // đây là n: Số trang
        sortByDate: event.sortByDate,
        attributeSortSelector: "publishedAt",     
        keySearch: _currentSearchQuery,
        attributeSearchSelector: (element) => element.title,
        startDate: event.startDate,
        endDate: event.endDate
      );
      final news = await stream.first; // News entity

      final UserEntity? userToken = await serviceLocator<AuthService>().getUserRequested();
      final String userId = userToken?.id ?? '';
      print('id user: $userId');
      // Lọc ra những bài viết của user đăng nhập
      print('news length: ${news.length}');

      final fileterdNews = news.where((element) {
        // print('element: ${element.toJson()}');
        // print('element userCodepost: ${element.userCodePost}, news id: ${element.code}');
        // if(element.userCodePost?.toLowerCase() == userId.toLowerCase()){
        //   print('news id: ${element.code}, userCodePost: ${element.userCodePost}');
        // }
        return element.userCodePost?.toLowerCase() == userId.toLowerCase();
      }).toList();

      // for(final element in news.toList()){
      //   print('element: ${element.toJson()}');
      //   print('element userCodepost: ${element.userCodePost}, news id: ${element.code}');
      //   if(element.userCodePost?.toLowerCase() == userId.toLowerCase()){
      //     print('news id: ${element.code}, userCodePost: ${element.userCodePost}');
      //     fileterdNews.add(element);
      //   }
      // }
      print('fileterdNews length: ${fileterdNews.length}');
      final newsStored = fileterdNews.sortedBy((element) => element.publishedAt ?? '');
      
      print('newsStored length: ${newsStored.length}');
      emit(ProfileNewsLoadedState(
        // news: news,
        news: newsStored.length > 0 ? newsStored : [],
        currentPage: 1,
        hasReachedMax: news.length < _pageSize,
      ));
    } catch (e) {
      emit(ProfileNewsErrorState(e.toString()));
    }
  }
  
  
  Future<void> _onLoadMore(
    LoadMoreProfileEvent event, // Sự kiện ( Bắt lấy người dùng kéo xuống quá 10 phần tử (x))
    Emitter<ProfileState> emit, // Trạng thái
  ) async {
    if (state is! ProfileNewsLoadedState) return; // Nếu trạng thái không phải là người dùng load trang sẽ trả về y nguyên vậy
    final currentState = state as ProfileNewsLoadedState;
    if (currentState.hasReachedMax) return;
    try {
      emit(ProfileNewsLoadingState(news: currentState.news));
      final nextPage = currentState.currentPage + 1; // Cộng thêm số trang tiếp theo ( n = n + 1)
      // print('attribute search selector: ${(element) => element.title}');
      print('nextPage: ${nextPage}');
      final stream = tblUsecase.getList(
        pageSize: _pageSize,
        pageNumber: nextPage,
        sortByDate: false,
        attributeSortSelector: "publishedAt",
        // keySearch: _currentSearchQuery,
        // attributeSearchSelector: (element) => element.title
      );
      final newNews = await stream.first;
      final allNews = [...currentState.news, ...newNews];
      emit(ProfileNewsLoadedState(
        news: allNews,
        currentPage: nextPage,
        hasReachedMax: newNews.length < _pageSize,
      ));
    } catch (e) {
      emit(ProfileNewsErrorState(e.toString(), news: currentState.news));
    }
  }

  // Hàm này load lại trang
  Future<void> _onRefresh(
    RefreshProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    add(LoadInitialProfilevent(
      sortByDate: true, // Mặc định là sắp xếp theo ngày mới
      // keySearch: _currentSearchQuery, 
      // attributeSearch: _currentAttributeSearch,
      attributeSortSelector: "publishedAt"
    ));
  }

  Future<void> _onInsertNews(
    InsertProfileNewsEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(ProfileNewsOperationInProgressState(news: state.news, operation: "insert"));
      print('Bloc insert: ${event.newsEntity.toJson()}');
      await tblUsecase.insertRecord(event.id, event.newsEntity);
      TblRepository<UserEntity> userEntity = serviceLocator<TblRepository<UserEntity>>();
      print('Gia tri user id: ${event.newsEntity.userCodePost??''}');
      final userDb = await userEntity.getDetail(event.newsEntity.userCodePost??'');
      if(userDb == null){
        throw Exception('False posting. User is null with id: ${userDb?.id}');
      }
      print('user: ${userDb.toJson()}'); 
      if(userDb.postCount == null){
        print('postCount null');
      } 
      final postCountDb = (userDb?.postCount ?? 0);
      final countPost = postCountDb + 1;
      print('countPost: $countPost');
      final userUpdate = userDb.copyWith(postCount: countPost);
      userEntity.updateById(userDb.id??'', userUpdate);

      add(LoadInitialProfilevent(sortByDate: false, keySearch: _currentSearchQuery));
      
    } catch (e) {
      print('Bloc lỗi khi insert: ${e.toString()}');
      emit(ProfileNewsOperationFailureState(e.toString(), news: state.news, operation: "insert"));
    }
  }

 Future<void> _onUpdateNews(
  UpdateProfileNewsEvent event,
  Emitter<ProfileState> emit,
) async {
  try {
    emit(ProfileNewsOperationInProgressState(news: state.news, operation: "update"));
    await tblUsecase.updateById(event.id, event.newsEntity);
    add(LoadInitialProfilevent(sortByDate: false, keySearch: _currentSearchQuery));
  } catch (e) {
    emit(ProfileNewsOperationFailureState(e.toString(), news: state.news, operation: "update"));
  }
}

Future<void> _onDeleteNews(
  DeleteProfileNewsEvent event,
  Emitter<ProfileState> emit,
) async {
  try {
    emit(ProfileNewsOperationInProgressState(news: state.news, operation: "delete"));
    await tblUsecase.deleteById(event.id);
    final userToken = await serviceLocator<AuthService>().getUserRequested();
    final userId = userToken?.id ?? '';
    TblRepository<UserEntity> userEntity = serviceLocator<TblRepository<UserEntity>>();
    final userDb = await userEntity.getDetail(userId);
    if (userDb != null) {
      final postCount = (userDb.postCount ?? 0) - 1;
      final updatedUser = userDb.copyWith(postCount: postCount);
      await userEntity.updateById(userId, updatedUser);
    }
    add(LoadInitialProfilevent(sortByDate: false, keySearch: _currentSearchQuery));
  } catch (e) {
    emit(ProfileNewsOperationFailureState(e.toString(), news: state.news, operation: "delete"));
  }
}

  Future<void> _onGetDetailNews(
    GetDetailProfileNewsEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(ProfileNewsLoadingState());
      final newsDetail = await tblUsecase.getDetail(event.id);
      emit(ProfileNewsDetailLoadedState(newsDetail: newsDetail, news: state.news));
    } catch (e) {
      emit(ProfileNewsErrorState(e.toString()));
    }
  }


  Future<String> uploadImage(File imageFile) async {
  try {
    // Implement logic upload ảnh lên server của bạn
    // Ví dụ sử dụng Firebase Storage:
    final ref = FirebaseStorage.instance.ref().child('posts/${DateTime.now().millisecondsSinceEpoch}'); // Lưu vào 

    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
    
  } catch (e) {
    throw Exception('Lỗi upload ảnh: $e');
  }
}

}