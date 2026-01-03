import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/auth_service.dart';
import '../models/user_model.dart';

// Services
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// State
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({User? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error, // If explicit null passed? No, this simplified logic clears error if not passed.
    );
  }
  
  bool get isAuthenticated => user != null;
}

// Controller / Notifier
class AuthController extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthController(this._authService) : super(AuthState());

  Future<bool> login(String email, String password) async {
    state = AuthState(isLoading: true);
    try {
      final user = await _authService.login(email: email, password: password);
      state = AuthState(user: user, isLoading: false);
      return true;
    } catch (e) {
      state = AuthState(error: e.toString().replaceAll('Exception: ', ''), isLoading: false);
      return false;
    }
  }

  Future<bool> signup(String name, String email, String password) async {
    state = AuthState(isLoading: true);
    try {
      final user = await _authService.signup(name: name, email: email, password: password);
      state = AuthState(user: user, isLoading: false);
      return true;
    } catch (e) {
      state = AuthState(error: e.toString().replaceAll('Exception: ', ''), isLoading: false);
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthController(authService);
});
