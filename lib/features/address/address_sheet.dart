import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/context_x.dart';
import 'address.dart';
import 'addresses_controller.dart';

IconData addressLabelIcon(AddressLabel label) => switch (label) {
  AddressLabel.home => Icons.home_rounded,
  AddressLabel.work => Icons.work_rounded,
  AddressLabel.other => Icons.place_rounded,
};

String addressLabelText(BuildContext context, AddressLabel label) => switch (label) {
  AddressLabel.home => context.l10n.labelHome,
  AddressLabel.work => context.l10n.labelWork,
  AddressLabel.other => context.l10n.labelOther,
};

/// Opens the map to add (or, with [editing], change) an address. The new address becomes the selected one.
Future<SavedAddress?> pickAddressOnMap(BuildContext context, {SavedAddress? editing}) =>
    context.push<SavedAddress>(AppRoutes.addressPick, extra: editing);

/// Lets the user switch between saved addresses or add one. With none saved, goes straight to the map.
Future<void> showAddressSheet(BuildContext context, WidgetRef ref) async {
  if (ref.read(addressesProvider).addresses.isEmpty) {
    await pickAddressOnMap(context);
    return;
  }
  await showModalBottomSheet<void>(
    context: context,
    // Above the tabs' floating navigation bar, which would otherwise cover the sheet's bottom.
    useRootNavigator: true,
    useSafeArea: true,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: context.colors.surface,
    builder: (_) => const _AddressSheet(),
  );
}

class _AddressSheet extends ConsumerWidget {
  const _AddressSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final book = ref.watch(addressesProvider);
    final selectedId = book.selected?.id;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.myAddresses, style: context.text.titleLarge),
          const SizedBox(height: 12),
          for (final a in book.addresses)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AddressTile(
                address: a,
                selected: a.id == selectedId,
                onTap: () {
                  ref.read(addressesProvider.notifier).select(a.id);
                  Navigator.pop(context);
                },
                onEdit: () {
                  // The sheet's context is gone once it closes; keep the router.
                  final router = GoRouter.of(context);
                  Navigator.pop(context);
                  router.push<SavedAddress>(AppRoutes.addressPick, extra: a);
                },
              ),
            ),
          const SizedBox(height: 4),
          OutlinedButton.icon(
            onPressed: () {
              final router = GoRouter.of(context);
              Navigator.pop(context);
              router.push<SavedAddress>(AppRoutes.addressPick);
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              foregroundColor: context.isDark ? AppColors.darkLink : AppColors.ember,
              side: BorderSide(color: context.sufra.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            icon: const Icon(Icons.add_location_alt_rounded),
            label: Text(l10n.addNewAddress),
          ),
        ],
      ),
    );
  }
}

class AddressTile extends StatelessWidget {
  const AddressTile({super.key, required this.address, this.selected = false, this.onTap, this.onEdit});

  final SavedAddress address;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final a = address;
    return Material(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? AppColors.ember : context.sufra.border, width: selected ? 1.5 : 1),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: context.sufra.softAccent, borderRadius: BorderRadius.circular(14)),
                child: Icon(addressLabelIcon(a.label), color: context.isDark ? AppColors.darkLink : AppColors.ember),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${addressLabelText(context, a.label)} · ${a.area.resolve(context.locale)}',
                      style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [a.landmark, if (a.details.isNotEmpty) a.details].join('، '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodyMedium?.copyWith(color: context.sufra.muted),
                    ),
                  ],
                ),
              ),
              if (onEdit != null)
                IconButton(
                  tooltip: context.l10n.edit,
                  onPressed: onEdit,
                  icon: Icon(Icons.edit_outlined, color: context.sufra.muted),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
