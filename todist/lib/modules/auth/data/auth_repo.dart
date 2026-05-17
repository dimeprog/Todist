import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todist/core/app_local_prefs.dart';
import 'package:todist/core/failure.dart';
import 'package:todist/core/response_data.dart';
import 'package:todist/core/typedefs.dart';
import 'package:todist/models/user_model.dart';

abstract class AuthRepository {
  FutureResponse<UserModel> register({
    required String email,
    required String password,
  });
  FutureResponse<UserModel> login({
    required String email,
    required String password,
  });

  Stream<AuthState> authStateChanges();

UserModel? getCurrentUser();

  FutureResponse<bool> logout();
}

final authRepoProvider = Provider<AuthRepository>((_) {
  return AuthRepositoryImpl(client: Supabase.instance.client);
});

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient client;

  const AuthRepositoryImpl({required this.client});

  @override
  FutureResponse<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await client.auth.signInWithPassword(
        password: password,
        email: email,
      );
      return Right(
        ResponseData(
          data: UserModel(email: result.user!.email!, id: result.user!.id),
        ),
      );
    } on AuthException catch (e) {
      final errorMsg = AuthErrorHandler.getMessage(e);
      return Left(Failure(errorMsg));
    } catch (e) {
      debugPrint(e.toString());
      return Left(Failure(e.toString()));
    }
  }

  @override
  FutureResponse<UserModel> register({
    required String email,
    required String password,
  }) async {
    try {
      final result = await client.auth.signUp(password: password, email: email);
      return Right(
        ResponseData(
          data: UserModel(email: result.user!.email!, id: result.user!.id),
        ),
      );
    } on AuthException catch (e) {
      final errorMsg = AuthErrorHandler.getMessage(e);
      return Left(Failure(errorMsg));
    } catch (e) {
      debugPrint(e.toString());
      return Left(Failure(e.toString()));
    }
  }

  @override
  Stream<AuthState> authStateChanges() {
    return client.auth.onAuthStateChange;
  }

  @override
  FutureResponse<bool> logout() async {
    try {
      await client.auth.signOut();
      AppLocalPrefs.clearAll();
      return Right(ResponseData(data: true));
    } catch (e) {
      debugPrint(e.toString());
      return Left(Failure(e.toString()));
    }
  }
  
  @override
  UserModel? getCurrentUser() {
    try {
      final user = client.auth.currentUser;
      if (user == null) return null;
      return UserModel.fromSupaBase(user);
    } catch (e) {
      return null;
    }
  }
}

class AuthErrorHandler {
  static String getMessage(Object error) {
    if (error is AuthException) {
      final message = error.message.toLowerCase();
      debugPrint("Supabase:$message");

      // Network
      if (message.contains('socketexception')) {
        return 'No internet connection.';
      }

      // Email errors
      if (message.contains('invalid email')) {
        return 'Please enter a valid email address.';
      }

      if (message.contains('email not confirmed')) {
        return 'Please verify your email before logging in.';
      }

      if (message.contains('user already registered')) {
        return 'An account with this email already exists.';
      }

      // Password errors
      if (message.contains('password')) {
        return 'Password must be at least 6 characters.';
      }

      // Login errors
      if (message.contains('invalid login credentials')) {
        return 'Incorrect email or password.';
      }

      // Network
      if (message.contains('network')) {
        return 'No internet connection.';
      }
      // Network
      if (message.contains('socketexception')) {
        return 'No internet connection.';
      }

      return error.message;
    }

    return 'Something went wrong. Please try again.';
  }
}
