import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../core/utils/error_mapper.dart';
import '../data/services/analytics_service.dart';
import '../data/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final AnalyticsService _analyticsService;
  StreamSubscription<User?>? _authSubscription;

  User? _user;
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({
    AuthService? authService,
    AnalyticsService? analyticsService,
  })  : _authService = authService ?? AuthService(),
        _analyticsService = analyticsService ?? AnalyticsService() {
    _init();
  }

  void _init() {
    _authSubscription = _authService.authStateChanges.listen((User? user) {
      _user = user;
      _isInitialized = true;
      if (user != null) {
        _analyticsService.setUserId(user.uid);
      }
      notifyListeners();
    }, onError: (dynamic error) {
      _isInitialized = true;
      _errorMessage = ErrorMapper.mapAuthError(error);
      notifyListeners();
    });
  }

  User? get user => _user;
  String? get userId => _user?.uid;
  String? get userEmail => _user?.email;
  bool get isAuthenticated => _user != null;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _authService.signUp(email: email, password: password);
      _user = credential.user;
      await _analyticsService.logSignUp();
      if (_user != null) {
        await _analyticsService.setUserId(_user!.uid);
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = ErrorMapper.mapAuthError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _authService.signIn(email: email, password: password);
      _user = credential.user;
      await _analyticsService.logLogin();
      if (_user != null) {
        await _analyticsService.setUserId(_user!.uid);
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = ErrorMapper.mapAuthError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendPasswordResetEmail({required String email}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.sendPasswordResetEmail(email: email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = ErrorMapper.mapAuthError(e);
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      await _analyticsService.setUserId(null);
    } finally {
      _user = null;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
