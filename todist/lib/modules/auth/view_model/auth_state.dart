import 'package:equatable/equatable.dart';
import 'package:todist/models/user_model.dart';

abstract class AuthState extends Equatable {}

class AuthInitial extends AuthState {
  @override
  List<Object?> get props => throw UnimplementedError();
}

class LoginLoading extends AuthState {
  @override
  List<Object?> get props => throw UnimplementedError();
}

class LoginSuccess extends AuthState {
  final String message;
  final UserModel user;


  LoginSuccess({required this.message, required this.user});
  @override
  List<Object?> get props => throw UnimplementedError();
}

class LoginFailure extends AuthState {
  final String message;

  LoginFailure({required this.message});
  @override
  List<Object?> get props => [];
}

class Registering extends AuthState {
  @override
  List<Object?> get props => throw UnimplementedError();
}

class Registered extends AuthState {
  final String message;
  final UserModel user;

  Registered({required this.message, required this.user});
  @override
  List<Object?> get props => throw UnimplementedError();
}

class RegisterFailure extends AuthState {
   final String message;

  RegisterFailure({required this.message});
  @override
  List<Object?> get props => throw UnimplementedError();
}
