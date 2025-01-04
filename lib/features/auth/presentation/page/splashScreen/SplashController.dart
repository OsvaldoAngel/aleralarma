// splash_controller.dart
import 'package:aleralarma/features/auth/domain/repository/auth_repository.dart';
import 'package:aleralarma/features/auth/presentation/page/login/login_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final splashControllerProvider = StateNotifierProvider<SplashController, AsyncValue<void>>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return SplashController(authRepository);
});

class SplashController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _authRepository;

  SplashController(this._authRepository) : super(const AsyncValue.loading()) {
    checkAuth();
  }

  Future<void> checkAuth() async {
    try {
      state = const AsyncValue.loading();
      await _authRepository.refreshTokenUser();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
