import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/providers/infrastructure.dart';
import '../data/auth_api.dart';
import '../domain/auth_models.dart';

/// High-level authentication phase used by the router.
enum SessionStatus {
  initializing,
  unauthenticated,
  needsProfile,
  authenticated,
}

@immutable
class SessionState {
  const SessionState({
    required this.status,
    this.user,
    this.profiles = const [],
    this.activeProfileId,
    this.error,
  });

  const SessionState.initializing() : this(status: SessionStatus.initializing);

  final SessionStatus status;
  final User? user;
  final List<Profile> profiles;
  final String? activeProfileId;
  final String? error;

  Profile? get activeProfile {
    for (final profile in profiles) {
      if (profile.id == activeProfileId) return profile;
    }
    return null;
  }

  SessionState copyWith({
    SessionStatus? status,
    User? user,
    List<Profile>? profiles,
    String? activeProfileId,
    String? error,
    bool clearActiveProfile = false,
  }) {
    return SessionState(
      status: status ?? this.status,
      user: user ?? this.user,
      profiles: profiles ?? this.profiles,
      activeProfileId: clearActiveProfile
          ? null
          : (activeProfileId ?? this.activeProfileId),
      error: error,
    );
  }
}

/// Owns the token pair, account snapshot and profile selection.
///
/// The low-level interceptor rotates tokens on the wire; this controller is the
/// single source of truth for the UI and the router.
class SessionController extends Notifier<SessionState> {
  late final AuthApi _api;

  @override
  SessionState build() {
    _api = ref.read(authApiProvider);
    final sync = ref.read(sessionSyncProvider);
    sync
      ..onExpired = _handleExpired
      ..onSessionRefreshed = _handleRefreshed;
    Future<void>.microtask(_restore);
    return const SessionState.initializing();
  }

  Future<void> _restore() async {
    final store = ref.read(tokenStoreProvider);
    if (!store.hasSession) {
      state = const SessionState(status: SessionStatus.unauthenticated);
      return;
    }
    try {
      final session = await _api.refresh(store.refreshToken!);
      await _applySession(session);
    } on ApiException catch (error) {
      if (error.isUnauthorized) {
        await store.clear();
      }
      state = SessionState(
        status: SessionStatus.unauthenticated,
        error: error.message,
      );
    }
  }

  Future<void> login({required String email, required String password}) async {
    final session = await _api.login(email: email, password: password);
    await _applySession(session);
  }

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final session = await _api.register(
      email: email,
      password: password,
      displayName: displayName,
    );
    await _applySession(session);
  }

  Future<void> selectProfile(String profileId) async {
    final store = ref.read(tokenStoreProvider);
    final refreshToken = store.refreshToken;
    if (refreshToken == null) {
      await logout();
      return;
    }
    final session = await _api.selectProfile(
      profileId: profileId,
      refreshToken: refreshToken,
    );
    await _applySession(session);
  }

  Future<void> logout() async {
    final store = ref.read(tokenStoreProvider);
    final refreshToken = store.refreshToken;
    try {
      if (refreshToken != null) await _api.logout(refreshToken);
    } on ApiException {
      // Logging out must always succeed locally.
    }
    await store.clear();
    state = const SessionState(status: SessionStatus.unauthenticated);
  }

  /// Re-reads the account snapshot after profile mutations or settings changes.
  Future<void> refreshAccount() async {
    try {
      final snapshot = await _api.me();
      final active = _activeProfile(
        snapshot.profiles,
        snapshot.activeProfileId,
      );
      state = SessionState(
        status: active == null
            ? SessionStatus.needsProfile
            : SessionStatus.authenticated,
        user: snapshot.user,
        profiles: snapshot.profiles,
        activeProfileId: active?.id,
      );
    } on ApiException catch (error) {
      if (error.isUnauthorized) await _handleExpired();
    }
  }

  Future<void> _applySession(AuthSession session) async {
    await ref
        .read(tokenStoreProvider)
        .save(
          accessToken: session.accessToken,
          refreshToken: session.refreshToken,
        );
    final active = _activeProfile(session.profiles, session.activeProfileId);
    state = SessionState(
      status: active == null
          ? SessionStatus.needsProfile
          : SessionStatus.authenticated,
      user: session.user,
      profiles: session.profiles,
      activeProfileId: active?.id,
    );
  }

  void _handleRefreshed(Map<String, dynamic> json) {
    try {
      final session = AuthSession.fromJson(json);
      unawaited(_applySession(session));
    } on Object {
      unawaited(_handleExpired());
    }
  }

  Future<void> _handleExpired() async {
    await ref.read(tokenStoreProvider).clear();
    state = const SessionState(
      status: SessionStatus.unauthenticated,
      error: 'Your session has expired. Please sign in again.',
    );
  }

  Profile? _activeProfile(List<Profile> profiles, String? activeId) {
    if (activeId == null) return null;
    for (final profile in profiles) {
      if (profile.id == activeId) return profile;
    }
    return null;
  }
}

final sessionControllerProvider =
    NotifierProvider<SessionController, SessionState>(SessionController.new);
