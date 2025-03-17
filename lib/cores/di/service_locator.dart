import 'package:dio/dio.dart';
import 'package:flutter_news_app/cores/network/network_client.dart';
import 'package:flutter_news_app/cores/shared/contants.dart';
import 'package:flutter_news_app/features_app/news/dataStorage/apiCall/news_call_api.dart';
import 'package:flutter_news_app/features_app/news/domain/repository/news_repository.dart';
import 'package:flutter_news_app/features_app/news/screens/bloc/main_news_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_news_app/features_app/news/dataStorage/repository/implement_repository.dart';
import 'package:flutter_news_app/features_app/news/domain/usecase/get_recent_news_usecase.dart';
final serviceLocator = GetIt.instance; // dependency theem get_it ( Để đăng ký các DI)

// Sử dụng file để khởi tạo các instance dễ quản lý vòng đời ứng dụng

// Ý tưởng khi cần lấy đến một instance của Dio thì GetIt sẽ:
// - Init instance
// - Init NetWorkClient với đối tượng Dio truyền vào constants từ  serviceLocator
// - Trả về thuộc tính NetWorkClient với dio
setupServiceLocator(){ // Cấu hình dịch vụ
  serviceLocator.registerFactory<Constants>(() => Constants());
  serviceLocator.registerFactory<Dio>( // Dio để thao tác các phương thức http
    () => NetworkClient(Dio(), constants: serviceLocator()).dio
  );

  //News
  serviceLocator.registerFactory<MainNewsBloc>(()=>MainNewsBloc()); // Đăng ký MainNewsBloc mới khi request
  serviceLocator.registerLazySingleton<NewsApi>(()=>NewsApi( // Khởi tạo api khi lần đầu được yêu cầu lấy dữ liệu từ api
    dio: serviceLocator(), apiKey: serviceLocator<Constants>().apiKey
  ));
  serviceLocator.registerLazySingleton<NewsRepository>(()=>NewsRepositoryImplement( // tương tự khởi tạo Repository tới api khi lần đầu yêu cầu dữ liệu từ api
    newsApi: serviceLocator(), apiKey: serviceLocator<Constants>().apiKey
  ));
  // Đăng ký ca sử dụng call api
  serviceLocator.registerLazySingleton<GetUseCaseApi>( 
    () => GetUseCaseApi( 
    newsRepoImplement: serviceLocator<NewsRepository>(), 
  )); 
}