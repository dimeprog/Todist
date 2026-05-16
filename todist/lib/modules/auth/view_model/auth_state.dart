import 'package:equatable/equatable.dart';
import 'package:todist/models/user_model.dart';

abstract class AuthState extends Equatable {}

class Authenticated extends AuthState {
  final UserModel user;
  Authenticated({required this.user});
  @override
  List<Object?> get props => [user];
}

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

// Logout states
class LogoutProcessing extends AuthState {
  final String? message;
  LogoutProcessing({ this.message});

  @override
  List<Object?> get props => [];
}

class LogoutSuccess extends AuthState {
  final String message;
  LogoutSuccess({required this.message});

  @override
  List<Object?> get props => [];
}

class LogoutFailure extends AuthState {
  final String message;
  LogoutFailure({required this.message});

  @override
  List<Object?> get props => [];
}

class LogoutNeedsAction extends AuthState {
  final int pendingCount;
  final bool hasInternet;
  LogoutNeedsAction({required this.pendingCount, required this.hasInternet});
   
  @override
  List<Object?> get props => [pendingCount, hasInternet];
}
