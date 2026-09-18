import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  final FirebaseAnalytics? _analyticsInstance;

  AnalyticsService({FirebaseAnalytics? analytics})
      : _analyticsInstance = analytics;

  FirebaseAnalytics? get _analytics {
    if (_analyticsInstance != null) return _analyticsInstance;
    try {
      return FirebaseAnalytics.instance;
    } catch (_) {
      return null;
    }
  }

  FirebaseAnalyticsObserver? getAnalyticsObserver() {
    final analytics = _analytics;
    return analytics != null ? FirebaseAnalyticsObserver(analytics: analytics) : null;
  }

  Future<void> setUserId(String? userId) async {
    try {
      await _analytics?.setUserId(id: userId);
    } catch (e) {
      debugPrint('Analytics setUserId error: $e');
    }
  }

  Future<void> logLogin({String loginMethod = 'email_password'}) async {
    try {
      await _analytics?.logLogin(loginMethod: loginMethod);
    } catch (e) {
      debugPrint('Analytics logLogin error: $e');
    }
  }

  Future<void> logSignUp({String signUpMethod = 'email_password'}) async {
    try {
      await _analytics?.logSignUp(signUpMethod: signUpMethod);
    } catch (e) {
      debugPrint('Analytics logSignUp error: $e');
    }
  }

  Future<void> logNoteCreated({required String category}) async {
    try {
      await _analytics?.logEvent(
        name: 'note_created',
        parameters: {'category': category},
      );
    } catch (e) {
      debugPrint('Analytics logNoteCreated error: $e');
    }
  }

  Future<void> logNoteUpdated({required String category}) async {
    try {
      await _analytics?.logEvent(
        name: 'note_updated',
        parameters: {'category': category},
      );
    } catch (e) {
      debugPrint('Analytics logNoteUpdated error: $e');
    }
  }

  Future<void> logNoteDeleted() async {
    try {
      await _analytics?.logEvent(name: 'note_deleted');
    } catch (e) {
      debugPrint('Analytics logNoteDeleted error: $e');
    }
  }

  Future<void> logFavoriteToggled({required bool isFavorite}) async {
    try {
      await _analytics?.logEvent(
        name: 'note_favorite_toggled',
        parameters: {'is_favorite': isFavorite},
      );
    } catch (e) {
      debugPrint('Analytics logFavoriteToggled error: $e');
    }
  }
}
