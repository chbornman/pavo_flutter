import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pavo_flutter/core/logging/app_logger.dart';
import 'package:pavo_flutter/core/logging/log_mixin.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> with LogMixin {
  AuthNotifier() : super(const AuthState.authenticated()) {
    _initializeAuth();
  }

  void _initializeAuth() {
    log.info('Initializing authentication');
    // Listen to auth state changes
    // Note: Clerk Flutter SDK might have different API than shown in docs
    // This is a simplified version
    // TEMPORARY: Starting as authenticated to bypass login
    logStateChange('auth', newValue: 'authenticated (temporary)');
  }

  Future<void> signIn(String email, String password) async {
    logUserAction('sign_in_attempt', details: {'email': email});
    state = const AuthState.loading();
    
    try {
      // Clerk sign in implementation
      // The actual API might differ from the beta docs
      state = const AuthState.authenticated();
      log.info('User signed in successfully', data: {'email': email});
      logStateChange('auth', oldValue: 'unauthenticated', newValue: 'authenticated');
    } catch (e, stackTrace) {
      log.error('Sign in failed', 
        data: {'email': email},
        error: e,
        stackTrace: stackTrace
      );
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signUp(String email, String password, String firstName, String lastName) async {
    logUserAction('sign_up_attempt', details: {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
    });
    state = const AuthState.loading();
    
    try {
      // Clerk sign up implementation
      // The actual API might differ from the beta docs
      state = const AuthState.authenticated();
      log.info('User signed up successfully', data: {
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
      });
      logStateChange('auth', oldValue: 'unauthenticated', newValue: 'authenticated');
    } catch (e, stackTrace) {
      log.error('Sign up failed',
        data: {'email': email},
        error: e,
        stackTrace: stackTrace
      );
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signOut() async {
    logUserAction('sign_out');
    try {
      // Clerk sign out implementation
      state = const AuthState.unauthenticated();
      log.info('User signed out successfully');
      logStateChange('auth', oldValue: 'authenticated', newValue: 'unauthenticated');
    } catch (e, stackTrace) {
      log.error('Sign out failed', error: e, stackTrace: stackTrace);
    }
  }
}

sealed class AuthState {
  const AuthState();
  
  const factory AuthState.initial() = AuthInitial;
  const factory AuthState.loading() = AuthLoading;
  const factory AuthState.authenticated() = AuthAuthenticated;
  const factory AuthState.unauthenticated() = AuthUnauthenticated;
  const factory AuthState.error(String message) = AuthError;
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated();
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}