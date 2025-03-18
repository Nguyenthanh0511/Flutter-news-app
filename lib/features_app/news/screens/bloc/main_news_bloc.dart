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

  MainNewsBloc({required this.tblUsecase}) : super(NewsInitialState()) {
    on<LoadInitialNewsEvent>(_onLoadInitial);
    on<LoadMoreNewsEvent>(_onLoadMore);
    on<RefreshNewsEvent>(_onRefresh);
  }

  Future<void> _onLoadInitial(
    LoadInitialNewsEvent event,
    Emitter<MainNewsState> emit,
  ) async {
    try {
      emit(NewsLoadingState());

      final stream = tblUsecase.getList(
        pageSize: _pageSize,
        pageNumber: 1,
        sortByDate: event.sortByDate,
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
      emit(NewsLoadingState(oldNews: currentState.news));

      final nextPage = currentState.currentPage + 1;
      final stream = tblUsecase.getList(
        pageSize: _pageSize,
        pageNumber: nextPage,
        sortByDate: false,
      );

      final newNews = await stream.first;
      final allNews = [...currentState.news, ...newNews];

      emit(NewsLoadedState(
        news: allNews,
        currentPage: nextPage,
        hasReachedMax: newNews.length < _pageSize,
      ));
    } catch (e) {
      emit(NewsErrorState(e.toString(), oldNews: currentState.news));
    }
  }

  Future<void> _onRefresh(
    RefreshNewsEvent event,
    Emitter<MainNewsState> emit,
  ) async {
    add(LoadInitialNewsEvent());
  }
}