import 'package:material_ui/material_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/backend/backend.dart';
import 'core/settings/settings_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Fonts ship inside the app (assets/google_fonts); never fetch them at runtime.
  GoogleFonts.config.allowRuntimeFetching = false;
  LicenseRegistry.addLicense(() async* {
    for (final (family, file) in [('Alexandria', 'OFL-Alexandria.txt'), ('IBM Plex Sans Arabic', 'OFL-IBMPlexSansArabic.txt')]) {
      yield LicenseEntryWithLineBreaks([family], await rootBundle.loadString('assets/google_fonts/$file'));
    }
  });
  final prefs = await SharedPreferences.getInstance();
  await initBackend();
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const SufraApp(),
    ),
  );
}
