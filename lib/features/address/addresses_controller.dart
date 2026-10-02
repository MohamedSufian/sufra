import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/backend/backend.dart';
import '../../core/settings/settings_controller.dart';
import '../auth/auth.dart';
import 'address.dart';

@immutable
class AddressBook {
  const AddressBook({this.addresses = const [], this.selectedId});

  final List<SavedAddress> addresses;
  final String? selectedId;

  /// The address orders go to; the first one when the selection was deleted.
  SavedAddress? get selected =>
      addresses.where((a) => a.id == selectedId).firstOrNull ?? addresses.firstOrNull;
}

/// Kept on the device, and in the account once signed in. The device copy shows instantly and
/// works offline; signing in merges it with the account's.
class AddressesController extends Notifier<AddressBook> {
  static const _key = 'addresses.v1';

  SupabaseClient? get _remote => ref.read(currentUserProvider) == null ? null : ref.read(supabaseProvider);

  @override
  AddressBook build() {
    final signedIn = ref.watch(currentUserProvider) != null;
    final local = _readCache();
    final db = ref.watch(supabaseProvider);
    if (signedIn && db != null) Future.microtask(() => _pull(db, local));
    return local;
  }

  AddressBook _readCache() {
    final raw = ref.read(sharedPreferencesProvider).getString(_key);
    if (raw == null) return const AddressBook();
    try {
      final json = jsonDecode(raw) as Map<String, Object?>;
      return AddressBook(
        selectedId: json['selectedId'] as String?,
        addresses: [
          for (final a in (json['addresses']! as List).cast<Map>()) SavedAddress.fromJson(a.cast<String, Object?>()),
        ],
      );
    } on Object {
      return const AddressBook();
    }
  }

  /// Account addresses win; ones only on this device (added before signing in) are uploaded.
  Future<void> _pull(SupabaseClient db, AddressBook local) async {
    try {
      final rows = await db.from('addresses').select().order('created_at', ascending: true);
      final remote = [for (final r in rows) SavedAddress.fromRow(r)];
      final remoteIds = {for (final a in remote) a.id};
      final deviceOnly = [for (final a in local.addresses) if (!remoteIds.contains(a.id)) a];
      if (deviceOnly.isNotEmpty) await db.from('addresses').upsert([for (final a in deviceOnly) a.toRow()]);
      if (!ref.mounted) return;
      _set(AddressBook(addresses: [...remote, ...deviceOnly], selectedId: state.selectedId));
    } on Object {
      // Offline or server trouble: keep the device copy; the next sign-in or app start syncs again.
    }
  }

  /// Adds a new address or replaces the one with the same id, and selects it.
  void save(SavedAddress address) {
    final exists = state.addresses.any((a) => a.id == address.id);
    _set(AddressBook(
      selectedId: address.id,
      addresses: exists
          ? [for (final a in state.addresses) a.id == address.id ? address : a]
          : [...state.addresses, address],
    ));
    final db = _remote;
    if (db != null) unawaited(_quietly(() => db.from('addresses').upsert(address.toRow())));
  }

  void select(String id) => _set(AddressBook(addresses: state.addresses, selectedId: id));

  void delete(String id) {
    _set(AddressBook(
      addresses: [for (final a in state.addresses) if (a.id != id) a],
      selectedId: state.selectedId == id ? null : state.selectedId,
    ));
    final db = _remote;
    if (db != null) unawaited(_quietly(() => db.from('addresses').delete().eq('id', id)));
  }

  /// On sign-out: this device shouldn't keep someone's addresses.
  void clearLocal() => _set(const AddressBook());

  /// A failed upload leaves the device copy in place; _pull re-uploads it later.
  Future<void> _quietly(Future<Object?> Function() call) async {
    try {
      await call();
    } on Object {
      // See above.
    }
  }

  void _set(AddressBook next) {
    state = next;
    ref.read(sharedPreferencesProvider).setString(_key, jsonEncode({
      'selectedId': next.selectedId,
      'addresses': [for (final a in next.addresses) a.toJson()],
    }));
  }
}

final addressesProvider = NotifierProvider<AddressesController, AddressBook>(AddressesController.new);
