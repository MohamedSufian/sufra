import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/backend/backend.dart';

/// The signed-in user; always null in demo mode.
final authUserProvider = StreamProvider<User?>((ref) async* {
  final db = ref.watch(supabaseProvider);
  if (db == null) {
    yield null;
    return;
  }
  yield db.auth.currentUser;
  yield* db.auth.onAuthStateChange.map((s) => s.session?.user);
});

final currentUserProvider = Provider<User?>(
  (ref) => ref.watch(authUserProvider).value ?? ref.watch(supabaseProvider)?.auth.currentUser,
);

enum AuthOutcome { signedIn, confirmEmail }

/// Why signing in failed, in terms the screen can explain.
enum AuthProblem { invalidCredentials, emailNotConfirmed, userExists, weakPassword, network }

class AuthFailure implements Exception {
  const AuthFailure(this.problem);

  final AuthProblem problem;
}

AuthProblem authProblemFor(AuthException e) => switch (e.code) {
  'invalid_credentials' => AuthProblem.invalidCredentials,
  'email_not_confirmed' => AuthProblem.emailNotConfirmed,
  'user_already_exists' || 'email_exists' => AuthProblem.userExists,
  'weak_password' => AuthProblem.weakPassword,
  _ => AuthProblem.network,
};

class AuthService {
  AuthService(this._db);

  final SupabaseClient _db;

  Future<AuthOutcome> signIn(String email, String password) => _guard(() async {
    await _db.auth.signInWithPassword(email: email.trim(), password: password);
    return AuthOutcome.signedIn;
  });

  /// With "Confirm email" on in Supabase, there's no session until the link is opened.
  Future<AuthOutcome> signUp(String email, String password) => _guard(() async {
    final res = await _db.auth.signUp(email: email.trim(), password: password);
    return res.session == null ? AuthOutcome.confirmEmail : AuthOutcome.signedIn;
  });

  Future<void> signOut() => _db.auth.signOut();

  Future<AuthOutcome> _guard(Future<AuthOutcome> Function() run) async {
    try {
      return await run();
    } on AuthException catch (e) {
      throw AuthFailure(authProblemFor(e));
    } on Object {
      throw const AuthFailure(AuthProblem.network);
    }
  }
}

/// null in demo mode.
final authServiceProvider = Provider<AuthService?>((ref) {
  final db = ref.watch(supabaseProvider);
  return db == null ? null : AuthService(db);
});
