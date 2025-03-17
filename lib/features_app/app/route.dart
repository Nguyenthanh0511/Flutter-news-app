import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_news_app/features_app/news/screens/bloc/main_news_bloc.dart';
import 'package:flutter_news_app/features_app/news/screens/mainNewsScreen/main_news_screen.dart';
import 'package:flutter_news_app/features_app/news/screens/mainNewsScreen/main_news_screen.dart';
import 'package:flutter_news_app/cores/di/service_locator.dart';
// Theem thu vien
import 'package:go_router/go_router.dart';
class AppRoute {
  GoRouter generatedRoute(){
    return GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder:(context, state){
            return BlocProvider.value(
              value: serviceLocator<MainNewsBloc>()
              ..add(MainNewsGetRecentEvent()),
              child: const MainNewsScreen(),
            );
          }
        )
      ]
    );
  }
}