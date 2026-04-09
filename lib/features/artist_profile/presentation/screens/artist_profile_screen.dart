import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/l10n/locale_notifier.dart';
import '../../../../core/widgets/najma_shimmer.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../artists/presentation/bloc/artists_bloc.dart';
import '../../../artists/domain/entities/artist_entity.dart';
import '../../../artists/domain/entities/artist_event_entity.dart';
import '../../../artists/data/datasources/artists_datasource.dart';
import '../../../reviews/presentation/bloc/reviews_bloc.dart';
import '../../../reviews/presentation/bloc/reviews_event.dart';
import '../../../reviews/presentation/bloc/reviews_state.dart';
import '../../../reviews/domain/entities/review_status_entity.dart';
import '../../../reviews/presentation/screens/add_review_screen.dart';
import '../../../reviews/presentation/widgets/star_rating_widget.dart';

// تسميات أنواع الخدمات
const _typeLabels = {
  'setlist':          'قائمة أغاني',
  'normal_greeting':  'تهنئة عادية',
  'special_greeting': 'تهنئة مميزة',
  'vip_greeting':     'تهنئة VIP',
  'booking':          'حجز خاص',
  'custom_song':      'أغنية خاصة',
  'gift_song':        'أغنية هدية',
};

class ArtistProfileScreen extends StatelessWidget {
  final String artistId;
  const ArtistProfileScreen({super.key, required this.artistId});

  @override
  Widget build(BuildContext context) {
    final id = int.parse(artistId);
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ArtistsBloc()..add(LoadArtistDetailEvent(id)),
        ),
        // ReviewsBloc هنا فوق الـ BlocBuilder حتى لا يُعاد إنشاؤه
        // عند كل تحديث صامت لبيانات الفنان
        BlocProvider(
          create: (_) => ReviewsBloc()..add(LoadReviewsEvent(id)),
        ),
      ],
      child: _ArtistProfileBody(artistId: artistId),
    );
  }
}

class _ArtistProfileBody extends StatelessWidget {
  final String artistId;
  const _ArtistProfileBody({required this.artistId});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final dir = LocaleNotifier.instance.textDirection;

    return Directionality(
      textDirection: dir,
      child: Scaffold(
        backgroundColor: NajmaColors.black,
        body: BlocBuilder<ArtistsBloc, ArtistsState>(
          builder: (context, state) {
            if (state is ArtistsLoading) return _Skeleton();
            if (state is ArtistsError) {
              return SafeArea(
                child: Column(
                  children: [
                    _BackButton(),
                    Expanded(
                      child: Center(
                        child: Text(
                          state.message,
                          style: NajmaTextStyles.body(
                            color: NajmaColors.textDim,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            if (state is ArtistDetailLoaded) {
              return _Content(artist: state.artist, s: s);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────── Content (Tabbed) ─────────────────
class _Content extends StatefulWidget {
  final ArtistEntity artist;
  final AppStrings s;
  const _Content({required this.artist, required this.s});

  @override
  State<_Content> createState() => _ContentState();
}

class _ContentState extends State<_Content>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final a = widget.artist;
    return NestedScrollView(
      headerSliverBuilder: (context, _) => [
        // ── Hero ──────────────────────────────────────────────────
        SliverAppBar(
          expandedHeight: 260,
          pinned: true,
          backgroundColor: NajmaColors.black,
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                a.avatar != null
                    ? CachedNetworkImage(
                        imageUrl: a.avatar!,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) =>
                            Container(color: NajmaColors.surface2),
                      )
                    : _HeroFallback(name: a.nameAr),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x44000000), NajmaColors.black],
                      stops: [0.4, 1.0],
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(children: [_BackButton()]),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Info Header (name + rating + location) ─────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a.nameAr,
                              style: NajmaTextStyles.display(size: 24)),
                          if (a.nameEn != null)
                            Text(a.nameEn!,
                                style: NajmaTextStyles.label()),
                        ],
                      ),
                    ),
                    _AvailBadge(isAvailable: a.isAvailable),
                  ],
                ),
                const SizedBox(height: 8),
                // Genre + Stars + Rating
                Row(children: [
                  if (a.genre != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: NajmaColors.gold.withOpacity(0.1),
                        border: Border.all(
                            color: NajmaColors.gold.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(a.genre!,
                          style: NajmaTextStyles.caption(
                              size: 10, color: NajmaColors.gold)),
                    ),
                    const SizedBox(width: 10),
                  ],
                  ...List.generate(5, (i) => Icon(
                    i < a.rating.floor()
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: NajmaColors.gold, size: 13,
                  )),
                  const SizedBox(width: 5),
                  Text('${a.rating.toStringAsFixed(1)} (${a.reviewsCount})',
                      style: NajmaTextStyles.caption(
                          size: 11, color: NajmaColors.textSecond)),
                ]),
                // الموقع الجغرافي
                if (a.hasLocation) ...[
                  const SizedBox(height: 8),
                  _LocationChip(location: a.location!),
                ],
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),

        // ── TabBar ─────────────────────────────────────────────────
        SliverPersistentHeader(
          pinned: true,
          delegate: _TabBarDelegate(
            TabBar(
              controller: _tab,
              labelColor: NajmaColors.gold,
              unselectedLabelColor: NajmaColors.textDim,
              indicatorColor: NajmaColors.gold,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: NajmaTextStyles.caption(
                  size: 13).copyWith(fontWeight: FontWeight.w700),
              tabs: const [
                Tab(text: 'عن الفنان'),
                Tab(text: 'مواعيد'),
                Tab(text: 'تقييمات'),
              ],
            ),
          ),
        ),
      ],

      // ── Tab Bodies ───────────────────────────────────────────────
      body: TabBarView(
        controller: _tab,
        children: [
          _AboutTab(artist: a),
          _EventsTab(artist: a),
          _ReviewsTab(artist: a),
        ],
      ),
    );
  }
}

// ── TabBar SliverDelegate ─────────────────────────────────────────
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _TabBarDelegate(this.tabBar);

  @override double get minExtent => tabBar.preferredSize.height + 1;
  @override double get maxExtent => tabBar.preferredSize.height + 1;

  @override
  Widget build(_, __, ___) => Container(
    color: NajmaColors.black,
    child: Column(children: [
      tabBar,
      Container(height: 0.5, color: NajmaColors.goldDim.withOpacity(0.2)),
    ]),
  );

  @override
  bool shouldRebuild(_TabBarDelegate old) => tabBar != old.tabBar;
}

// ── Location Chip ─────────────────────────────────────────────────
class _LocationChip extends StatelessWidget {
  final ArtistLocation location;
  const _LocationChip({required this.location});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final url = 'https://maps.google.com/?q=${location.latitude},${location.longitude}';
        launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color:        NajmaColors.surface,
          border:       Border.all(
              color: NajmaColors.goldDim.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.location_on_rounded,
              color: NajmaColors.gold, size: 13),
          const SizedBox(width: 5),
          Text(
            location.label ?? 'الموقع الحالي للفنان',
            style: NajmaTextStyles.caption(
                size: 11, color: NajmaColors.gold),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.open_in_new_rounded,
              color: NajmaColors.textDim, size: 10),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  Tab 1 — عن الفنان  (Bio + Social + Services)
// ══════════════════════════════════════════════════════════════════
class _AboutTab extends StatelessWidget {
  final ArtistEntity artist;
  const _AboutTab({required this.artist});

  @override
  Widget build(BuildContext context) {
    final a = artist;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        if (a.bio != null && a.bio!.isNotEmpty) ...[
          Text(a.bio!,
              style: NajmaTextStyles.body(
                  size: 14, color: NajmaColors.textSecond)),
          const SizedBox(height: 20),
          _GoldDivider(),
          const SizedBox(height: 20),
        ],

        if (a.hasSocial) ...[
          _SocialRow(artist: a),
          const SizedBox(height: 20),
          _GoldDivider(),
          const SizedBox(height: 20),
        ],

        // ── الخدمات ───────────────────────────────────────────────
        Row(children: [
          Container(width: 3, height: 18, color: NajmaColors.gold),
          const SizedBox(width: 10),
          Text('الخدمات المتاحة',
              style: NajmaTextStyles.heading(size: 15)),
          const Spacer(),
          if (a.services.isNotEmpty)
            Text('${a.services.length} خدمة',
                style: NajmaTextStyles.caption(
                    size: 11, color: NajmaColors.textDim)),
        ]),
        const SizedBox(height: 14),
        if (a.services.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: NajmaColors.surface,
              border: Border.all(
                  color: NajmaColors.goldDim.withOpacity(0.15)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text('لا توجد خدمات متاحة حالياً',
                  style: NajmaTextStyles.caption(
                      color: NajmaColors.textDim)),
            ),
          )
        else
          ...a.services.asMap().entries.map(
            (e) => _ServiceCard(
              index:       e.key,
              service:     e.value,
              artistId:    a.id,
              artistName:  a.nameAr,
              isAvailable: a.isAvailable,
            ),
          ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  Tab 2 — مواعيد الفنان  (Upcoming + Past)
// ══════════════════════════════════════════════════════════════════
class _EventsTab extends StatefulWidget {
  final ArtistEntity artist;
  const _EventsTab({required this.artist});

  @override
  State<_EventsTab> createState() => _EventsTabState();
}

class _EventsTabState extends State<_EventsTab>
    with AutomaticKeepAliveClientMixin {
  late Future<List<ArtistEventEntity>> _upcomingFuture;
  late Future<List<ArtistEventEntity>> _pastFuture;
  final _ds = ArtistsDataSource();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _upcomingFuture = _ds.getArtistEvents(
        widget.artist.id, type: 'upcoming');
    _pastFuture     = _ds.getArtistEvents(
        widget.artist.id, type: 'past');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        _EventSection(
            title: 'المواعيد القادمة',
            icon: Icons.event_rounded,
            future: _upcomingFuture,
            emptyMsg: 'لا توجد مواعيد قادمة'),
        const SizedBox(height: 24),
        _GoldDivider(),
        const SizedBox(height: 24),
        _EventSection(
            title: 'الحفلات السابقة',
            icon: Icons.history_rounded,
            future: _pastFuture,
            emptyMsg: 'لا توجد حفلات سابقة'),
      ],
    );
  }
}

class _EventSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Future<List<ArtistEventEntity>> future;
  final String emptyMsg;
  const _EventSection({
    required this.title,
    required this.icon,
    required this.future,
    required this.emptyMsg,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(width: 3, height: 18, color: NajmaColors.gold),
          const SizedBox(width: 10),
          Icon(icon, color: NajmaColors.gold, size: 16),
          const SizedBox(width: 6),
          Text(title, style: NajmaTextStyles.heading(size: 15)),
        ]),
        const SizedBox(height: 14),
        FutureBuilder<List<ArtistEventEntity>>(
          future: future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return Column(children: List.generate(2, (_) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: NajmaShimmer(height: 72),
              )));
            }
            if (snap.hasError) {
              return Text('تعذر التحميل',
                  style: NajmaTextStyles.caption(
                      color: NajmaColors.textDim));
            }
            final events = snap.data ?? [];
            if (events.isEmpty) {
              return _EmptyBox(msg: emptyMsg);
            }
            return Column(children: events
                .map((e) => _EventCard(event: e))
                .toList());
          },
        ),
      ],
    );
  }
}

class _EventCard extends StatelessWidget {
  final ArtistEventEntity event;
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final isUpcoming = event.isUpcoming;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: NajmaColors.surface,
        border: Border.all(
          color: isUpcoming
              ? NajmaColors.gold.withOpacity(0.2)
              : NajmaColors.surface2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        // أيقونة الخدمة
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: NajmaColors.gold.withOpacity(0.08),
            border: Border.all(
                color: NajmaColors.goldDim.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(_categoryIcon(event.serviceCategory),
                style: const TextStyle(fontSize: 20)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(event.serviceName ?? 'حفلة',
                  style: NajmaTextStyles.body(size: 14)),
              if (event.timingDisplay != null)
                Text(event.timingDisplay!,
                    style: NajmaTextStyles.caption(
                        size: 11, color: NajmaColors.textSecond)),
              if (event.occasion != null)
                Text(event.occasion!,
                    style: NajmaTextStyles.caption(
                        size: 10, color: NajmaColors.textDim)),
            ],
          ),
        ),
        _StatusBadge(status: event.status),
      ]),
    );
  }

  String _categoryIcon(String? cat) {
    return switch (cat) {
      'custom_song'  => '🎵',
      'gift_song'    => '🎁',
      'performance'  => '🎤',
      _ => '🎶',
    };
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'confirmed'   => ('مؤكد', NajmaColors.success),
      'in_progress' => ('قيد التنفيذ', NajmaColors.gold),
      'completed'   => ('منتهي', NajmaColors.textDim),
      _ => ('—', NajmaColors.textDim),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label,
          style: NajmaTextStyles.caption(size: 10, color: color)),
    );
  }
}

class _EmptyBox extends StatelessWidget {
  final String msg;
  const _EmptyBox({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NajmaColors.surface,
        border: Border.all(
            color: NajmaColors.goldDim.withOpacity(0.12)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(msg,
            style: NajmaTextStyles.caption(
                color: NajmaColors.textDim)),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  Tab 3 — تقييمات  (Rating Summary + Reviews List + Action)
// ══════════════════════════════════════════════════════════════════
class _ReviewsTab extends StatelessWidget {
  final ArtistEntity artist;
  const _ReviewsTab({required this.artist});

  @override
  Widget build(BuildContext context) {
    return _ReviewsSection(artist: artist);
  }
}

// ── OLD _Content helper (kept for reference — now replaced by tabs)
// The old services section is now in _AboutTab._servicesList
// Keeping _ServiceCard and other helpers intact below.

// Legacy stub removed — services section now lives in _AboutTab.
// ─────────────────────────────────────────────────────────────────
// Below: _ServiceCard still uses _openCheckout which navigates to checkout.
// For custom_song / gift_song, we route to a special form instead.

// Temporary until _ServiceCard is fully updated:
// uses this helper to distinguish service category
bool _isCustomService(Map<String, dynamic> s) {
  final cat = s['service_category']?.toString() ?? 'performance';
  return cat == 'custom_song' || cat == 'gift_song';
}

// ─────────────────────────────────────────────────────────────────
// Below this line: all original helpers (_ServiceCard, _Skeleton, etc.)
// SERVICES from old _Content moved to _AboutTab above.
// The following section keeps the structure intact.
// ─────────────────────────────────────────────────────────────────
// PLACEHOLDER: The old inline services list from _Content (lines 264–314)
// is now inside _AboutTab. The following placeholder ensures compilation.
// Dummy references removed — _AboutTab handles everything.

// ── Gold Divider ──────────────────────────────────────────────────
class _GoldDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.5,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            NajmaColors.gold.withOpacity(0.4),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

// ── Availability Badge ────────────────────────────────────────────
class _AvailBadge extends StatelessWidget {
  final bool isAvailable;
  const _AvailBadge({required this.isAvailable});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isAvailable
            ? NajmaColors.success.withOpacity(0.1)
            : NajmaColors.surface2,
        border: Border.all(
          color: isAvailable
              ? NajmaColors.success.withOpacity(0.4)
              : NajmaColors.textDim.withOpacity(0.2),
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isAvailable ? NajmaColors.success : NajmaColors.textDim,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            isAvailable ? 'متاح' : 'غير متاح',
            style: NajmaTextStyles.caption(
              size: 11,
              color: isAvailable ? NajmaColors.success : NajmaColors.textDim,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ── Hero Fallback ─────────────────────────────────────────────────
class _HeroFallback extends StatelessWidget {
  final String name;
  const _HeroFallback({required this.name});

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0] : '?';
    return Container(
      color: NajmaColors.surface2,
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 80,
            fontWeight: FontWeight.w900,
            color: NajmaColors.goldDim,
          ),
        ),
      ),
    );
  }
}

// ── Back Button ───────────────────────────────────────────────────
class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pop(),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: NajmaColors.black.withOpacity(0.5),
          shape: BoxShape.circle,
          border: Border.all(
            color: NajmaColors.gold.withOpacity(0.4),
            width: 0.5,
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.arrow_back_ios_new,
            color: NajmaColors.gold,
            size: 16,
          ),
        ),
      ),
    );
  }
}

// ── Service Card ──────────────────────────────────────────────────
class _ServiceCard extends StatefulWidget {
  final int index;
  final Map<String, dynamic> service;
  final int artistId;
  final String artistName;
  final bool isAvailable;

  const _ServiceCard({
    required this.index,
    required this.service,
    required this.artistId,
    required this.artistName,
    required this.isAvailable,
  });

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 150),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _openCheckout() {
    if (!widget.isAvailable) return;
    final s    = widget.service;
    final cat  = s['service_category']?.toString() ?? 'performance';
    final sid  = s['id'] ?? widget.index;
    final sName = Uri.encodeComponent(s['name_ar'] ?? '');
    final price = s['price'] ?? 0;
    final aName = Uri.encodeComponent(widget.artistName);

    if (cat == 'custom_song' || cat == 'gift_song') {
      // → شاشة طلب الأغنية الخاصة
      context.push(
        '/home/custom-song-request'
        '?serviceId=$sid'
        '&serviceName=$sName'
        '&category=$cat'
        '&price=$price'
        '&artistName=$aName'
        '&artistId=${widget.artistId}',
      );
    } else {
      // → شاشة الـ checkout العادي
      context.push(
        '/home/checkout'
        '?serviceId=$sid'
        '&serviceName=$sName'
        '&price=$price'
        '&artistName=$aName',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.service;
    final name = s['name_ar'] as String? ?? '—';
    final type = s['type'] as String? ?? '';
    final price = (s['price'] as num?)?.toDouble() ?? 0;
    final typeLabel = _typeLabels[type] ?? type;
    final canBook = widget.isAvailable;

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: canBook ? (_) => _ctrl.forward() : null,
        onTapUp: canBook
            ? (_) {
                _ctrl.reverse();
                _openCheckout();
              }
            : null,
        onTapCancel: canBook ? () => _ctrl.reverse() : null,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: NajmaColors.surface,
            border: Border.all(
              color: canBook
                  ? NajmaColors.goldDim.withOpacity(0.25)
                  : NajmaColors.surface2,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Opacity(
            opacity: canBook ? 1.0 : 0.55,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // أيقونة النوع
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: NajmaColors.gold.withOpacity(0.08),
                      border: Border.all(
                        color: NajmaColors.goldDim.withOpacity(0.25),
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        _typeIcon(type),
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // اسم + نوع
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: NajmaTextStyles.body(size: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (typeLabel.isNotEmpty)
                          Text(
                            typeLabel,
                            style: NajmaTextStyles.caption(
                              size: 10,
                              color: NajmaColors.textSecond,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),

                  // السعر + زر
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (price > 0)
                        Text(
                          '${price.toStringAsFixed(0)} ر.س',
                          style: NajmaTextStyles.body(
                            size: 15,
                            color: NajmaColors.goldBright,
                          ).copyWith(fontWeight: FontWeight.w700),
                        ),
                      const SizedBox(height: 4),
                      if (canBook)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: NajmaColors.gold,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            'احجز',
                            style: NajmaTextStyles.caption(
                              size: 11,
                              color: NajmaColors.black,
                            ).copyWith(fontWeight: FontWeight.w700),
                          ),
                        )
                      else
                        Text(
                          'غير متاح',
                          style: NajmaTextStyles.caption(
                            size: 10,
                            color: NajmaColors.textDim,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _typeIcon(String type) {
    return switch (type) {
      'setlist'          => '🎵',
      'normal_greeting'  => '👋',
      'special_greeting' => '🌟',
      'vip_greeting'     => '👑',
      'booking'          => '📅',
      'custom_song'      => '🎼',
      'gift_song'        => '🎁',
      _ => '🎤',
    };
  }
}

// ── Skeleton ──────────────────────────────────────────────────────
class _Skeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const NajmaShimmer(height: 280, radius: 0),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              NajmaShimmer(height: 32, width: 200),
              const SizedBox(height: 10),
              NajmaShimmer(height: 16, width: 100),
              const SizedBox(height: 20),
              NajmaShimmer(height: 14),
              const SizedBox(height: 8),
              NajmaShimmer(height: 14),
              const SizedBox(height: 20),
              ...List.generate(
                3,
                (_) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: NajmaShimmer(height: 68),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// Social Media — أيقونات فقط (4 في صف) + deep link مع web fallback
// ══════════════════════════════════════════════════════════════════

/// يستخرج username نظيف من أي صيغة (username / @username / URL كاملة)
String _extractUsername(String raw) {
  final s = raw.trim();
  // إذا كان URL → خذ آخر path segment
  if (s.startsWith('http://') || s.startsWith('https://')) {
    final uri = Uri.tryParse(s);
    if (uri != null) {
      final segs = uri.pathSegments.where((x) => x.isNotEmpty).toList();
      // أبعد @ إذا كانت موجودة
      return segs.isNotEmpty ? segs.last.replaceFirst(RegExp(r'^@'), '') : s;
    }
  }
  // اسم مستخدم عادي — أبعد @ فقط
  return s.replaceFirst(RegExp(r'^@'), '');
}

/// يحاول فتح deep link للتطبيق أولاً، ثم الـ web fallback
Future<void> _launchSocial(String appScheme, String webUrl) async {
  // حاول فتح تطبيق المنصة مباشرةً
  final appUri = Uri.tryParse(appScheme);
  if (appUri != null) {
    try {
      final ok = await launchUrl(appUri, mode: LaunchMode.externalApplication);
      if (ok) return;
    } catch (_) {}
  }
  // fallback للمتصفح
  final webUri = Uri.tryParse(webUrl);
  if (webUri != null) {
    await launchUrl(webUri, mode: LaunchMode.externalApplication);
  }
}

class _SocialRow extends StatelessWidget {
  final ArtistEntity artist;
  const _SocialRow({required this.artist});

  @override
  Widget build(BuildContext context) {
    // ابنِ قائمة المنصات المتاحة فقط
    final items = <_SocialIconData>[];

    if (artist.instagram != null) {
      final u = _extractUsername(artist.instagram!);
      items.add(_SocialIconData(
        icon:      FontAwesomeIcons.instagram,
        color:     const Color(0xFFE1306C),
        appLink:   'instagram://user?username=$u',
        webLink:   'https://www.instagram.com/$u',
        tooltip:   '@$u على Instagram',
      ));
    }
    if (artist.snapchat != null) {
      final u = _extractUsername(artist.snapchat!);
      items.add(_SocialIconData(
        icon:      FontAwesomeIcons.snapchat,
        color:     const Color(0xFFFFFC00),
        appLink:   'snapchat://add/$u',
        webLink:   'https://www.snapchat.com/add/$u',
        tooltip:   '@$u على Snapchat',
      ));
    }
    if (artist.twitter != null) {
      final u = _extractUsername(artist.twitter!);
      items.add(_SocialIconData(
        icon:      FontAwesomeIcons.xTwitter,
        color:     const Color(0xFFE7E9EA),
        appLink:   'twitter://user?screen_name=$u',
        webLink:   'https://x.com/$u',
        tooltip:   '@$u على X',
      ));
    }
    if (artist.tiktok != null) {
      final u = _extractUsername(artist.tiktok!);
      items.add(_SocialIconData(
        icon:      FontAwesomeIcons.tiktok,
        color:     const Color(0xFF69C9D0),
        appLink:   'snssdk1233://user/profile/$u',
        webLink:   'https://www.tiktok.com/@$u',
        tooltip:   '@$u على TikTok',
      ));
    }
    if (artist.youtube != null) {
      final raw = artist.youtube!.trim();
      // إذا كان URL كامل استخدمه مباشرة، وإلا ابنِ channel URL
      final webLink = (raw.startsWith('http'))
          ? raw
          : 'https://www.youtube.com/@$raw';
      items.add(_SocialIconData(
        icon:      FontAwesomeIcons.youtube,
        color:     const Color(0xFFFF0000),
        appLink:   'vnd.youtube://$raw',
        webLink:   webLink,
        tooltip:   'قناة YouTube',
      ));
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 3, height: 18, color: NajmaColors.gold),
            const SizedBox(width: 10),
            Text('تابعني على', style: NajmaTextStyles.heading(size: 15)),
          ],
        ),
        const SizedBox(height: 16),
        // شبكة 4 أيقونات في الصف
        Wrap(
          spacing:    16,
          runSpacing: 16,
          children: items.map((d) => _SocialIconBtn(data: d)).toList(),
        ),
      ],
    );
  }
}

class _SocialIconData {
  final IconData icon;
  final Color    color;
  final String   appLink;   // deep link للتطبيق
  final String   webLink;   // fallback للمتصفح
  final String   tooltip;

  const _SocialIconData({
    required this.icon,
    required this.color,
    required this.appLink,
    required this.webLink,
    required this.tooltip,
  });
}

class _SocialIconBtn extends StatefulWidget {
  final _SocialIconData data;
  const _SocialIconBtn({required this.data});

  @override
  State<_SocialIconBtn> createState() => _SocialIconBtnState();
}

class _SocialIconBtnState extends State<_SocialIconBtn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>    _scale;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(
      vsync:           this,
      duration:        const Duration(milliseconds: 70),
      reverseDuration: const Duration(milliseconds: 150),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.88)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    return Tooltip(
      message: d.tooltip,
      child: ScaleTransition(
        scale: _scale,
        child: GestureDetector(
          onTapDown:   (_) => _ctrl.forward(),
          onTapUp:     (_) { _ctrl.reverse(); _launchSocial(d.appLink, d.webLink); },
          onTapCancel: ()  => _ctrl.reverse(),
          child: Container(
            width:  58,
            height: 58,
            decoration: BoxDecoration(
              color:        d.color.withOpacity(0.10),
              border:       Border.all(color: d.color.withOpacity(0.35), width: 1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: FaIcon(d.icon, color: d.color, size: 24),
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// Reviews Section — يستخدم ReviewsBloc من الـ parent (لا يُعيد إنشاءه)
// ══════════════════════════════════════════════════════════════════
class _ReviewsSection extends StatelessWidget {
  final ArtistEntity artist;
  const _ReviewsSection({required this.artist});

  @override
  Widget build(BuildContext context) {
    // ReviewsBloc موجود في الشجرة من ArtistProfileScreen — لا نُنشئه هنا
    return _ReviewsSectionBody(artist: artist);
  }
}

class _ReviewsSectionBody extends StatefulWidget {
  final ArtistEntity artist;
  const _ReviewsSectionBody({required this.artist});
  @override
  State<_ReviewsSectionBody> createState() => _ReviewsSectionBodyState();
}

class _ReviewsSectionBodyState extends State<_ReviewsSectionBody> {
  @override
  void initState() {
    super.initState();
    // جلب حالة التقييم عند فتح الصفحة (فقط إذا كان fan)
    if (LocalStorage.getRole() == 'fan') {
      context.read<ReviewsBloc>().add(
        CheckReviewStatusEvent(widget.artist.id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header + زر التقييم الذكي ─────────────────────────────
        Row(
          children: [
            Container(width: 3, height: 18, color: NajmaColors.gold),
            const SizedBox(width: 10),
            Text('التقييمات', style: NajmaTextStyles.heading(size: 15)),
            const SizedBox(width: 8),
            BlocBuilder<ReviewsBloc, ReviewsState>(
              buildWhen: (_, s) => s is ReviewsLoaded,
              builder: (_, s) {
                final count = s is ReviewsLoaded
                    ? s.reviews.length
                    : widget.artist.reviewsCount;
                return Text(
                  '($count)',
                  style: NajmaTextStyles.caption(
                    size: 12, color: NajmaColors.textDim),
                );
              },
            ),
            const Spacer(),
            if (LocalStorage.getRole() == 'fan')
              _ReviewActionButton(
                artist: widget.artist,
                onReviewDone: _onReviewDone,
              ),
          ],
        ),
        const SizedBox(height: 14),

        // ── ملخص التقييم ─────────────────────────────────────────
        BlocBuilder<ArtistsBloc, ArtistsState>(
          buildWhen: (_, s) => s is ArtistDetailLoaded,
          builder: (_, s) {
            final rating       = s is ArtistDetailLoaded
                ? s.artist.rating       : widget.artist.rating;
            final reviewsCount = s is ArtistDetailLoaded
                ? s.artist.reviewsCount : widget.artist.reviewsCount;
            return _RatingSummary(rating: rating, count: reviewsCount);
          },
        ),
        const SizedBox(height: 16),

        // ── قائمة التقييمات ────────────────────────────────────
        BlocBuilder<ReviewsBloc, ReviewsState>(
          buildWhen: (_, s) => s is ReviewsLoading || s is ReviewsLoaded,
          builder: (_, state) {
            if (state is ReviewsLoading) {
              return Column(
                children: List.generate(2, (_) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: NajmaShimmer(height: 72),
                )),
              );
            }
            if (state is ReviewsLoaded && state.reviews.isNotEmpty) {
              return Column(
                children: state.reviews.take(3)
                    .map((r) => _ReviewCard(review: r)).toList(),
              );
            }
            if (state is ReviewsLoaded && state.reviews.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color:        NajmaColors.surface,
                  border:       Border.all(
                      color: NajmaColors.goldDim.withOpacity(0.12)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'لا توجد تقييمات بعد',
                    style: NajmaTextStyles.caption(
                        color: NajmaColors.textDim),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  void _onReviewDone() {
    context.read<ReviewsBloc>()
      ..add(LoadReviewsEvent(widget.artist.id))
      ..add(CheckReviewStatusEvent(widget.artist.id));
    context.read<ArtistsBloc>()
        .add(RefreshArtistDetailEvent(widget.artist.id));
  }
}

// ── زر التقييم الذكي — يتغير حسب الحالة ────────────────────────
class _ReviewActionButton extends StatelessWidget {
  final ArtistEntity  artist;
  final VoidCallback  onReviewDone;
  const _ReviewActionButton({required this.artist, required this.onReviewDone});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReviewsBloc, ReviewsState>(
      buildWhen: (_, s) => s is ReviewStatusLoaded,
      builder: (ctx, state) {
        // قبل تحميل الـ status — لا نُظهر شيء
        if (state is! ReviewStatusLoaded) return const SizedBox.shrink();

        final st = state.status;

        // ── لا يملك طلباً مكتملاً → لا يقدر يقيّم ────────────────
        if (!st.canReview) {
          return Tooltip(
            message: st.reason ?? 'أكمل طلباً أولاً',
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color:        NajmaColors.surface2,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.lock_outline,
                    color: NajmaColors.textDim, size: 12),
                const SizedBox(width: 4),
                Text('قيّم',
                    style: NajmaTextStyles.caption(
                        size: 11, color: NajmaColors.textDim)),
              ]),
            ),
          );
        }

        // ── قيّم مسبقاً ولا يزال في نافذة التعديل ────────────────
        if (st.hasReviewed && st.canEdit) {
          return _RateBtn(
            label: 'عدّل تقييمك',
            icon:  Icons.edit_outlined,
            onTap: () => _openReviewScreen(ctx),
          );
        }

        // ── قيّم مسبقاً وانتهت نافذة التعديل ─────────────────────
        if (st.hasReviewed && !st.canEdit) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color:        NajmaColors.gold.withOpacity(0.08),
              border:       Border.all(
                  color: NajmaColors.gold.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.star_rounded,
                  color: NajmaColors.gold, size: 12),
              const SizedBox(width: 4),
              Text('تقييمك مسجّل',
                  style: NajmaTextStyles.caption(
                      size: 11, color: NajmaColors.gold)),
            ]),
          );
        }

        // ── لم يقيّم بعد ويمكنه ──────────────────────────────────
        return _RateBtn(
          label: 'قيّم',
          icon:  Icons.star_outline_rounded,
          onTap: () => _openReviewScreen(ctx),
        );
      },
    );
  }

  Future<void> _openReviewScreen(BuildContext context) async {
    final reviewsBloc = context.read<ReviewsBloc>();
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: reviewsBloc,
          child: AddReviewScreen(
            artistId:   artist.id,
            artistName: artist.nameAr,
          ),
        ),
      ),
    );
    if (result == true) onReviewDone();
  }
}

class _RateBtn extends StatelessWidget {
  final String   label;
  final IconData icon;
  final VoidCallback onTap;
  const _RateBtn({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border:       Border.all(color: NajmaColors.gold.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: NajmaColors.gold, size: 14),
          const SizedBox(width: 5),
          Text(label,
              style: NajmaTextStyles.caption(
                  size: 12, color: NajmaColors.gold)),
        ]),
      ),
    );
  }
}

class _RatingSummary extends StatelessWidget {
  final double rating;
  final int    count;
  const _RatingSummary({required this.rating, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NajmaColors.surface,
        border: Border.all(color: NajmaColors.gold.withOpacity(0.15)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // الرقم الكبير
          Column(
            children: [
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: NajmaColors.gold,
                  height: 1.0,
                ),
              ),
              StarRatingWidget(rating: rating, size: 16),
              const SizedBox(height: 4),
              Text(
                '$count تقييم',
                style: NajmaTextStyles.caption(size: 10, color: NajmaColors.textDim),
              ),
            ],
          ),
          const SizedBox(width: 20),
          // شريط المؤشر
          Expanded(
            child: Column(
              children: List.generate(5, (i) {
                final star = 5 - i;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Text('$star', style: NajmaTextStyles.caption(size: 10, color: NajmaColors.textDim)),
                      const SizedBox(width: 4),
                      const Icon(Icons.star_rounded, color: NajmaColors.gold, size: 10),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: count > 0 ? (rating >= star ? 0.7 : 0.1) : 0,
                            backgroundColor: NajmaColors.surface2,
                            color: NajmaColors.gold,
                            minHeight: 4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final dynamic review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: NajmaColors.surface,
        border: Border.all(color: NajmaColors.goldDim.withOpacity(0.12)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: NajmaColors.gold.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    review.userName.isNotEmpty ? review.userName[0] : '؟',
                    style: const TextStyle(
                      color: NajmaColors.gold,
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.userName, style: NajmaTextStyles.body(size: 13)),
                    Text(review.createdAt, style: NajmaTextStyles.caption(size: 10, color: NajmaColors.textDim)),
                  ],
                ),
              ),
              StarRatingWidget(rating: review.rating.toDouble(), size: 14),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.comment!,
              style: NajmaTextStyles.body(size: 13, color: NajmaColors.textSecond),
            ),
          ],
        ],
      ),
    );
  }
}
