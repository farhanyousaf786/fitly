import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../services/firebase/auth_service.dart';
import '../services/firebase/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final FirestoreService _firestoreService;

  AuthProvider({
    required AuthService authService,
    required FirestoreService firestoreService,
  }) : _authService = authService,
       _firestoreService = firestoreService {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  // State
  UserProfile? _user;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserProfile? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  bool get isGuest => !isAuthenticated;

  // Private methods
  void _onAuthStateChanged(String? userId) {
    if (userId != null) {
      _loadUserProfile(userId);
    } else {
      _user = null;
      notifyListeners();
    }
  }

  Future<void> _loadUserProfile(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      final userProfile = await _firestoreService.getUserProfile(userId);
      _user = userProfile;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load user profile: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Public methods
  Future<bool> signIn(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();

      final userId = await _authService.signIn(email, password);
      return userId != null;
    } catch (e) {
      _setError('Sign in failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String username,
    required String firstName,
    required String lastName,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final userId = await _authService.signUp(email, password);
      if (userId == null) {
        _setError('Failed to create account');
        return false;
      }

      // Create user profile
      final userProfile = UserProfile(
        id: userId,
        email: email,
        username: username,
        firstName: firstName,
        lastName: lastName,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestoreService.createUserProfile(userProfile);
      return true;
    } catch (e) {
      _setError('Sign up failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signOut() async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.signOut();
      return true;
    } catch (e) {
      _setError('Sign out failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _clearError();

      final userId = await _authService.signInWithGoogle();

      // User cancelled the sign-in
      if (userId == null) {
        _setLoading(false);
        return false;
      }

      // Check if user profile exists, if not create one
      try {
        await _firestoreService.getUserProfile(userId);
      } catch (e) {
        // Profile doesn't exist, create a new one
        final currentUser = _authService.currentUser;
        final userProfile = UserProfile(
          id: userId,
          email: currentUser?.email ?? '',
          username: currentUser?.displayName ?? 'User',
          firstName: currentUser?.displayName?.split(' ').first ?? '',
          lastName:
              currentUser?.displayName?.split(' ').skip(1).join(' ') ?? '',
          profileImageUrl: currentUser?.photoURL,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firestoreService.createUserProfile(userProfile);
      }

      return true;
    } catch (e) {
      _setError('Google sign in failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      _setError('Password reset failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateEmail(String newEmail) async {
    if (_user == null) return false;

    try {
      _setLoading(true);
      _clearError();

      await _authService.updateEmail(newEmail);

      // Update user profile
      final updatedProfile = _user!.copyWith(
        email: newEmail,
        updatedAt: DateTime.now(),
      );

      await _firestoreService.updateUserProfile(updatedProfile);
      _user = updatedProfile;
      notifyListeners();

      return true;
    } catch (e) {
      _setError('Email update failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updatePassword(String newPassword) async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.updatePassword(newPassword);
      return true;
    } catch (e) {
      _setError('Password update failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteAccount() async {
    if (_user == null) return false;

    try {
      _setLoading(true);
      _clearError();

      // Delete user profile from Firestore
      await _firestoreService.deleteUserProfile(_user!.id);

      // Delete user from Auth
      await _authService.deleteAccount();

      return true;
    } catch (e) {
      _setError('Account deletion failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> sendEmailVerification() async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.sendEmailVerification();
      return true;
    } catch (e) {
      _setError('Email verification failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> reloadUser() async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.reloadUser();

      if (_user != null) {
        await _loadUserProfile(_user!.id);
      }

      return true;
    } catch (e) {
      _setError('User reload failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _clearError();
  }

  // Check if email is verified
  bool get isEmailVerified {
    return _authService.currentUser?.emailVerified ?? false;
  }

  // Get current user ID
  String? get currentUserId {
    return _authService.currentUser?.uid;
  }

  // Get current user email
  String? get currentUserEmail {
    return _authService.currentUser?.email;
  }
}
