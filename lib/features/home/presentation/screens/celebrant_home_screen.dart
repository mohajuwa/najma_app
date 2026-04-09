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
import '../../../banners/presentation/widgets/banners_carousel.dart';

// فئات التخصص للتصفية (بدون "الكل" — يُضاف ديناميكياً)
const _genreList = [
  'طرب عربي',
  'شعبي',
  'خليجي',
  'كلاسيكي',
  'جاز',
  'روك',
  'هيب هوب',
  'إلكترونيك',
  'فلكلور',
  'ديني',
  'أطفال',
];

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
  // 'all' كمعرّف داخلي مستقل عن اللغة
  String _selectedGenre = 'all';

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
              selectedGenre: _selectedGenre,
              onSearch: (v) => setState(() => _searchQuery = v),
              onGenre: (v) => setState(() => _selectedGenre = v),
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

// ─────────────────────────────── Tab 1: Artists ──────────────────
class _ArtistsTab extends StatelessWidget {
  final TextEditingController searchCtrl;
  final String query;
  final String selectedGenre;
  final ValueChanged<String> onSearch;
  final ValueChanged<String> onGenre;

  const _ArtistsTab({
    required this.searchCtrl,
    required this.query,
    required this.selectedGenre,
    required this.onSearch,
    required this.onGenre,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ShaderMask(
                        shaderCallback: (b) => const LinearGradient(
                          colors: [
                            NajmaColors.goldDim,
                            NajmaColors.goldBright,
                            NajmaColors.gold,
                          ],
                        ).createShader(b),
                        child: const Text(
                          'NAJM',
                          style: TextStyle(
                            fontFamily: 'PlayfairDisplay',
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 9,
                            height: 1.0,
                          ),
                        ),
                      ),
                      const Text(
                        'AL  SAHRA',
                        style: TextStyle(
                          fontFamily: 'PlayfairDisplay',
                          fontSize: 9,
                          fontWeight: FontWeight.w300,
                          color: NajmaColors.goldDim,
                          letterSpacing: 5,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
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
                        borderRadius: BorderRadius.circular(4),
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
          ),

          // ── Ads Banners Carousel ──────────────────────────────
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: BannersCarousel(),
            ),
          ),

          // ── Welcome Banner ────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: _WelcomeBanner(s: s),
            ),
          ),

          // ── Search bar ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: _SearchBar(
                controller: searchCtrl,
                onChanged: onSearch,
                s: s,
              ),
            ),
          ),

          // ── Genre Filter ──────────────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 42,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                // 'all' + قائمة الأنواع
                itemCount: _genreList.length + 1,
                itemBuilder: (_, i) {
                  final isAll = i == 0;
                  final g = isAll ? 'all' : _genreList[i - 1];
                  final label = isAll ? s.allGenres : _genreList[i - 1];
                  final active = g == selectedGenre;
                  return GestureDetector(
                    onTap: () => onGenre(g),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: active ? NajmaColors.gold : NajmaColors.surface,
                        border: Border.all(
                          color: active
                              ? NajmaColors.gold
                              : NajmaColors.goldDim.withOpacity(0.25),
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          label,
                          style:
                              NajmaTextStyles.caption(
                                size: 12,
                                color: active
                                    ? NajmaColors.black
                                    : NajmaColors.textSecond,
                              ).copyWith(
                                fontWeight: active
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                              ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ── Section title ────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  Container(width: 3, height: 18, color: NajmaColors.gold),
                  const SizedBox(width: 10),
                  Text(s.artists, style: NajmaTextStyles.heading(size: 16)),
                ],
              ),
            ),
          ),

          // ── Artists list ─────────────────────────────────────
          BlocBuilder<ArtistsBloc, ArtistsState>(
            builder: (context, state) {
              if (state is ArtistsLoading) {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, __) => Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: NajmaShimmer(height: 96),
                    ),
                    childCount: 5,
                  ),
                );
              }

              if (state is ArtistsError) {
                return SliverFillRemaining(
                  child: _ErrorView(
                    message: state.message,
                    onRetry: () =>
                        context.read<ArtistsBloc>().add(LoadArtistsEvent()),
                  ),
                );
              }

              if (state is ArtistsLoaded) {
                var list = state.artists;

                // تصفية بالبحث
                if (query.isNotEmpty) {
                  final q = query.toLowerCase();
                  list = list
                      .where(
                        (a) =>
                            a.nameAr.contains(query) ||
                            (a.nameEn?.toLowerCase().contains(q) ?? false) ||
                            (a.genre?.contains(query) ?? false),
                      )
                      .toList();
                }

                // تصفية بالتخصص
                if (selectedGenre != 'all') {
                  list = list.where((a) => a.genre == selectedGenre).toList();
                }

                if (list.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.search_off,
                            color: NajmaColors.textDim,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            s.noArtists,
                            style: NajmaTextStyles.body(
                              color: NajmaColors.textDim,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final artist = list[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: NajmaArtistCard(
                          artist: artist,
                          onTap: () async {
                            // انتظر العودة من صفحة الفنان
                            await context.push('/home/artist/${artist.id}');
                            // بعد العودة: حدّث rating هذا الفنان في القائمة بصمت
                            if (ctx.mounted) {
                              ctx.read<ArtistsBloc>().add(
                                SilentRefreshArtistInListEvent(artist.id),
                              );
                            }
                          },
                        ),
                      );
                    },
                    childCount: list.length,
                  ),
                );
              }

              return const SliverToBoxAdapter(child: SizedBox.shrink());
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

// ── Welcome Banner ────────────────────────────────────────────────
class _WelcomeBanner extends StatelessWidget {
  final AppStrings s;
  const _WelcomeBanner({required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [NajmaColors.gold.withOpacity(0.12), NajmaColors.surface],
        ),
        border: Border.all(color: NajmaColors.gold.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.discoverArtists,
                  style: NajmaTextStyles.heading(size: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  s.findPerfectArtist,
                  style: NajmaTextStyles.caption(
                    size: 12,
                    color: NajmaColors.textSecond,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: NajmaColors.gold.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: NajmaColors.gold.withOpacity(0.3),
                width: 0.5,
              ),
            ),
            child: const Center(
              child: Text('🎤', style: TextStyle(fontSize: 22)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Search Bar ───────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final AppStrings s;
  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: NajmaColors.surface,
        border: Border.all(color: NajmaColors.goldDim.withOpacity(0.25)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Icon(Icons.search, color: NajmaColors.goldDim, size: 20),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: NajmaTextStyles.body(size: 14),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: s.searchHint,
                hintStyle: NajmaTextStyles.body(
                  size: 14,
                  color: NajmaColors.textDim,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                controller.clear();
                onChanged('');
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.close, color: NajmaColors.textDim, size: 16),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Error View ───────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, color: NajmaColors.textDim, size: 44),
          const SizedBox(height: 12),
          Text(
            message,
            style: NajmaTextStyles.body(color: NajmaColors.textDim),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: NajmaColors.gold.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                AppStrings.of(context).retry,
                style: NajmaTextStyles.gold(size: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────── Tab 2: Orders ───────────────────
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
                    size: 52,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    s.noOrders,
                    style: NajmaTextStyles.body(
                      size: 14,
                      color: NajmaColors.textDim,
                    ),
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

// ─────────────────────────────── Tab 3: Notifications ────────────
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
                    size: 52,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    s.noNotifications,
                    style: NajmaTextStyles.body(
                      size: 14,
                      color: NajmaColors.textDim,
                    ),
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

// ─────────────────────────────── Tab 4: Profile ──────────────────
class _ProfileTab extends StatelessWidget {
  final AppStrings s;
  const _ProfileTab({required this.s});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _TabHeader(title: s.profile),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                children: [
                  // Profile card
                  GestureDetector(
                    onTap: () => context.push('/home/settings/edit-profile'),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [
                            NajmaColors.gold.withOpacity(0.1),
                            NajmaColors.surface,
                          ],
                        ),
                        border: Border.all(
                          color: NajmaColors.gold.withOpacity(0.2),
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: NajmaColors.surface2,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: NajmaColors.gold.withOpacity(0.4),
                                width: 1.5,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.person_outline,
                                color: NajmaColors.gold,
                                size: 28,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.celebrantRole,
                                  style: NajmaTextStyles.heading(size: 15),
                                ),
                                Text(
                                  s.tapToEdit,
                                  style: NajmaTextStyles.caption(
                                    size: 11,
                                    color: NajmaColors.textSecond,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.edit_outlined,
                            color: NajmaColors.goldDim,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // روابط سريعة
                  _QuickLink(
                    icon: Icons.settings_outlined,
                    label: s.settings,
                    onTap: () => context.push('/home/settings'),
                  ),
                  _QuickLink(
                    icon: Icons.shield_outlined,
                    label: s.privacyPolicy,
                    onTap: () => context.push('/home/settings/privacy'),
                  ),
                  _QuickLink(
                    icon: Icons.article_outlined,
                    label: s.termsConditions,
                    onTap: () => context.push('/home/settings/terms'),
                  ),
                  _QuickLink(
                    icon: Icons.info_outline,
                    label: s.aboutApp,
                    onTap: () => context.push('/home/settings/about'),
                  ),
                  const SizedBox(height: 20),

                  // تسجيل الخروج
                  GestureDetector(
                    onTap: () async {
                      await LocalStorage.clearAll();
                      if (context.mounted) context.go('/splash');
                    },
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: NajmaColors.error.withOpacity(0.4),
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.logout,
                              color: NajmaColors.error,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              s.logout,
                              style: NajmaTextStyles.body(
                                size: 14,
                                color: NajmaColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${s.version} 1.0.0',
                    style: NajmaTextStyles.caption(
                      size: 10,
                      color: NajmaColors.textDim,
                    ),
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

class _QuickLink extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickLink({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: NajmaColors.surface,
          border: Border.all(color: NajmaColors.goldDim.withOpacity(0.12)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Icon(icon, color: NajmaColors.gold, size: 20),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: NajmaTextStyles.body(size: 14))),
            const Icon(
              Icons.arrow_forward_ios,
              color: NajmaColors.textDim,
              size: 13,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────── Tab Header ──────────────────────
class _TabHeader extends StatelessWidget {
  final String title;
  const _TabHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: NajmaColors.goldDim.withOpacity(0.15),
            width: 0.5,
          ),
        ),
      ),
      child: Text(title, style: NajmaTextStyles.heading(size: 18)),
    );
  }
}

// ─────────────────────────────── Nav Bar ─────────────────────────
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
    return Container(
      decoration: BoxDecoration(
        color: NajmaColors.surface,
        border: Border(
          top: BorderSide(
            color: NajmaColors.goldDim.withOpacity(0.15),
            width: 0.5,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: index,
        onTap: onTap,
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: NajmaColors.gold,
        unselectedItemColor: NajmaColors.textDim,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.people_outline, size: 22),
            activeIcon: const Icon(Icons.people, size: 22),
            label: s.artists,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.receipt_long_outlined, size: 22),
            activeIcon: const Icon(Icons.receipt_long, size: 22),
            label: s.myOrders,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.notifications_outlined, size: 22),
            activeIcon: const Icon(Icons.notifications, size: 22),
            label: s.notifications,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline, size: 22),
            activeIcon: const Icon(Icons.person, size: 22),
            label: s.profile,
          ),
        ],
      ),
    );
  }
}
