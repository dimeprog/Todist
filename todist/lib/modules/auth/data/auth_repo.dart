import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todist/core/di.dart';
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
}

final authRepoProvider = Provider<AuthRepository>((_) {
  return AuthRepositoryImpl(client: getIt<Supabase>().client);
});

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient client;

  const AuthRepositoryImpl({required this.client});

  @override
  FutureResponse<UserModel> login({
    required String email,
    required String password,
  }) {
    // TODO: implement login
    throw UnimplementedError();
  }

  @override
  FutureResponse<UserModel> register({
    required String email,
    required String password,
  }) {
    // TODO: implement register
    throw UnimplementedError();
  }
}
