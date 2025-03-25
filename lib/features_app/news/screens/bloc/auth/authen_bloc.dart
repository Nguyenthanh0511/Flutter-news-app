// auth_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_news_app/features_app/news/domain/entity/user_entity.dart';
import 'package:flutter_news_app/features_app/news/domain/repository/tbl_repository.dart';
import 'package:flutter_news_app/features_app/news/service/authenService/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:flutter_news_app/cores/di/service_locator.dart';
import 'package:go_router/go_router.dart';
// Bloc
class AuthenBloc extends Bloc<AuthenEvent, AuthenState>{
  final AuthService authenService = serviceLocator<AuthService>(); // Khỏi tạo AuthenService
  
   AuthenBloc() : super(AuthInitialState()) { // Khoi tao ham 
    on<LoginRequestEvent>(_onLoginRequested);
    on<RegisterRequestedEvent>(_onRegisterRequested);
    on<LogoutRequestedEvent>(_onLogoutRequested);
    on<GetUserEvent>(_getUserRequested);
  }

  Future<void> _onLoginRequested(LoginRequestEvent event, Emitter<AuthenState> emit) async {
      emit(AuthenLoadingState()); // iem tra trang thai loading
      try {
        final credential = await authenService.login(email: event.email, password: event.password);
        // Chuyển đổi Firebase user thành custom User
        
        final user = authenService.userFromFirebase(credential.user);
        if (user != null) {
          emit(AuthenAuthenticatedState(user: user)); // Trang thai thanh
        } else {
          emit(const AuthenErrorState(error: 'User is null')  );
        }
      } catch (e) {
        emit(AuthenErrorState(error: e.toString()));
      }
    }


    Future<void> _onRegisterRequested(RegisterRequestedEvent event, Emitter<AuthenState> emit) async {
    emit(AuthenLoadingState());
    try {
      final credential = await authenService.register(email: event.email, password: event.password);
      // Tạo đối tượng User với UID từ FirebaseAuth và thông tin thêm từ form
      final user = UserEntity(
        id: credential.user!.uid, // UID từ FirebaseAuth
        name: event.name, // Thông tin từ event (bạn cần truyền vào)
        email: event.email,
        age: event.age,
        phoneNumber: event.phoneNumber,
        address: event.address,
        sex: event.sex,
        role: 'User', // Mặc định là 'User'
      );
      // final user = authenService.userFromFirebase(credential.user);

      if (user != null) {
        print('Model user: ${user.toJson()}');
          // Lưu thông tin user vào Firebase Database
        await authenService.saveUserDetails(user);
        emit(AuthenAuthenticatedState(user: user));
      } else {
        emit(const AuthenErrorState(error: 'User is null'));
      }
    } catch (e) {
      print('Error: $e');
      emit(AuthenErrorState(error: e.toString()));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequestedEvent event, Emitter<AuthenState> emit) async {
    await authenService.logout();
    emit(AuthenUnauthenticatedState());
  }
  
  // Lấy thông tin người dùng
  Future<UserEntity?> _getUserRequested(GetUserEvent event, Emitter<AuthenState> emit) async {
    try{
      emit(AuthenLoadingState()); // iem tra trang thai loading
      final TblRepository<UserEntity> userEntity = serviceLocator<TblRepository<UserEntity>>();
      final String? uid = event.uid;
      final user = await userEntity.getDetail(uid!);
      print('get user: ${user!.toJson()}');
      if(user == null){
        print('User is null with id: $uid');
        throw Exception('User is null with id: $uid');
      }
      emit(AuthenUnauthenticatedState());
      return user;
    } 
    catch (e) {
      
      print('Lỗi get dữ liệu user: $e');
      throw Exception('Lỗi get dữ liệu user: $e');
    }
  }




}


