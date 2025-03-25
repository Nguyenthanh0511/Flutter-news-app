// auth_event.dart
import 'package:equatable/equatable.dart';

abstract class AuthenEvent extends Equatable{
  const AuthenEvent();
  @override
  //The list of properties that will be used to determine whether two instances are equal.
  List<Object?> get props => [];
  
}

class LoginRequestEvent extends AuthenEvent{
  final String email;
  final String password;

  const LoginRequestEvent({
    required this.email,
    required this.password
  });

  @override
  List<Object?> get props => [email, password];

}

// Tao su kien cho dang ky
class RegisterRequestedEvent extends AuthenEvent {
  final String email;
  final String password;
  final String name;
  final int age;
  final String phoneNumber;
  final String address;
  final int sex; // 1,2,3

  const RegisterRequestedEvent({
    required this.email,
    required this.password,
    required this.name,
    required this.age,
    required this.phoneNumber,
    required this.address,
    required this.sex,
  });

  @override
  List<Object?> get props => [email, password, name, age, phoneNumber, address, sex];
}

class LogoutRequestedEvent extends AuthenEvent {}

class GetUserEvent extends AuthenEvent {
  final String? uid;

  const GetUserEvent({required this.uid});

  @override
  List<Object?> get props => [uid];
}
