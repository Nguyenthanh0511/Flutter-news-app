import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_news_app/features_app/news/domain/entity/news_entity.dart';
import 'package:flutter_news_app/features_app/news/domain/usecase/tbl_usecase.dart';

part 'main_news_event.dart';
part 'main_news_state.dart';

class MainNewsBloc extends Bloc<MainNewsEvent, MainNewsState> {
  final TblUsecase<NewsEntity> tblUsecase;
  static const int _pageSize = 10; // Số lượng item mỗi trang
  String? _currentSearchQuery; // Lưu từ khóa tìm kiếm hiện tại

  MainNewsBloc({required this.tblUsecase}) : super(NewsInitialState()) {
    on<LoadInitialNewsEvent>(_onLoadInitial);
    on<LoadMoreNewsEvent>(_onLoadMore);
    on<RefreshNewsEvent>(_onRefresh);
    on<InsertNewsEvent>(_onInsertNews);
    on<UpdateNewsEvent>(_onUpdateNews);
    on<GetDetailNewsEvent>(_onGetDetailNews);
    on<DeleteNewsEvent>(_onDeleteNews);
  }

  Future<void> _onLoadInitial(
    LoadInitialNewsEvent event,
    Emitter<MainNewsState> emit,
  ) async {
    try {
      emit(NewsLoadingState());
      _currentSearchQuery = event.title; // Lưu lại từ khóa tìm kiếm
      final stream = tblUsecase.getList(
        pageSize: _pageSize,
        pageNumber: 1,
        sortByDate: event.sortByDate,
        title: event.title,
      );
      final news = await stream.first;
      emit(NewsLoadedState(
        news: news,
        currentPage: 1,
        hasReachedMax: news.length < _pageSize,
      ));
    } catch (e) {
      emit(NewsErrorState(e.toString()));
    }
  }

  Future<void> _onLoadMore(
    LoadMoreNewsEvent event,
    Emitter<MainNewsState> emit,
  ) async {
    if (state is! NewsLoadedState) return;
    final currentState = state as NewsLoadedState;
    if (currentState.hasReachedMax) return;
    try {
      emit(NewsLoadingState(news: currentState.news));
      final nextPage = currentState.currentPage + 1;
      final stream = tblUsecase.getList(
        pageSize: _pageSize,
        pageNumber: nextPage,
        sortByDate: false,
        title: _currentSearchQuery,
      );
      final newNews = await stream.first;
      final allNews = [...currentState.news, ...newNews];
      emit(NewsLoadedState(
        news: allNews,
        currentPage: nextPage,
        hasReachedMax: newNews.length < _pageSize,
      ));
    } catch (e) {
      emit(NewsErrorState(e.toString(), news: currentState.news));
    }
  }

  Future<void> _onRefresh(
    RefreshNewsEvent event,
    Emitter<MainNewsState> emit,
  ) async {
    add(LoadInitialNewsEvent(
      sortByDate: false,
      title: _currentSearchQuery,
    ));
  }

  Future<void> _onInsertNews(
    InsertNewsEvent event,
    Emitter<MainNewsState> emit,
  ) async {
    try {
      emit(NewsOperationInProgressState(news: state.news, operation: "insert"));
      await tblUsecase.insertRecord(event.id, event.newsEntity);
      add(LoadInitialNewsEvent(sortByDate: false, title: _currentSearchQuery));
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
      add(LoadInitialNewsEvent(sortByDate: false, title: _currentSearchQuery));
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
      add(LoadInitialNewsEvent(sortByDate: false, title: _currentSearchQuery));
    } catch (e) {
      emit(NewsOperationFailureState(e.toString(), news: state.news, operation: "delete"));
    }
  }
}
