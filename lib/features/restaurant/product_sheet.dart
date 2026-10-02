import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/context_x.dart';
import '../../core/widgets/plate_art.dart';
import '../../core/widgets/quantity_stepper.dart';
import '../cart/add_to_cart.dart';
import '../home/domain/models.dart';

/// Opens the dish details: options, a note for the kitchen and the quantity.
Future<void> showProductSheet(BuildContext context, Product product, {required bool canOrder}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: context.colors.surface,
    clipBehavior: Clip.antiAlias,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (_) => ProductSheet(product: product, canOrder: canOrder),
  );
}

class ProductSheet extends ConsumerStatefulWidget {
  const ProductSheet({super.key, required this.product, required this.canOrder});

  final Product product;

  /// False while the restaurant is closed.
  final bool canOrder;

  @override
  ConsumerState<ProductSheet> createState() => _ProductSheetState();
}

class _ProductSheetState extends ConsumerState<ProductSheet> {
  /// Picked choices per group id, in the order they were picked.
  final _selected = <String, List<OptionChoice>>{};
  final _note = TextEditingController();
  var _quantity = 1;

  Product get _product => widget.product;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  List<OptionChoice> get _choices => [
    for (final g in _product.optionGroups) ...?_selected[g.id],
  ];

  bool get _choicesComplete =>
      _product.optionGroups.every((g) => !g.isRequired || (_selected[g.id]?.isNotEmpty ?? false));

  int get _total => (_product.price + _choices.fold<int>(0, (sum, c) => sum + c.priceDelta)) * _quantity;

  void _toggle(OptionGroup group, OptionChoice choice) {
    HapticFeedback.selectionClick();
    setState(() {
      final picked = _selected[group.id] ?? [];
      if (group.isSingle) {
        _selected[group.id] = [choice];
      } else if (picked.any((c) => c.id == choice.id)) {
        _selected[group.id] = [for (final c in picked) if (c.id != choice.id) c];
      } else if (picked.length < group.maxSelections) {
        _selected[group.id] = [...picked, choice];
      }
    });
  }

  Future<void> _add() async {
    final added = await addToCart(context, ref, _product, choices: _choices, note: _note.text, quantity: _quantity);
    if (!added || !mounted) return;
    // No snackbar: the cart bar updating right below is the confirmation, and a snackbar would cover it.
    HapticFeedback.lightImpact();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = _product;
    final palette = PlatePalette.of(p.artIndex);
    final name = p.name.resolve(context.locale);
    final description = p.description.resolve(context.locale);
    final orderable = widget.canOrder && p.isAvailable;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.92),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 210,
                          color: context.isDark ? palette.backdropDark : palette.backdropLight,
                        ),
                        PlateArt(palette: palette, size: 156)
                            .animate()
                            .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 400.ms, curve: Curves.easeOutBack)
                            .rotate(begin: -0.05, end: 0, duration: 500.ms),
                        Positioned(
                          top: 10,
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: context.colors.onSurface.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        PositionedDirectional(
                          top: 12,
                          end: 12,
                          child: IconButton(
                            tooltip: l10n.close,
                            onPressed: () => Navigator.pop(context),
                            style: IconButton.styleFrom(
                              fixedSize: const Size(44, 44),
                              backgroundColor: context.colors.surface,
                              foregroundColor: context.colors.onSurface,
                            ),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(name, style: context.text.headlineSmall?.copyWith(fontSize: 22))),
                              if (p.isPopular) _PopularBadge(label: l10n.popular),
                            ],
                          ),
                          if (description.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              description,
                              style: context.text.bodyLarge?.copyWith(color: context.sufra.muted, height: 1.5),
                            ),
                          ],
                          const SizedBox(height: 10),
                          Text(
                            l10n.price(p.price),
                            style: context.text.titleLarge?.copyWith(color: context.isDark ? AppColors.darkLink : AppColors.ember),
                          ),
                        ],
                      ),
                    ),
                    for (final g in p.optionGroups)
                      _GroupSection(
                        group: g,
                        picked: _selected[g.id] ?? const [],
                        onToggle: (c) => _toggle(g, c),
                      ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.noteTitle, style: context.text.titleMedium),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _note,
                            maxLength: 120,
                            maxLines: 2,
                            minLines: 1,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              hintText: l10n.noteHint,
                              prefixIcon: const Icon(Icons.edit_note_rounded),
                              fillColor: context.theme.scaffoldBackgroundColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _BottomBar(
              quantity: _quantity,
              itemName: name,
              onIncrement: orderable ? () => setState(() => _quantity++) : null,
              onDecrement: _quantity > 1 ? () => setState(() => _quantity--) : null,
              label: !widget.canOrder
                  ? l10n.restaurantClosed
                  : !p.isAvailable
                      ? l10n.soldOut
                      : _choicesComplete
                          ? l10n.addToCartPrice(_total)
                          : l10n.completeChoices,
              onPressed: orderable && _choicesComplete ? _add : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupSection extends StatelessWidget {
  const _GroupSection({required this.group, required this.picked, required this.onToggle});

  final OptionGroup group;
  final List<OptionChoice> picked;
  final ValueChanged<OptionChoice> onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final satisfied = picked.isNotEmpty;
    final full = !group.isSingle && picked.length >= group.maxSelections;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: context.sufra.border, width: 6))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(group.name.resolve(context.locale), style: context.text.titleMedium),
                    Text(
                      group.isSingle ? l10n.pickOne : l10n.pickUpTo(group.maxSelections),
                      style: context.text.bodySmall?.copyWith(color: context.sufra.muted),
                    ),
                  ],
                ),
              ),
              _RequirementBadge(required: group.isRequired, satisfied: satisfied),
            ],
          ),
          const SizedBox(height: 6),
          for (final c in group.choices)
            _ChoiceTile(
              choice: c,
              single: group.isSingle,
              selected: picked.any((p) => p.id == c.id),
              enabled: !full || picked.any((p) => p.id == c.id),
              onTap: () => onToggle(c),
            ),
        ],
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.choice,
    required this.single,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final OptionChoice choice;
  final bool single;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = context.isDark ? AppColors.coral : AppColors.ember;
    final indicator = AnimatedContainer(
      duration: 180.ms,
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: single ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: single ? null : BorderRadius.circular(7),
        color: selected && !single ? accent : Colors.transparent,
        border: Border.all(color: selected ? accent : context.sufra.muted, width: 2),
      ),
      alignment: Alignment.center,
      child: !selected
          ? null
          : single
              ? Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                )
              : const Icon(Icons.check_rounded, size: 16, color: Colors.white),
    );

    return MergeSemantics(
      child: Semantics(
        checked: selected,
        inMutuallyExclusiveGroup: single,
        enabled: enabled,
        child: Opacity(
          opacity: enabled ? 1 : 0.45,
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(14),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Row(
                children: [
                  indicator,
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      choice.name.resolve(context.locale),
                      style: context.text.bodyLarge?.copyWith(fontWeight: selected ? FontWeight.w700 : FontWeight.w500),
                    ),
                  ),
                  if (choice.priceDelta > 0)
                    Text(
                      context.l10n.priceDelta(choice.priceDelta),
                      style: context.text.bodyMedium?.copyWith(color: context.sufra.muted, fontWeight: FontWeight.w600),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RequirementBadge extends StatelessWidget {
  const _RequirementBadge({required this.required, required this.satisfied});

  final bool required;
  final bool satisfied;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (label, background, foreground) = switch ((required, satisfied)) {
      (true, true) => (l10n.done, AppColors.mint, AppColors.onMint),
      (true, false) => (l10n.required, context.sufra.softAccent, context.colors.onPrimaryContainer),
      _ => (l10n.optional, context.theme.scaffoldBackgroundColor, context.sufra.muted),
    };
    return AnimatedContainer(
      duration: 200.ms,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (required && satisfied) ...[
            Icon(Icons.check_rounded, size: 14, color: foreground),
            const SizedBox(width: 4),
          ],
          Text(label, style: context.text.labelMedium?.copyWith(color: foreground, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _PopularBadge extends StatelessWidget {
  const _PopularBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: context.sufra.softAccent, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department_rounded, size: 14, color: AppColors.coral),
          const SizedBox(width: 4),
          Text(
            label,
            style: context.text.labelMedium?.copyWith(color: context.colors.onPrimaryContainer, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.quantity,
    required this.itemName,
    required this.label,
    this.onIncrement,
    this.onDecrement,
    this.onPressed,
  });

  final int quantity;
  final String itemName;
  final String label;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.paddingOf(context).bottom),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(top: BorderSide(color: context.sufra.border)),
      ),
      child: Row(
        children: [
          QuantityStepper(
            quantity: quantity,
            itemName: itemName,
            onIncrement: onIncrement,
            onDecrement: onDecrement,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: onPressed,
              child: AnimatedSwitcher(
                duration: 200.ms,
                child: Text(label, key: ValueKey(label), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
