import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_news_app/features_app/news/domain/entity/news_entity.dart';
import 'package:flutter_news_app/features_app/news/domain/repository/news_repository.dart'; // Cai nay chi la canh bao( warming)
import 'package:flutter_news_app/cores/di/service_locator.dart';
import 'package:flutter_news_app/features_app/news/domain/usecase/get_recent_news_usecase.dart';
// PART (Chia nhỏ file ra dễ quản lsy)
part 'main_news_event.dart';
part 'main_news_state.dart';
// Theo kiến trúc BLOC đây là phần chính, để quán lý sự kiện và trạng trạng thái


class MainNewsBloc extends Bloc<MainNewsEvent, MainNewsState>{
  MainNewsBloc() : super(MainNewsInitialState()){ // Khi moi khởi tạo đây sẽ là trạng thái mặc định
    on<MainNewsGetRecentEvent>(mainNewsGetRecentEvent); // Lắng nghe sự kiện và gọi đến
  }

  Future<void> mainNewsGetRecentEvent(
    MainNewsGetRecentEvent event, Emitter<MainNewsState> emit ) async{
      try{
        emit(MainNewsLoadingState()); // Loading state
        // Caasu hinh di ( dependency injection toi api)
        // Gọi đến api
        List<NewsEntity> news = await serviceLocator<GetUseCaseApi>().call(); // Tao them ca su dung ( api )
        emit(MainNewsGetRecentNewsSuccessState(news:news));
        
      }
      catch(e){
        emit(MainNewsErrorState(e.toString())); // Bắt lỗi
      }
    }
  
}
