// auth_state.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_news_app/features_app/news/domain/entity/user_entity.dart';

abstract class AuthenState extends Equatable {
  const AuthenState();
  
  @override
  List<Object?> get props => [];
}

class AuthInitialState extends AuthenState {}

class AuthenLoadingState extends AuthenState {}

class AuthenAuthenticatedState extends AuthenState {
  final UserEntity user;
  
  const AuthenAuthenticatedState({required this.user});
  
  @override
  List<Object?> get props => [user];
}

class AuthenErrorState extends AuthenState {
  final String error;
  
  const AuthenErrorState({required this.error});
  
  @override
  List<Object?> get props => [error];
}

class AuthenUnauthenticatedState extends AuthenState {}


