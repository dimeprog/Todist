import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
    } catch (e) {
      debugPrint(e.toString());
      return Left(Failure(e.toString()));
    }
  }
  
  @override
  Stream<AuthState> authStateChanges() {
    return client.auth.onAuthStateChange;
  }
}
