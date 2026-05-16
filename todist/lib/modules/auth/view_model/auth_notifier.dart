import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todist/modules/auth/data/auth_repo.dart';
import 'package:todist/modules/auth/view_model/auth_state.dart';

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<AuthState> {
  late AuthRepository _authRepository;
  @override
  build() {
    _authRepository = ref.read(authRepoProvider);
    return onStart();
  }

  AuthState onStart() {
    final user = _authRepository.getCurrentUser();
    if (user != null) {
      return Authenticated(user: user);
    } else {
      return AuthInitial();
    }

  }

  void login({required String email, required String password}) async {
    try {
      state = LoginLoading();
      final res = await _authRepository.login(
        email: email.trim(),
        password: password.trim(),
      );
      res.fold(
        (l) {
          state = LoginFailure(message: l.message);
        },
        (r) {
          state = LoginSuccess(message: r.message, user: r.data);
        },
      );
    } catch (e) {
      state = LoginFailure(message: e.toString());
    }
  }

  void register({required String email, required String password}) async {
    try {
      state = Registering();
      final res = await _authRepository.register(
        email: email.trim(),
        password: password.trim(),
      );
      res.fold(
        (l) {
          state = RegisterFailure(message: l.message);
        },
        (r) {
          state = Registered(message: r.message, user: r.data);
        },
      );
    } catch (e) {
      state = RegisterFailure(message: e.toString());
    }
  }

  void logout() async {
    try {
      state = LogoutProcessing();
      await _authRepository.logout().then(
        (_) => state = LogoutSuccess(message: 'Logout successful'),
      );

    } catch (e) {
      state = LogoutFailure(message: e.toString());
    }
  }
}
