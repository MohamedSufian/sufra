import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase settings come from the build, never from source:
///   flutter run --dart-define-from-file=supabase.json
/// Without them the app runs on its built-in sample data (demo mode).
abstract final class BackendConfig {
  static const _rawUrl = String.fromEnvironment('SUPABASE_URL');
  static const key = String.fromEnvironment('SUPABASE_KEY');

  /// The project origin. The dashboard also shows endpoint URLs like ".../rest/v1/"; those get trimmed.
  static String get url => normalizeUrl(_rawUrl);

  static String normalizeUrl(String raw) {
    final uri = Uri.tryParse(raw.trim());
    return uri == null || !uri.hasScheme ? raw.trim() : uri.origin;
  }

  static bool get isConfigured => url.isNotEmpty && key.isNotEmpty;
}

Future<void> initBackend() async {
  if (!BackendConfig.isConfigured) return;
  // Takes a new "sb_publishable_…" key or an older "anon" JWT; both are public client keys.
  await Supabase.initialize(url: BackendConfig.url, publishableKey: BackendConfig.key);
}

/// null in demo mode.
final supabaseProvider = Provider<SupabaseClient?>(
  (ref) => BackendConfig.isConfigured ? Supabase.instance.client : null,
);
