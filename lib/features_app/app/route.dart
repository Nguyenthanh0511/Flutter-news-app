import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_news_app/features_app/news/screens/bloc/profile/profile_bloc.dart';
import 'package:flutter_news_app/features_app/news/screens/loginScreen/login_screen.dart';
import 'package:flutter_news_app/features_app/news/screens/bloc/auth/auth_event.dart';
import 'package:flutter_news_app/features_app/news/screens/bloc/main_news_bloc.dart';
import 'package:flutter_news_app/features_app/news/screens/bloc/auth/authen_bloc.dart';
import 'package:flutter_news_app/features_app/news/screens/mainNewsScreen/main_news_screen.dart';
import 'package:flutter_news_app/cores/di/service_locator.dart';

import 'package:flutter_news_app/features_app/news/screens/loginScreen/register_screen.dart';
import 'package:flutter_news_app/features_app/news/screens/profileScreen/profile_screen.dart';
import 'package:flutter_news_app/features_app/news/screens/profileScreen/post_news_screen.dart';
// Theem thu vien
import 'package:go_router/go_router.dart';
class AppRoute {

  GoRouter generatedRoute(
    // bool firebaseConnected, String? errorMessage
    ){
    return GoRouter(
      initialLocation: '/login', // Trang main
      routes: [ // Trang main
      GoRoute(
          path: '/login', // Trang main
          builder: (context, state) {
            // Lấy đối số extra được truyền qua route (nếu có)
            return BlocProvider(
                create: (context) => serviceLocator<AuthenBloc>(),
                child: const LoginScreen(),
              );
          },
        ),
        GoRoute(
          path: '/main-news', // Trang main
          builder: (context, state) {
            // Lấy đối số extra được truyền qua route (nếu có)
            return BlocProvider(
                create: (context) => serviceLocator<MainNewsBloc>()
                  ..add(LoadInitialNewsEvent()), // Sử dụng event mới
                child: const MainNewsScreen(),
              );
          },
        ),
        GoRoute(
          path: '/register', // Trang main
          builder: (context, state){
            return BlocProvider(
              create: (context) => serviceLocator<AuthenBloc>(),
              child: const RegisterScreen(),
            );
          }
        ),
        GoRoute(
          path: '/profile',
           builder: (context, state) {
            return MultiBlocProvider(
              providers: [
                BlocProvider<AuthenBloc>(
                  create: (context) => serviceLocator<AuthenBloc>(),
                ),
                BlocProvider<ProfileBloc>(
                  create: (context) => serviceLocator<ProfileBloc>(),
                ),
              ],
              child: const ProfileScreen(),
            );
          },
        ),
        GoRoute(
        path: '/create-post',
        builder: (context, state) => BlocProvider<ProfileBloc>(
          create: (context) => serviceLocator<ProfileBloc>(),
          child: CreatePostScreen(),
        ),
      ),
        
      ]
    );
  }
}