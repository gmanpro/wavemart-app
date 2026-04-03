import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/auth_service.dart';
import '../../data/models/user.dart';

/// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Auth State - Current authenticated user
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState.initial());

  /// Check if user is authenticated
  Future<void> checkAuth() async {
    final isAuthenticated = await _authService.isAuthenticated();
    if (isAuthenticated) {
      await loadUser();
    }
  }

  /// Load current user data
  Future<void> loadUser() async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        state = AuthState.unauthenticated();
      }
    } catch (e) {
      state = AuthState.unauthenticated();
    }
  }

  /// Send OTP to phone number
  Future<AuthResponse> sendOtp(String phoneNumber) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final response = await _authService.sendOtp(phoneNumber: phoneNumber);
    if (response.success) {
      state = state.copyWith(
        isLoading: false,
        phoneNumber: phoneNumber,
        otpSent: true,
      );
    } else {
      state = state.copyWith(isLoading: false, errorMessage: response.message);
    }
    return response;
  }

  /// Login with OTP
  Future<AuthResponse> login(String otpCode) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final response = await _authService.login(
      phoneNumber: state.phoneNumber ?? '',
      otpCode: otpCode,
    );
    if (response.success && response.user != null) {
      state = AuthState.authenticated(response.user!);
    } else {
      state = state.copyWith(isLoading: false, errorMessage: response.message);
    }
    return response;
  }

  /// Verify OTP
  Future<AuthResponse> verifyOtp(String otpCode) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final response = await _authService.verifyOtp(
      phoneNumber: state.phoneNumber ?? '',
      otpCode: otpCode,
    );
    state = state.copyWith(isLoading: false);
    return response;
  }

  /// Resend OTP
  Future<AuthResponse> resendOtp() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final response = await _authService.resendOtp(
      phoneNumber: state.phoneNumber ?? '',
    );
    state = state.copyWith(isLoading: false);
    return response;
  }

  /// Logout
  Future<void> logout() async {
    await _authService.logout();
    state = AuthState.unauthenticated();
  }
}

/// Auth State
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final bool otpSent;
  final User? user;
  final String? phoneNumber;
  final String? errorMessage;

  const AuthState({
    required this.isAuthenticated,
    this.isLoading = false,
    this.otpSent = false,
    this.user,
    this.phoneNumber,
    this.errorMessage,
  });

  factory AuthState.initial() => const AuthState(
    isAuthenticated: false,
    isLoading: false,
    otpSent: false,
  );

  factory AuthState.authenticated(User user) => AuthState(
    isAuthenticated: true,
    isLoading: false,
    otpSent: false,
    user: user,
    phoneNumber: user.phoneNumber,
    errorMessage: null,
  );

  factory AuthState.unauthenticated() => const AuthState(
    isAuthenticated: false,
    isLoading: false,
    otpSent: false,
    user: null,
    phoneNumber: null,
    errorMessage: null,
  );

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    bool? otpSent,
    User? user,
    String? phoneNumber,
    String? errorMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      otpSent: otpSent ?? this.otpSent,
      user: user ?? this.user,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      errorMessage: errorMessage,
    );
  }
}
