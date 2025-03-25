import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_news_app/features_app/news/domain/entity/news_entity.dart';
import 'package:flutter_news_app/features_app/news/domain/usecase/tbl_usecase.dart';

part 'main_news_event.dart';
part 'main_news_state.dart';

class MainNewsBloc extends Bloc<MainNewsEvent, MainNewsState> {
  final TblUsecase<NewsEntity> tblUsecase;
  static const int _pageSize = 50; // Số lượng item mỗi trang ( Mặc định ban đầu ( Sẽ được tăng lên tại thời điểm người dùng load trang) )
  String? _currentSearchQuery; // Lưu từ khóa tìm kiếm hiện tại
  // Khởi tạo các event
  MainNewsBloc({required this.tblUsecase}) : super(NewsInitialState()) {
    on<LoadInitialNewsEvent>(_onLoadInitial); // Load trrang ban đầu
    on<LoadMoreNewsEvent>(_onLoadMore); // Người dùng lướt xuống sẽ load trang
    on<RefreshNewsEvent>(_onRefresh); // Refesh lại trang. Khi load
    on<InsertNewsEvent>(_onInsertNews); // Thêm
    on<UpdateNewsEvent>(_onUpdateNews);
    on<GetDetailNewsEvent>(_onGetDetailNews);
    on<DeleteNewsEvent>(_onDeleteNews);
  }

  // Ban đầu nó sẽ load trang. Chỉ lấy ra 10 phần tử đầu tiên là trang 1. 
  // Và cứ như thế số trang tiếp theo sẽ là x = 10 * n. Với n = n + 1, n = 1. 
  // Trong đó x là số phần tử (record(bản ghi)) và n là số trang
  Future<void> _onLoadInitial(
    LoadInitialNewsEvent event,
    Emitter<MainNewsState> emit,
  ) async {
    try {
      emit(NewsLoadingState());
      _currentSearchQuery = event.keySearch; // Lưu lại từ khóa tìm kiếm
      // _currentAttributeSearch = event.attributeSearch;
      // _currentAttributeSort = event.attributeSort;
      final stream = tblUsecase.getList(
        pageSize: _pageSize, // đây là x: Số phần tử
        pageNumber: 1, // đây là n: Số trang
        sortByDate: event.sortByDate,
        attributeSortSelector: "publishedAt",
        keySearch: _currentSearchQuery,
        attributeSearchSelector: (element) => element.title,
        startDate: event.startDate,
        endDate: event.endDate
      );
      final news = await stream.first;
      final newsStored = event.sortByDate
      ? news.sortedBy((element) => element.publishedAt ?? '')
      : news.sortedBy((element) => (element.publishedAt ?? '').toLowerCase()).reversed.toList();
      // final newsStored = news.sortedBy((element) => element.publishedAt ?? '').sortedByCompare(keyOf, compare);

      
      emit(NewsLoadedState(
        news: newsStored,
        currentPage: 1,
        hasReachedMax: news.length < _pageSize,
      ));
    } catch (e) {
      emit(NewsErrorState(e.toString()));
    }
  }
  
  // Vừa xong loadMore nhé
  Future<void> _onLoadMore(
    LoadMoreNewsEvent event, // Sự kiện ( Bắt lấy người dùng kéo xuống quá 10 phần tử (x))
    Emitter<MainNewsState> emit, // Trạng thái
  ) async {
    if (state is! NewsLoadedState) return; // Nếu trạng thái không phải là người dùng load trang sẽ trả về y nguyên vậy
    final currentState = state as NewsLoadedState;
    if (currentState.hasReachedMax) return;
    try {
      emit(NewsLoadingState(news: currentState.news));
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
      final allNews = [...currentState.news, ...newNews]; // Nối liền dữ liệu ( Cóo lẽ sẽ là nguyên nhân sort sai)
      emit(NewsLoadedState(
        news: allNews,
        currentPage: nextPage,
        hasReachedMax: newNews.length < _pageSize,
      ));
    } catch (e) {
      emit(NewsErrorState(e.toString(), news: currentState.news));
    }
  }

  // Hàm này load lại trang
  Future<void> _onRefresh(
    RefreshNewsEvent event,
    Emitter<MainNewsState> emit,
  ) async {
    add(LoadInitialNewsEvent(
      sortByDate: true, // Mặc định là sắp xếp theo ngày mới
      // keySearch: _currentSearchQuery, 
      // attributeSearch: _currentAttributeSearch,
      attributeSortSelector: "publishedAt"
    ));
  }

  Future<void> _onInsertNews(
    InsertNewsEvent event,
    Emitter<MainNewsState> emit,
  ) async {
    try {
      emit(NewsOperationInProgressState(news: state.news, operation: "insert"));
      await tblUsecase.insertRecord(event.id, event.newsEntity);
      add(LoadInitialNewsEvent(sortByDate: false, keySearch: _currentSearchQuery));
    } catch (e) {
      emit(NewsOperationFailureState(e.toString(), news: state.news, operation: "insert"));
    }
  }

  Future<void> _onUpdateNews(
    UpdateNewsEvent event,
    Emitter<MainNewsState> emit,
  ) async {
    try {
      emit(NewsOperationInProgressState(news: state.news, operation: "update"));
      await tblUsecase.updateById(event.id, event.newsEntity);
      add(LoadInitialNewsEvent(sortByDate: false, keySearch: _currentSearchQuery, ));
    } catch (e) {
      emit(NewsOperationFailureState(e.toString(), news: state.news, operation: "update"));
    }
  }

  // Khi người dùng xem chi tiết bài viết, tăng viewCount và cập nhật lại vào Firebase
  Future<void> _onGetDetailNews(
    GetDetailNewsEvent event,
    Emitter<MainNewsState> emit,
  ) async {
    try {
      emit(NewsOperationInProgressState(news: state.news, operation: "getDetail"));
      final detail = await tblUsecase.getDetail(event.id);
      if (detail != null) {
        final newViewCount = (detail.viewCount ?? 0) + 1;
        final updatedNews = detail.copyWith(viewCount: newViewCount);
        await tblUsecase.updateById(event.id, updatedNews);
        final updatedDetail = await tblUsecase.getDetail(event.id);
        emit(NewsDetailLoadedState(newsDetail: updatedDetail, news: state.news));
      } else {
        emit(NewsErrorState("Không tìm thấy bài viết", news: state.news));
      }
    } catch (e) {
      emit(NewsOperationFailureState(e.toString(), news: state.news, operation: "getDetail"));
    }
  }

  Future<void> _onDeleteNews(
    DeleteNewsEvent event,
    Emitter<MainNewsState> emit,
  ) async {
    try {
      emit(NewsOperationInProgressState(news: state.news, operation: "delete"));
      await tblUsecase.deleteById(event.id);
      add(LoadInitialNewsEvent(sortByDate: false, keySearch: _currentSearchQuery, ));
    } catch (e) {
      emit(NewsOperationFailureState(e.toString(), news: state.news, operation: "delete"));
    }
  }
}
