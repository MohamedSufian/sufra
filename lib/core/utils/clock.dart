import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Ticks every second while a screen watches it, so time-based UI (order progress) stays current.
final clockProvider = StreamProvider.autoDispose<DateTime>(
  (ref) => Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
);

extension ClockX on AsyncValue<DateTime> {
  DateTime get now => value ?? DateTime.now();
}
