// lib/features/auth/bloc/login_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ==================== EVENTS ====================
abstract class LoginEvent {}

class LoginSubmittedEvent extends LoginEvent {
  final String email;
  final String password;

  LoginSubmittedEvent({required this.email, required this.password});
}

class RegisterSubmittedEvent extends LoginEvent {
  final String email;
  final String password;
  final String? name;

  RegisterSubmittedEvent({
    required this.email,
    required this.password,
    this.name,
  });
}

class LogoutEvent extends LoginEvent {}

class CheckAuthStatusEvent extends LoginEvent {}

// ==================== STATES ====================
abstract class LoginState {}

class LoginInitialState extends LoginState {}

class LoginLoadingState extends LoginState {}

class LoginSuccessActionState extends LoginState {
  final String userId;
  final String email;
  final bool isNewUser;

  LoginSuccessActionState({
    required this.userId,
    required this.email,
    this.isNewUser = false,
  });
}

class LoginErrorState extends LoginState {
  final String message;

  LoginErrorState({required this.message});
}

class LoggedOutState extends LoginState {}

class AuthenticatedState extends LoginState {
  final String userId;
  final String email;

  AuthenticatedState({required this.userId, required this.email});
}

// ==================== BLOC ====================
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  LoginBloc() : super(LoginInitialState()) {
    on<LoginSubmittedEvent>(_onLoginSubmitted);
    on<RegisterSubmittedEvent>(_onRegisterSubmitted);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
  }

  // ==================== LOGIN ====================
  Future<void> _onLoginSubmitted(
    LoginSubmittedEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoadingState());
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      if (userCredential.user != null) {
        final user = userCredential.user!;

        // Check if email is verified
        if (!user.emailVerified) {
          await _auth.signOut();
          emit(
            LoginErrorState(
              message:
                  'Please verify your email before logging in. Check your inbox.',
            ),
          );
          return;
        }

        emit(
          LoginSuccessActionState(
            userId: user.uid,
            email: user.email ?? '',
            isNewUser: false,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Login failed';

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No account found with this email';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled';
          break;
        case 'invalid-credential':
          errorMessage =
              'Invalid credentials. Please check your email and password';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many failed attempts. Please try again later';
          break;
        default:
          errorMessage = e.message ?? 'An error occurred during login';
      }

      emit(LoginErrorState(message: errorMessage));
    } catch (e) {
      emit(LoginErrorState(message: 'An unexpected error occurred'));
    }
  }

  // ==================== REGISTER ====================
  Future<void> _onRegisterSubmitted(
    RegisterSubmittedEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoadingState());
    try {
      // Create user account
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      if (userCredential.user != null) {
        final user = userCredential.user!;

        // Send email verification
        await user.sendEmailVerification();

        // Store user data in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'name': event.name ?? '',
          'email': event.email,
          'createdAt': FieldValue.serverTimestamp(),
          'emailVerified': false,
          'wishlist': [],
          'cart': [],
        });

        // Update display name if provided
        if (event.name != null && event.name!.isNotEmpty) {
          await user.updateDisplayName(event.name);
        }

        // Sign out user until they verify email
        await _auth.signOut();

        emit(
          LoginSuccessActionState(
            userId: user.uid,
            email: user.email ?? '',
            isNewUser: true,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Registration failed';

      switch (e.code) {
        case 'weak-password':
          errorMessage = 'Password is too weak. Use at least 6 characters';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account already exists with this email';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled';
          break;
        default:
          errorMessage = e.message ?? 'An error occurred during registration';
      }

      emit(LoginErrorState(message: errorMessage));
    } catch (e) {
      emit(LoginErrorState(message: 'An unexpected error occurred'));
    }
  }

  // ==================== LOGOUT ====================
  Future<void> _onLogout(LogoutEvent event, Emitter<LoginState> emit) async {
    try {
      await _auth.signOut();
      emit(LoggedOutState());
    } catch (e) {
      emit(LoginErrorState(message: 'Failed to logout'));
    }
  }

  // ==================== CHECK AUTH STATUS ====================
  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<LoginState> emit,
  ) async {
    final user = _auth.currentUser;

    if (user != null && user.emailVerified) {
      emit(AuthenticatedState(userId: user.uid, email: user.email ?? ''));
    } else {
      emit(LoggedOutState());
    }
  }
}
