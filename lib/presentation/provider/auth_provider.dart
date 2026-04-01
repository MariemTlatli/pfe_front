import 'package:flutter/material.dart';
import '../../core/errors/exceptions.dart';

import '../../data/repositories/auth_repository.dart';
import 'localization_provider.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository authRepository;
  final LocalizationProvider localizationProvider;

  bool _isLoading = false;
  String? _errorMessage;
  String? _userId;
  String? _username;
  String? _email;
  bool _isLoggedIn = false;

  AuthProvider({
    required this.authRepository,
    required this.localizationProvider,
  });

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get userId => _userId;
  String? get username => _username;
  String? get email => _email;
  bool get isLoggedIn => _isLoggedIn;

  /// Initialize authentication state
  Future<void> initializeAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      _isLoggedIn = await authRepository.isLoggedIn();
      if (_isLoggedIn) {
        final userData = await authRepository.getUserData();
        _userId = userData['userId'];
        _username = userData['username'];
        _email = userData['email'];
      }
    } catch (e) {
      print('[AuthProvider] Error during initialization: $e');
      _isLoggedIn = false;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Register user
  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Validation
      final validationError = _validateRegisterInput(username, email, password);

      if (validationError != null) {
        _errorMessage = validationError;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final response = await authRepository.register(
        username: username,
        email: email,
        password: password,
      );

      _userId = response.user.userId;
      _username = response.user.username;
      _email = response.user.email;
      _isLoggedIn = true;

      _isLoading = false;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = localizationProvider.locale.unknownError;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Login user
  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Validation
      final validationError = _validateLoginInput(email, password);

      if (validationError != null) {
        _errorMessage = validationError;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final response = await authRepository.login(
        email: email,
        password: password,
      );

      _userId = response.user.userId;
      _username = response.user.username;
      _email = response.user.email;
      _isLoggedIn = true;

      _isLoading = false;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = localizationProvider.locale.unknownError;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await authRepository.logout();
    } catch (e) {
      print('[AuthProvider] Error during logout: $e');
    } finally {
      _isLoggedIn = false;
      _userId = null;
      _username = null;
      _email = null;
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Validation methods
  String? _validateLoginInput(String email, String password) {
    if (email.isEmpty) {
      return localizationProvider.locale.emailRequired;
    }

    if (!_isValidEmail(email)) {
      return localizationProvider.locale.emailInvalid;
    }

    if (password.isEmpty) {
      return localizationProvider.locale.passwordRequired;
    }

    return null;
  }

  String? _validateRegisterInput(
    String username,
    String email,
    String password,
  ) {
    if (username.isEmpty) {
      return localizationProvider.locale.usernameRequired;
    }

    if (username.length < 3) {
      return localizationProvider.locale.usernameTooShort;
    }

    if (email.isEmpty) {
      return localizationProvider.locale.emailRequired;
    }

    if (!_isValidEmail(email)) {
      return localizationProvider.locale.emailInvalid;
    }

    if (password.isEmpty) {
      return localizationProvider.locale.passwordRequired;
    }

    if (password.length < 6) {
      return localizationProvider.locale.passwordTooShort;
    }

    return null;
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
