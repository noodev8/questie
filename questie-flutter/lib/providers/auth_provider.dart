// Authentication Provider - Manages authentication state using Riverpod
// Handles login state, user session, token persistence, and automatic login/logout

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

// Authentication state model
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final Map<String, dynamic>? user;
  final String? error;
  final String? registrationEmail; // Email of successfully registered user

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
    this.registrationEmail,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    Map<String, dynamic>? user,
    String? error,
    String? registrationEmail,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error,
      registrationEmail: registrationEmail,
    );
  }

  // Convenience getters
  bool get isAnonymous => user?['is_anonymous'] == true;
  bool get isEmailVerified => user?['email_verified'] == true;
  String? get displayName => user?['display_name'];
  String? get email => user?['email'];
  int? get userId => user?['id'];
}

// Authentication provider
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _initialize();
  }

  // Initialize authentication state
  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final isLoggedIn = await AuthService.initialize();
      
      if (isLoggedIn) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: AuthService.currentUser,
          error: null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          user: null,
          error: null,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        user: null,
        error: 'Initialization failed: ${e.toString()}',
      );
    }
  }

  // Set error state
  void _setError(String error) {
    state = state.copyWith(error: error, isLoading: false);
  }

  // Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Clear registration email (after showing popup)
  void clearRegistrationEmail() {
    state = state.copyWith(registrationEmail: null);
  }

  // Register new user
  Future<bool> register({
    required String email,
    required String displayName,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await AuthService.register(
        email: email,
        displayName: displayName,
        password: password,
      );

      if (result['success']) {
        state = state.copyWith(
          isLoading: false,
          error: null,
          registrationEmail: email, // Store the email for popup
        );
        return true;
      } else {
        _setError(result['message'] ?? 'Registration failed');
        return false;
      }
    } catch (e) {
      _setError('Registration failed: ${e.toString()}');
      return false;
    }
  }

  // Login user
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await AuthService.login(
        email: email,
        password: password,
      );

      if (result['success']) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: result['user'],
          error: null,
        );
        return true;
      } else {
        // Handle specific error cases
        if (result['return_code'] == 'EMAIL_NOT_VERIFIED') {
          _setError('Email not verified. Please check your email or continue as guest.');
        } else {
          _setError(result['message'] ?? 'Login failed');
        }
        return false;
      }
    } catch (e) {
      _setError('Login failed: ${e.toString()}');
      return false;
    }
  }

  // Guest login
  Future<bool> guestLogin({
    required String displayName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await AuthService.guestLogin(
        displayName: displayName,
      );

      if (result['success']) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: result['user'],
          error: null,
        );
        return true;
      } else {
        _setError(result['message'] ?? 'Guest login failed');
        return false;
      }
    } catch (e) {
      _setError('Guest login failed: ${e.toString()}');
      return false;
    }
  }

  // Resend verification email
  Future<bool> resendVerificationEmail({
    required String email,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await AuthService.resendVerificationEmail(
        email: email,
      );

      state = state.copyWith(isLoading: false);
      
      if (!result['success']) {
        _setError(result['message'] ?? 'Failed to resend verification email');
      }
      
      return result['success'];
    } catch (e) {
      _setError('Failed to resend verification email: ${e.toString()}');
      return false;
    }
  }

  // Forgot password
  Future<bool> forgotPassword({
    required String email,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await AuthService.forgotPassword(
        email: email,
      );

      state = state.copyWith(isLoading: false);
      
      if (!result['success']) {
        _setError(result['message'] ?? 'Failed to send password reset email');
      }
      
      return result['success'];
    } catch (e) {
      _setError('Failed to send password reset email: ${e.toString()}');
      return false;
    }
  }

  // Reset password
  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await AuthService.resetPassword(
        token: token,
        newPassword: newPassword,
      );

      state = state.copyWith(isLoading: false);
      
      if (!result['success']) {
        _setError(result['message'] ?? 'Password reset failed');
      }
      
      return result['success'];
    } catch (e) {
      _setError('Password reset failed: ${e.toString()}');
      return false;
    }
  }

  // Update profile
  Future<bool> updateProfile({
    String? displayName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await AuthService.updateProfile(
        displayName: displayName,
      );

      if (result['success']) {
        state = state.copyWith(
          isLoading: false,
          user: result['user'],
          error: null,
        );
        return true;
      } else {
        _setError(result['message'] ?? 'Profile update failed');
        return false;
      }
    } catch (e) {
      _setError('Profile update failed: ${e.toString()}');
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await AuthService.logout();
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        user: null,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Logout failed: ${e.toString()}',
      );
    }
  }

  // Refresh authentication state
  Future<void> refresh() async {
    if (!state.isAuthenticated) return;

    try {
      final isValid = await AuthService.verifyToken();
      
      if (isValid) {
        state = state.copyWith(
          user: AuthService.currentUser,
          error: null,
        );
      } else {
        // Token is invalid, logout
        await logout();
      }
    } catch (e) {
      // Don't logout on network errors, just log the error
      // In production, use a proper logging framework
      assert(() {
        print('Auth refresh error: $e');
        return true;
      }());
    }
  }
}

// Provider instances
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

// Convenience providers
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final currentUserProvider = Provider<Map<String, dynamic>?>((ref) {
  return ref.watch(authProvider).user;
});

final isAnonymousProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAnonymous;
});

final isEmailVerifiedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isEmailVerified;
});

final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).error;
});
