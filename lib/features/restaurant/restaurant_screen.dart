import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/maps/app_map.dart';
import '../../core/maps/gaza_areas.dart';
import '../../core/maps/map_markers.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/context_x.dart';
import '../../core/widgets/plate_art.dart';
import '../../core/widgets/state_views.dart';
import '../cart/cart_bar.dart';
import '../home/domain/models.dart';
import '../home/presentation/home_providers.dart';
import '../home/presentation/widgets/restaurant_card.dart';
import 'restaurant_providers.dart';
import 'widgets/product_tile.dart';

class RestaurantScreen extends ConsumerWidget {
  const RestaurantScreen({super.key, required this.restaurantId});

  final String restaurantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return switch (ref.watch(restaurantByIdProvider(restaurantId))) {
      AsyncData(value: final restaurant?) => _RestaurantView(restaurant: restaurant),
      AsyncLoading() => const Scaffold(body: Center(child: CircularProgressIndicator())),
      // Unknown id or failed load: same way out.
      _ => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: MessageView(
            icon: Icons.storefront_outlined,
            title: l10n.errorTitle,
            body: l10n.errorBody,
            actionLabel: l10n.retry,
            onAction: () => ref.invalidate(restaurantsProvider),
            isError: true,
          ),
        ),
      ),
    };
  }
}

class _RestaurantView extends ConsumerStatefulWidget {
  const _RestaurantView({required this.restaurant});

  final Restaurant restaurant;

  @override
  ConsumerState<_RestaurantView> createState() => _RestaurantViewState();
}

class _RestaurantViewState extends ConsumerState<_RestaurantView> {
  static const _heroHeight = 270.0;
  static const _tabsHeight = 60.0;

  final _scroll = ScrollController();
  final _tabsScroll = ScrollController();
  final _sectionKeys = <String, GlobalKey>{};
  final _chipKeys = <String, GlobalKey>{};
  String? _activeSection;
  var _collapsed = false;
  var _jumping = false;

  /// Height of everything pinned above the menu: status bar, toolbar and section tabs.
  double get _pinnedExtent => MediaQuery.paddingOf(context).top + kToolbarHeight + _tabsHeight;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _tabsScroll.dispose();
    super.dispose();
  }

  double? _sectionTop(String id) {
    final box = _sectionKeys[id]?.currentContext?.findRenderObject() as RenderBox?;
    return box != null && box.attached ? box.localToGlobal(Offset.zero).dy : null;
  }

  void _onScroll() {
    final collapsed = _scroll.offset > _heroHeight - kToolbarHeight - 60;
    // While a tapped tab is scrolling into place, keep that tab selected.
    var active = _activeSection;
    if (!_jumping) {
      active = null;
      for (final id in _sectionKeys.keys) {
        final top = _sectionTop(id);
        if (top != null && top <= _pinnedExtent + 12) active = id;
      }
      // Short last sections can never reach the top; at the very end, they win.
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 4) active = _sectionKeys.keys.lastOrNull;
      active ??= _sectionKeys.keys.firstOrNull;
    }
    if (collapsed != _collapsed || active != _activeSection) {
      if (active != _activeSection) _revealChip(active);
      setState(() {
        _collapsed = collapsed;
        _activeSection = active;
      });
    }
  }

  /// Centers the chip in the tabs row. Scrollable.ensureVisible would also scroll the page itself.
  void _revealChip(String? id) {
    final box = _chipKeys[id]?.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.attached || !_tabsScroll.hasClients) return;
    final center = box.localToGlobal(box.size.center(Offset.zero)).dx;
    var delta = center - MediaQuery.sizeOf(context).width / 2;
    if (Directionality.of(context) == TextDirection.rtl) delta = -delta; // the row scrolls leftwards in RTL
    final position = _tabsScroll.position;
    _tabsScroll.animateTo(
      (position.pixels + delta).clamp(position.minScrollExtent, position.maxScrollExtent),
      duration: 250.ms,
      curve: Curves.easeOut,
    );
  }

  Future<void> _scrollToSection(String id) async {
    final top = _sectionTop(id);
    if (top == null) return;
    final target = (_scroll.offset + top - _pinnedExtent).clamp(0.0, _scroll.position.maxScrollExtent);
    _jumping = true;
    try {
      await _scroll.animateTo(target, duration: 450.ms, curve: Curves.easeInOutCubic);
    } finally {
      _jumping = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.restaurant;
    final l10n = context.l10n;
    final menu = ref.watch(menuProvider(r.id));
    final isFavorite = ref.watch(favoritesProvider.select((f) => f.contains(r.id)));

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: CartBar(restaurantId: r.id),
      body: CustomScrollView(
        controller: _scroll,
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: _heroHeight,
            backgroundColor: context.theme.scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            leadingWidth: 64,
            leading: Center(
              child: _CircleButton(
                icon: Icons.arrow_back_rounded,
                tooltip: l10n.back,
                onPressed: () => context.canPop() ? context.pop() : context.go(AppRoutes.home),
              ),
            ),
            title: AnimatedOpacity(
              opacity: _collapsed ? 1 : 0,
              duration: 200.ms,
              child: Text(r.name.resolve(context.locale), style: context.text.titleLarge?.copyWith(fontSize: 18)),
            ),
            actions: [
              _CircleButton(
                icon: Icons.ios_share_rounded,
                tooltip: l10n.share,
                // WhatsApp and friends; a link can be added once the app has a website or store page.
                onPressed: () => SharePlus.instance.share(ShareParams(
                  text: l10n.shareRestaurant(
                    r.name.resolve(context.locale),
                    r.cuisine.resolve(context.locale),
                    r.area.resolve(context.locale),
                  ),
                )),
              ),
              const SizedBox(width: 8),
              _CircleButton(
                icon: isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                iconColor: isFavorite ? AppColors.ember : null,
                tooltip: isFavorite ? l10n.removeFromFavorites : l10n.addToFavorites,
                onPressed: () => ref.read(favoritesProvider.notifier).toggle(r.id),
              ),
              const SizedBox(width: 12),
            ],
            flexibleSpace: FlexibleSpaceBar(background: _HeroArt(restaurant: r)),
          ),
          // The pinned app bar always paints above later slivers, so the card sits below the hero
          // instead of overlapping it.
          SliverPadding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            sliver: SliverToBoxAdapter(child: _InfoCard(restaurant: r)),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            sliver: SliverToBoxAdapter(child: _LocationCard(restaurant: r)),
          ),
          if (!r.isOpen) SliverToBoxAdapter(child: _ClosedBanner()),
          ...switch (menu) {
            AsyncData(:final value) when value.isEmpty => [
              SliverToBoxAdapter(
                child: MessageView(
                  icon: Icons.menu_book_outlined,
                  title: l10n.menuEmptyTitle,
                  body: l10n.menuEmptyBody,
                ),
              ),
            ],
            AsyncData(:final value) => _menuSlivers(value, r),
            AsyncError() => [
              SliverToBoxAdapter(
                child: MessageView(
                  icon: Icons.wifi_off_rounded,
                  title: l10n.errorTitle,
                  body: l10n.errorBody,
                  actionLabel: l10n.retry,
                  onAction: () => ref.invalidate(menuProvider(r.id)),
                  isError: true,
                ),
              ),
            ],
            _ => [
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList.separated(
                  itemCount: 4,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, _) => const ShimmerBox(height: 112, radius: 22),
                ),
              ),
            ],
          },
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  List<Widget> _menuSlivers(RestaurantMenu menu, Restaurant r) {
    final sections = [
      for (final s in menu.sections)
        if (menu.productsIn(s.id).isNotEmpty) s,
    ];
    for (final s in sections) {
      _sectionKeys.putIfAbsent(s.id, GlobalKey.new);
      _chipKeys.putIfAbsent(s.id, GlobalKey.new);
    }
    final active = _activeSection ?? sections.first.id;

    return [
      SliverPersistentHeader(
        pinned: true,
        delegate: _TabsDelegate(
          height: _tabsHeight,
          child: Container(
            color: context.theme.scaffoldBackgroundColor,
            child: ListView.separated(
              controller: _tabsScroll,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: sections.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) => _SectionChip(
                key: _chipKeys[sections[i].id],
                label: sections[i].name.resolve(context.locale),
                selected: sections[i].id == active,
                onTap: () {
                  setState(() => _activeSection = sections[i].id);
                  _revealChip(sections[i].id);
                  _scrollToSection(sections[i].id);
                },
              ),
            ),
          ),
        ),
      ),
      // Built eagerly (menus are short) so every section can be measured for the tabs.
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final s in sections) ...[
                Padding(
                  key: _sectionKeys[s.id],
                  padding: const EdgeInsets.only(top: 18, bottom: 10),
                  child: Text(s.name.resolve(context.locale), style: context.text.titleLarge?.copyWith(fontSize: 18)),
                ),
                for (final (i, p) in menu.productsIn(s.id).indexed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ProductTile(product: p, canOrder: r.isOpen)
                        .animate()
                        .fadeIn(delay: (40 * i).ms, duration: 300.ms)
                        .slideY(begin: 0.08, end: 0),
                  ),
              ],
            ],
          ),
        ),
      ),
    ];
  }
}

class _HeroArt extends StatelessWidget {
  const _HeroArt({required this.restaurant});

  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    final palette = PlatePalette.of(restaurant.artIndex);
    return Container(
      decoration: BoxDecoration(
        color: context.isDark ? palette.backdropDark : palette.backdropLight,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top + kToolbarHeight - 24, bottom: 16),
        child: Center(
          child: Hero(
            tag: 'plate-${restaurant.id}',
            child: PlateArt(palette: palette, size: 180),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.restaurant});

  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    final r = restaurant;
    final l10n = context.l10n;
    final name = r.name.resolve(context.locale);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(28),
        border: context.isDark ? Border.all(color: context.sufra.border) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDark ? 0.4 : 0.08),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(color: context.sufra.contrastButton, borderRadius: BorderRadius.circular(18)),
                alignment: Alignment.center,
                child: Text(
                  name.characters.first,
                  style: context.text.headlineSmall?.copyWith(color: context.sufra.onContrastButton),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: context.text.titleLarge?.copyWith(fontSize: 20)),
                    const SizedBox(height: 2),
                    Text(
                      '${r.cuisine.resolve(context.locale)} · ${r.area.resolve(context.locale)}',
                      style: context.text.bodyMedium?.copyWith(color: context.sufra.muted),
                    ),
                  ],
                ),
              ),
              StatusBadge(isOpen: r.isOpen),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _Stat(
                value: r.rating.toStringAsFixed(1),
                label: l10n.ratingsCount(r.ratingCount),
                icon: const Icon(Icons.star_rounded, size: 16, color: AppColors.saffron),
              ),
              const SizedBox(width: 8),
              // An ASCII hyphen (unlike an en dash) keeps "25-35" in order inside Arabic text.
              _Stat(value: '${r.deliveryMinMinutes}-${r.deliveryMaxMinutes}', label: l10n.minutesShort),
              const SizedBox(width: 8),
              _Stat(value: l10n.price(r.deliveryFee), label: l10n.deliveryLabel),
              const SizedBox(width: 8),
              _Stat(value: l10n.price(r.minOrder), label: l10n.minOrderLabel),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, this.icon});

  final String value;
  final String label;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: context.theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            FittedBox(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ?icon,
                  Text(value, style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            FittedBox(
              child: Text(label, style: context.text.bodySmall?.copyWith(color: context.sufra.muted)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Where the restaurant is, so people know how far their food travels.
class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.restaurant});

  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    final r = restaurant;
    final area = GazaAreas.nearest(r.latitude, r.longitude)?.name ?? r.area;
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: SizedBox(
        height: 130,
        child: Stack(
          children: [
            Positioned.fill(
              child: AppMap(
                latitude: r.latitude,
                longitude: r.longitude,
                zoom: 15.5,
                interactive: false,
                markers: [AppMapMarker(point: (latitude: r.latitude, longitude: r.longitude), child: const RestaurantMarker())],
              ),
            ),
            PositionedDirectional(
              top: 10,
              start: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(color: context.colors.surface, borderRadius: BorderRadius.circular(999)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on_rounded, size: 16, color: context.isDark ? AppColors.darkLink : AppColors.ember),
                    const SizedBox(width: 4),
                    Text(
                      '${context.l10n.restaurantLocation} · ${area.resolve(context.locale)}',
                      style: context.text.labelMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClosedBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: context.sufra.softAccent, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          Icon(Icons.schedule_rounded, color: context.colors.onPrimaryContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.l10n.closedBanner,
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionChip extends StatelessWidget {
  const _SectionChip({super.key, required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: 220.ms,
      decoration: BoxDecoration(
        color: selected ? context.sufra.contrastButton : context.colors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: selected ? context.sufra.contrastButton : context.sufra.border),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                label,
                style: context.text.labelLarge?.copyWith(
                  color: selected ? context.sufra.onContrastButton : context.colors.onSurface,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.tooltip, required this.onPressed, this.iconColor});

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        fixedSize: const Size(44, 44),
        backgroundColor: context.colors.surface,
        foregroundColor: iconColor ?? context.colors.onSurface,
      ),
      icon: Icon(icon, size: 22),
    );
  }
}

class _TabsDelegate extends SliverPersistentHeaderDelegate {
  _TabsDelegate({required this.height, required this.child});

  final double height;
  final Widget child;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => child;

  @override
  bool shouldRebuild(_TabsDelegate oldDelegate) => true;
}
