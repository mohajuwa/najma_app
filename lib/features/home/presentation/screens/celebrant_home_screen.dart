import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/l10n/locale_notifier.dart';
import '../../../../core/widgets/najma_shimmer.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../artists/presentation/bloc/artists_bloc.dart';
import '../../../artists/presentation/widgets/artist_card.dart';

class CelebrantHomeScreen extends StatelessWidget {
  const CelebrantHomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ArtistsBloc()..add(LoadArtistsEvent()),
      child: const _HomeBody(),
    );
  }
}

class _HomeBody extends StatefulWidget {
  const _HomeBody();
  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> {
  int _navIndex = 0;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final dir = LocaleNotifier.instance.textDirection;

    return Directionality(
      textDirection: dir,
      child: Scaffold(
        backgroundColor: NajmaColors.black,
        body: IndexedStack(
          index: _navIndex,
          children: [
            _ArtistsTab(
              searchCtrl: _searchCtrl,
              query: _searchQuery,
              onSearch: (v) => setState(() => _searchQuery = v),
            ),
            _OrdersTab(s: s),
            _NotificationsTab(s: s),
            _ProfileTab(s: s),
          ],
        ),
        bottomNavigationBar: _NajmaNavBar(
          index: _navIndex,
          onTap: (i) => setState(() => _navIndex = i),
          s: s,
        ),
      ),
    );
  }
}

// ── Tab 1: Artists ───────────────────────────────────────────────
class _ArtistsTab extends StatelessWidget {
  final TextEditingController searchCtrl;
  final String query;
  final ValueChanged<String> onSearch;
  const _ArtistsTab({
    required this.searchCtrl,
    required this.query,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return SafeArea(
      child: Column(
        children: [
          // ── Top bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                // Logo
                ShaderMask(
                  shaderCallback: (b) => const LinearGradient(
                    colors: [
                      NajmaColors.goldDim,
                      NajmaColors.gold,
                      NajmaColors.goldBright,
                    ],
                  ).createShader(b),
                  child: const Text(
                    'NAJMA',
                    style: TextStyle(
                      fontFamily: 'PlayfairDisplay',
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 4,
                    ),
                  ),
                ),
                const Spacer(),
                // Notifications
                GestureDetector(
                  onTap: () => context.push('/home/notifications'),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: NajmaColors.surface,
                      border: Border.all(
                        color: NajmaColors.goldDim.withOpacity(0.3),
                      ),
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: NajmaColors.gold,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: NajmaColors.surface,
                border: Border.all(color: NajmaColors.goldDim.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Icon(
                      Icons.search,
                      color: NajmaColors.goldDim,
                      size: 20,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: searchCtrl,
                      onChanged: onSearch,
                      style: NajmaTextStyles.body(size: 14),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: s.search,
                        hintStyle: NajmaTextStyles.body(
                          size: 14,
                          color: NajmaColors.textDim,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Section title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(width: 3, height: 18, color: NajmaColors.gold),
                const SizedBox(width: 10),
                Text(s.artists, style: NajmaTextStyles.heading(size: 16)),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Artists list
          Expanded(
            child: BlocBuilder<ArtistsBloc, ArtistsState>(
              builder: (context, state) {
                if (state is ArtistsLoading) return _buildShimmer();
                if (state is ArtistsError)
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.wifi_off,
                          color: NajmaColors.textDim,
                          size: 40,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          state.message,
                          style: NajmaTextStyles.body(
                            color: NajmaColors.textDim,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => context.read<ArtistsBloc>().add(
                            LoadArtistsEvent(),
                          ),
                          child: Text(
                            AppStrings.of(context).retry,
                            style: NajmaTextStyles.gold(),
                          ),
                        ),
                      ],
                    ),
                  );
                if (state is ArtistsLoaded) {
                  final filtered = query.isEmpty
                      ? state.artists
                      : state.artists
                            .where(
                              (a) =>
                                  a.nameAr.contains(query) ||
                                  (a.nameEn?.toLowerCase().contains(
                                        query.toLowerCase(),
                                      ) ??
                                      false),
                            )
                            .toList();
                  if (filtered.isEmpty)
                    return Center(
                      child: Text(
                        s.noArtists,
                        style: NajmaTextStyles.body(color: NajmaColors.textDim),
                      ),
                    );
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => NajmaArtistCard(
                      artist: filtered[i],
                      onTap: () =>
                          context.push('/home/artist/${filtered[i].id}'),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 5,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: NajmaShimmer(height: 90),
      ),
    );
  }
}

// ── Tab 2: Orders placeholder ────────────────────────────────────
class _OrdersTab extends StatelessWidget {
  final AppStrings s;
  const _OrdersTab({required this.s});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _TabHeader(title: s.myOrders),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.receipt_long_outlined,
                    color: NajmaColors.textDim,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    s.noOrders,
                    style: NajmaTextStyles.body(color: NajmaColors.textDim),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tab 3: Notifications placeholder ────────────────────────────
class _NotificationsTab extends StatelessWidget {
  final AppStrings s;
  const _NotificationsTab({required this.s});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _TabHeader(title: s.notifications),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.notifications_none,
                    color: NajmaColors.textDim,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    s.noNotifications,
                    style: NajmaTextStyles.body(color: NajmaColors.textDim),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tab 4: Profile ───────────────────────────────────────────────
class _ProfileTab extends StatelessWidget {
  final AppStrings s;
  const _ProfileTab({required this.s});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _TabHeader(title: s.profile),
          const SizedBox(height: 40),
          const Icon(Icons.person_outline, color: NajmaColors.gold, size: 64),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: GestureDetector(
              onTap: () async {
                await LocalStorage.clearAll();
                if (context.mounted) context.go('/splash');
              },
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  border: Border.all(color: NajmaColors.error.withOpacity(0.5)),
                ),
                child: Center(
                  child: Text(
                    s.logout,
                    style: NajmaTextStyles.body(
                      size: 15,
                      color: NajmaColors.error,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared: Tab header ───────────────────────────────────────────
class _TabHeader extends StatelessWidget {
  final String title;
  const _TabHeader({required this.title});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: NajmaColors.goldDim.withOpacity(0.2)),
        ),
      ),
      child: Row(
        children: [
          Container(width: 3, height: 20, color: NajmaColors.gold),
          const SizedBox(width: 10),
          Text(title, style: NajmaTextStyles.heading(size: 18)),
        ],
      ),
    );
  }
}

// ── Bottom Nav Bar ───────────────────────────────────────────────
class _NajmaNavBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  final AppStrings s;
  const _NajmaNavBar({
    required this.index,
    required this.onTap,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.home_outlined, Icons.home, s.home),
      (Icons.receipt_long_outlined, Icons.receipt_long, s.myOrders),
      (Icons.notifications_outlined, Icons.notifications, s.notifications),
      (Icons.person_outline, Icons.person, s.profile),
    ];
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: NajmaColors.surface,
        border: Border(
          top: BorderSide(color: NajmaColors.goldDim.withOpacity(0.25)),
        ),
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final active = index == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    active ? items[i].$2 : items[i].$1,
                    color: active ? NajmaColors.gold : NajmaColors.textDim,
                    size: 22,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    items[i].$3,
                    style: NajmaTextStyles.caption(
                      size: 10,
                      color: active ? NajmaColors.gold : NajmaColors.textDim,
                    ),
                  ),
                  if (active)
                    Container(
                      margin: const EdgeInsets.only(top: 3),
                      width: 16,
                      height: 1.5,
                      color: NajmaColors.gold,
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
