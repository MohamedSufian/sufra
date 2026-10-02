import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';

/// Arabic date formats come out in Eastern Arabic digits (١٢٣); the app shows 123 everywhere.
String latinDigits(String s) =>
    s.replaceAllMapped(RegExp('[٠-٩]'), (m) => String.fromCharCode(m[0]!.codeUnitAt(0) - 0x0660 + 0x30));

extension ContextX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  ThemeData get theme => Theme.of(this);
  TextTheme get text => Theme.of(this).textTheme;
  ColorScheme get colors => Theme.of(this).colorScheme;
  SufraColors get sufra => Theme.of(this).extension<SufraColors>()!;
  Locale get locale => Localizations.localeOf(this);
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
