import 'package:dio/dio.dart';
import 'package:flutter_news_app/cores/network/network_client.dart';
import 'package:flutter_news_app/cores/shared/contants.dart';
import 'package:flutter_news_app/features_app/news/dataStorage/apiCall/news_call_api.dart';
import 'package:flutter_news_app/features_app/news/dataStorage/repository/tbl_repository_implement.dart';
import 'package:flutter_news_app/features_app/news/domain/entity/news_entity.dart';
import 'package:flutter_news_app/features_app/news/domain/repository/news_repository.dart';
import 'package:flutter_news_app/features_app/news/domain/repository/tbl_repository.dart';
import 'package:flutter_news_app/features_app/news/domain/usecase/connect_firebase_usecase.dart';
import 'package:flutter_news_app/features_app/news/domain/usecase/tbl_usecase.dart';
import 'package:flutter_news_app/features_app/news/screens/bloc/main_news_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_news_app/features_app/news/dataStorage/repository/implement_repository.dart';
import 'package:flutter_news_app/features_app/news/domain/usecase/get_recent_news_usecase.dart';
import 'package:flutter_news_app/features_app/news/domain/usecase/push_data_from_api_to_firebase_usecase.dart';
import 'package:flutter_news_app/features_app/news/domain/entity/user_entity.dart';
import 'package:flutter_news_app/cores/shared/connectFirebase/database_service.dart';
final serviceLocator = GetIt.instance; // dependency theem get_it ( Để đăng ký các DI)

// Sử dụng file để khởi tạo các instance dễ quản lý vòng đời ứng dụng

// Ý tưởng khi cần lấy đến một instance của Dio thì GetIt sẽ:
// - Init instance
// - Init NetWorkClient với đối tượng Dio truyền vào constants từ  serviceLocator
// - Trả về thuộc tính NetWorkClient với dio
setupServiceLocator() async { // Cấu hình dịch vụ

  // Connect firebase
  // Đăng ký ConnectFirebaseUseCase trước
  serviceLocator.registerSingletonAsync<ConnectFirebaseUseCase>(
    () async {
      final connectFirebaseUseCase = ConnectFirebaseUseCase();
      await connectFirebaseUseCase.initializeApp();
      return connectFirebaseUseCase;
    },
  );
  
  if (!serviceLocator.isRegistered<DatabaseService>()) {
    // Nếu bạn có dependency khác phụ thuộc vào ConnectFirebaseUseCase, sử dụng dependsOn
    serviceLocator.registerSingletonAsync<DatabaseService>(
      () async {
        // Đảm bảo Firebase đã được khởi tạo qua ConnectFirebaseUseCase trước khi khởi tạo DatabaseService
        return DatabaseService();
      },
      dependsOn: [ConnectFirebaseUseCase],  // Lưu ý: ConnectFirebaseUseCase đã được đăng ký ở trên
    );
  }
  serviceLocator.registerFactory<Constants>(() => Constants());
  serviceLocator.registerFactory<Dio>( // Dio để thao tác các phương thức http
    () => NetworkClient(Dio(), constants: serviceLocator()).dio
  );

  //News
  serviceLocator.registerFactory<MainNewsBloc>(()=>MainNewsBloc(tblUsecase: serviceLocator<TblUsecase<NewsEntity>>())); // Đăng ký MainNewsBloc mới khi request
  // serviceLocator.registerLazySingleton<NewsApi>(()=>NewsApi( // Khởi tạo api khi lần đầu được yêu cầu lấy dữ liệu từ api
  //   dio: serviceLocator(), apiKey: serviceLocator<Constants>().apiKey
  // ));
  // serviceLocator.registerLazySingleton<NewsRepository>(()=>NewsRepositoryImplement( // tương tự khởi tạo Repository tới api khi lần đầu yêu cầu dữ liệu từ api
  //   newsApi: serviceLocator(), apiKey: serviceLocator<Constants>().apiKey
  // ));
  // // Đăng ký ca sử dụng call api
  // serviceLocator.registerLazySingleton<GetUseCaseApi>( 
  //   () => GetUseCaseApi( 
  //   newsRepoImplement: serviceLocator<NewsRepository>(), 
  // )); 

  // // Đẩy dữ liệu vào firebase từ api ( data )
  // serviceLocator.registerLazySingleton<PushDataFromApiToFirebaseUsecase>(
  //   () {
  //     final usecase = PushDataFromApiToFirebaseUsecase(
  //       getNewsApiUseCase: serviceLocator<GetUseCaseApi>(),
  //       newsTblUsecase: serviceLocator<TblUsecase<NewsEntity>>(),
  //     );
  //     // Không gọi execute() ở đây, thay vào đó, bạn có thể gọi nó sau khi DI đã sẵn sàng hoặc khi người dùng nhấn nút
  //     return usecase;
  //   },
  // );
  
  
  // Đăng ký database service
  // serviceLocator.registerLazySingletonAsync<DatabaseService>(() async => DatabaseService());

  //Đăng ký các ca sử dụng news và user
  serviceLocator.registerLazySingleton<TblRepository<NewsEntity>>(
    () => TblRepositoryImplement(databaseService: serviceLocator<DatabaseService>(), 
      tableName: 'news', 
      fromJson: (json) => NewsEntity.fromJson(json), 
      toJson: (news) => news.toJson())
  );

  //Ca su dung
  serviceLocator.registerLazySingleton<TblUsecase<NewsEntity>>(
    () => TblUsecase(repository: serviceLocator<TblRepository<NewsEntity>>())
  );

  ///Đăng ký các ca sử dụng news và user
  serviceLocator.registerLazySingleton<TblRepository<User>>(
    () => TblRepositoryImplement(databaseService: serviceLocator<DatabaseService>(), 
      tableName: 'user', 
      fromJson: (json) => User.fromJson(json), 
      toJson: (news) => news.toJson())
  );

  //Ca su dung
  serviceLocator.registerLazySingleton<TblUsecase<User>>(
    () => TblUsecase(repository: serviceLocator<TblRepository<User>>())
  );
}