import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/l10n/locale_notifier.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/widgets/najma_shimmer.dart';
import '../bloc/dashboard_bloc.dart';
import '../../../notifications/presentation/bloc/notifications_bloc.dart';

class ArtistDashboardScreen extends StatelessWidget {
  const ArtistDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => DashboardBloc()..add(LoadDashboardEvent())),
        BlocProvider(create: (_) => NotificationsBloc()..add(LoadNotificationsEvent())),
      ],
      child: const _DashboardBody(),
    );
  }
}

class _DashboardBody extends StatefulWidget {
  const _DashboardBody();
  @override
  State<_DashboardBody> createState() => _DashboardBodyState();
}

class _DashboardBodyState extends State<_DashboardBody> {
  int _navIndex = 0;
  Timer? _autoRefresh;

  @override
  void initState() {
    super.initState();
    // Auto-refresh كل 30 ثانية
    _autoRefresh = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) context.read<DashboardBloc>().add(RefreshDashboardEvent());
    });
  }

  @override
  void dispose() {
    _autoRefresh?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s   = AppStrings.of(context);
    final dir = LocaleNotifier.instance.textDirection;

    return Directionality(
      textDirection: dir,
      child: Scaffold(
        backgroundColor: NajmaColors.black,
        body: IndexedStack(
          index: _navIndex,
          children: [
            _OverviewTab(s: s),
            _OrdersTab(s: s),
            _NotificationsTab(s: s),
            _ProfileTab(s: s),
          ],
        ),
        bottomNavigationBar: _DashNavBar(
          index: _navIndex,
          onTap: (i) => setState(() => _navIndex = i),
          s: s,
        ),
      ),
    );
  }
}

// ── Tab 1: Overview ───────────────────────────────────────────────
class _OverviewTab extends StatelessWidget {
  final AppStrings s;
  const _OverviewTab({required this.s});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        color: NajmaColors.gold,
        backgroundColor: NajmaColors.surface,
        onRefresh: () async {
          context.read<DashboardBloc>().add(RefreshDashboardEvent());
          await context.read<DashboardBloc>().stream.firstWhere(
            (s) => s is DashboardLoaded || s is DashboardError,
          );
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: _DashboardHeader(s: s),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: BlocBuilder<DashboardBloc, DashboardState>(
                  builder: (_, state) {
                    if (state is DashboardLoading) return _StatsGridSkeleton();
                    if (state is DashboardLoaded)  return _StatsGrid(stats: state.stats);
                    return _StatsGrid(stats: const {});
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                child: BlocBuilder<DashboardBloc, DashboardState>(
                  builder: (_, state) {
                    if (state is DashboardLoaded && state.liveOrders.isNotEmpty) {
                      return _LiveOrdersSection(orders: state.liveOrders);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: _QuickActions(s: s),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  final AppStrings s;
  const _DashboardHeader({required this.s});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(s.artistDashboard, style: NajmaTextStyles.display(size: 22)),
        Text('ARTIST PANEL', style: NajmaTextStyles.label()),
      ]),
      const Spacer(),
      BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (ctx, state) {
          final unread = state is NotificationsLoaded ? state.unreadCount : 0;
          return GestureDetector(
            onTap: () => ctx.push('/artist-dashboard/notifications'),
            child: Stack(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: NajmaColors.surface,
                  border: Border.all(color: NajmaColors.goldDim.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.notifications_outlined,
                    color: NajmaColors.gold, size: 20),
              ),
              if (unread > 0)
                Positioned(top: 4, left: 4, child: Container(
                  width: 14, height: 14,
                  decoration: const BoxDecoration(
                      color: NajmaColors.error, shape: BoxShape.circle),
                  child: Center(child: Text('$unread',
                      style: const TextStyle(color: Colors.white,
                          fontSize: 8, fontWeight: FontWeight.w700))),
                )),
            ]),
          );
        },
      ),
    ]);
  }
}

class _StatsGrid extends StatelessWidget {
  final Map<String, dynamic> stats;
  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    final todayOrders   = stats['today_orders']   ?? 0;
    final monthEarned   = stats['month_earned']   ?? 0.0;
    final pendingOrders = stats['pending_orders'] ?? 0;
    final totalEarned   = stats['total_earned']   ?? 0.0;

    return Column(children: [
      Row(children: [
        _StatCard(value: '$todayOrders',           label: 'طلبات اليوم',    icon: Icons.calendar_today),
        const SizedBox(width: 12),
        _StatCard(value: '${(monthEarned as num).toStringAsFixed(0)} ر.س', label: 'أرباح الشهر',  icon: Icons.account_balance_wallet_outlined),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        _StatCard(value: '$pendingOrders',         label: 'بانتظار القبول', icon: Icons.hourglass_empty),
        const SizedBox(width: 12),
        _StatCard(value: '${(totalEarned as num).toStringAsFixed(0)} ر.س',  label: 'إجمالي الأرباح', icon: Icons.star_outline),
      ]),
    ]);
  }
}

class _StatsGridSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        Expanded(child: NajmaShimmer(height: 90)),
        const SizedBox(width: 12),
        Expanded(child: NajmaShimmer(height: 90)),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: NajmaShimmer(height: 90)),
        const SizedBox(width: 12),
        Expanded(child: NajmaShimmer(height: 90)),
      ]),
    ]);
  }
}

class _StatCard extends StatelessWidget {
  final String value, label;
  final IconData icon;
  const _StatCard({required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: NajmaColors.surface,
          border: Border.all(color: NajmaColors.goldDim.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: NajmaColors.goldDim, size: 18),
          const SizedBox(height: 10),
          Text(value, style: NajmaTextStyles.heading(size: 18, color: NajmaColors.goldBright)),
          const SizedBox(height: 4),
          Text(label, style: NajmaTextStyles.caption(), overflow: TextOverflow.ellipsis),
        ]),
      ),
    );
  }
}

class _LiveOrdersSection extends StatelessWidget {
  final List<dynamic> orders;
  const _LiveOrdersSection({required this.orders});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(width: 3, height: 18, color: NajmaColors.gold),
        const SizedBox(width: 8),
        Text('طلبات حية (${orders.length})', style: NajmaTextStyles.heading(size: 15)),
        const Spacer(),
        Container(
          width: 8, height: 8,
          decoration: const BoxDecoration(color: Color(0xFF4CAF50), shape: BoxShape.circle),
        ),
      ]),
      const SizedBox(height: 12),
      ...orders.take(3).map((o) => _LiveOrderCard(order: o as Map<String, dynamic>)),
    ]);
  }
}

class _LiveOrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  const _LiveOrderCard({required this.order});

  static const _statusLabels = {
    'pending'   : 'انتظار',
    'paid'      : 'مدفوع',
    'accepted'  : 'مقبول',
    'performing': 'جاري',
  };

  static Color _statusColor(String s) => switch (s) {
    'paid'       => NajmaColors.goldBright,
    'accepted'   => const Color(0xFF4CAF50),
    'performing' => NajmaColors.gold,
    _            => NajmaColors.textSecond,
  };

  @override
  Widget build(BuildContext context) {
    final status = order['status'] as String? ?? 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: NajmaColors.surface,
        border: Border.all(color: NajmaColors.goldDim.withOpacity(0.15)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _statusColor(status).withOpacity(0.1),
            border: Border.all(color: _statusColor(status).withOpacity(0.4)),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(_statusLabels[status] ?? status,
              style: NajmaTextStyles.caption(size: 10, color: _statusColor(status))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(order['fan_name'] ?? '—', style: NajmaTextStyles.body(size: 13)),
          Text(order['service']?['name_ar'] ?? '—',
              style: NajmaTextStyles.caption(size: 11)),
        ])),
        Text('${order['amount']} ر.س',
            style: NajmaTextStyles.body(size: 13, color: NajmaColors.goldBright)),
      ]),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final AppStrings s;
  const _QuickActions({required this.s});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(width: 3, height: 18, color: NajmaColors.gold),
        const SizedBox(width: 8),
        Text('إجراءات سريعة', style: NajmaTextStyles.heading(size: 15)),
      ]),
      const SizedBox(height: 14),
      _ActionTile(
        icon: Icons.playlist_add,
        label: s.myServices,
        onTap: () => context.push('/artist-dashboard/services'),
      ),
      const SizedBox(height: 10),
      _ActionTile(
        icon: Icons.share_outlined,
        label: 'روابط السوشيال ميديا',
        onTap: () => context.push('/artist-dashboard/social-links'),
      ),
      const SizedBox(height: 10),
      _ActionTile(
        icon: Icons.location_on_rounded,
        label: 'مشاركة موقعي',
        onTap: () => context.push('/artist-dashboard/location'),
      ),
      const SizedBox(height: 10),
      BlocBuilder<DashboardBloc, DashboardState>(
        builder: (ctx, state) {
          // استخرج القيمة من الـ state المناسب
          bool isAvailable = false;
          bool isUpdating  = false;
          if (state is DashboardLoaded) {
            isAvailable = state.isAvailable;
          } else if (state is AvailabilityUpdating) {
            isAvailable = state.isAvailable;
            isUpdating  = true;
          }

          return _ActionTile(
            icon: isAvailable ? Icons.toggle_on : Icons.toggle_off_outlined,
            label: isUpdating
                ? 'جارٍ التحديث...'
                : (isAvailable ? 'متاح الآن' : 'غير متاح'),
            trailing: Switch(
              value: isAvailable,
              onChanged: isUpdating
                  ? null
                  : (val) => ctx.read<DashboardBloc>()
                        .add(ToggleAvailabilityEvent(val)),
              activeColor: NajmaColors.gold,
              inactiveThumbColor: NajmaColors.textDim,
              inactiveTrackColor: NajmaColors.surface2,
            ),
            onTap: isUpdating
                ? () {}
                : () => ctx.read<DashboardBloc>()
                      .add(ToggleAvailabilityEvent(!isAvailable)),
          );
        },
      ),
    ]);
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;
  const _ActionTile({required this.icon, required this.label, required this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: NajmaColors.surface,
          border: Border.all(color: NajmaColors.goldDim.withOpacity(0.15)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(children: [
          Icon(icon, color: NajmaColors.gold, size: 20),
          const SizedBox(width: 14),
          Text(label, style: NajmaTextStyles.body(size: 14)),
          const Spacer(),
          trailing ?? const Icon(Icons.arrow_forward_ios, color: NajmaColors.goldDim, size: 13),
        ]),
      ),
    );
  }
}

// ── Tab 2: Orders ─────────────────────────────────────────────────
class _OrdersTab extends StatelessWidget {
  final AppStrings s;
  const _OrdersTab({required this.s});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(children: [
        _DashTabHeader(title: s.orders),
        Expanded(
          child: BlocBuilder<DashboardBloc, DashboardState>(
            builder: (ctx, state) {
              if (state is DashboardLoading) {
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: 5,
                  itemBuilder: (_, __) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: NajmaShimmer(height: 80),
                  ),
                );
              }
              if (state is DashboardLoaded && state.liveOrders.isNotEmpty) {
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.liveOrders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _OrderActionCard(
                    order: state.liveOrders[i] as Map<String, dynamic>,
                  ),
                );
              }
              return Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_long_outlined,
                      color: NajmaColors.textDim, size: 48),
                  const SizedBox(height: 12),
                  Text(s.noOrders, style: NajmaTextStyles.body(color: NajmaColors.textDim)),
                ],
              ));
            },
          ),
        ),
      ]),
    );
  }
}

class _OrderActionCard extends StatelessWidget {
  final Map<String, dynamic> order;
  const _OrderActionCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final status    = order['status'] as String? ?? 'pending';
    final orderId   = order['id'] as int? ?? 0;
    final canAccept = status == 'paid';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: NajmaColors.surface,
        border: Border.all(color: NajmaColors.goldDim.withOpacity(0.15)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(order['fan_name'] ?? '—',
              style: NajmaTextStyles.body(size: 14))),
          Text('${order['amount']} ر.س',
              style: NajmaTextStyles.gold(size: 14)),
        ]),
        const SizedBox(height: 6),
        Text(order['service']?['name_ar'] ?? '—',
            style: NajmaTextStyles.caption(size: 12)),
        if (canAccept) ...[
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: GestureDetector(
              onTap: () => context.read<DashboardBloc>().add(
                  UpdateOrderStatusEvent(orderId, 'accepted')),
              child: Container(
                height: 36,
                decoration: BoxDecoration(
                  color: NajmaColors.gold.withOpacity(0.1),
                  border: Border.all(color: NajmaColors.gold.withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(child: Text('قبول',
                    style: NajmaTextStyles.body(size: 13, color: NajmaColors.gold))),
              ),
            )),
            const SizedBox(width: 10),
            Expanded(child: GestureDetector(
              onTap: () => context.read<DashboardBloc>().add(
                  UpdateOrderStatusEvent(orderId, 'rejected')),
              child: Container(
                height: 36,
                decoration: BoxDecoration(
                  border: Border.all(color: NajmaColors.error.withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(child: Text('رفض',
                    style: NajmaTextStyles.body(size: 13, color: NajmaColors.error))),
              ),
            )),
          ]),
        ],
      ]),
    );
  }
}

// ── Tab 3: Notifications ──────────────────────────────────────────
class _NotificationsTab extends StatelessWidget {
  final AppStrings s;
  const _NotificationsTab({required this.s});

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Column(children: [
      _DashTabHeader(title: s.notifications),
      Expanded(
        child: BlocBuilder<NotificationsBloc, NotificationsState>(
          builder: (ctx, state) {
            if (state is NotificationsLoading) {
              return ListView.builder(
                itemCount: 4,
                padding: const EdgeInsets.all(16),
                itemBuilder: (_, __) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: NajmaShimmer(height: 64),
                ),
              );
            }
            if (state is NotificationsLoaded && state.notifications.isNotEmpty) {
              return ListView.separated(
                itemCount: state.notifications.length,
                separatorBuilder: (_, __) =>
                    const Divider(color: Color(0xFF1E1E1E), height: 1),
                itemBuilder: (ctx, i) {
                  final n = state.notifications[i];
                  return ListTile(
                    tileColor: n.isRead
                        ? Colors.transparent
                        : NajmaColors.gold.withOpacity(0.04),
                    leading: Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: n.isRead ? Colors.transparent : NajmaColors.gold,
                      ),
                    ),
                    title: Text(n.title, style: NajmaTextStyles.body(size: 14)),
                    subtitle: Text(n.body, style: NajmaTextStyles.caption()),
                    onTap: () => ctx.read<NotificationsBloc>().add(MarkReadEvent(n.id)),
                  );
                },
              );
            }
            return Center(child: Text(s.noNotifications,
                style: NajmaTextStyles.body(color: NajmaColors.textDim)));
          },
        ),
      ),
    ]));
  }
}

// ── Tab 4: Profile ────────────────────────────────────────────────
class _ProfileTab extends StatelessWidget {
  final AppStrings s;
  const _ProfileTab({required this.s});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(children: [
        _DashTabHeader(title: s.profile),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // ── بطاقة الملف الشخصي ─────────────────────────────
              GestureDetector(
                onTap: () => context.push('/artist-dashboard/settings/edit-profile'),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        NajmaColors.gold.withOpacity(0.12),
                        NajmaColors.surface,
                      ],
                    ),
                    border: Border.all(color: NajmaColors.gold.withOpacity(0.25)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        color: NajmaColors.surface2,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: NajmaColors.gold.withOpacity(0.4), width: 1.5),
                      ),
                      child: const Center(
                        child: Icon(Icons.person_outline,
                            color: NajmaColors.gold, size: 30),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(s.artistProfile,
                            style: NajmaTextStyles.heading(size: 15)),
                        const SizedBox(height: 3),
                        Text(s.tapToEdit,
                            style: NajmaTextStyles.caption(
                                size: 12, color: NajmaColors.textSecond)),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: NajmaColors.gold.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(s.artistRole,
                              style: NajmaTextStyles.caption(
                                      size: 10, color: NajmaColors.gold)
                                  .copyWith(fontWeight: FontWeight.w600)),
                        ),
                      ]),
                    ),
                    const Icon(Icons.edit_outlined,
                        color: NajmaColors.goldDim, size: 18),
                  ]),
                ),
              ),

              const SizedBox(height: 28),

              // ── الحساب ──────────────────────────────────────────
              _ProfileSectionLabel(s.accountSection),
              _ProfileTile(
                icon: Icons.settings_outlined,
                label: s.settings,
                onTap: () => context.push('/artist-dashboard/settings'),
              ),
              _ProfileTile(
                icon: Icons.person_outline,
                label: s.editProfile,
                onTap: () =>
                    context.push('/artist-dashboard/settings/edit-profile'),
              ),
              _ProfileTile(
                icon: Icons.language,
                label: s.language,
                onTap: () =>
                    context.push('/artist-dashboard/settings/language'),
              ),

              const SizedBox(height: 8),

              // ── التطبيق ─────────────────────────────────────────
              _ProfileSectionLabel(s.appSection),
              _ProfileTile(
                icon: Icons.shield_outlined,
                label: s.privacyPolicy,
                onTap: () =>
                    context.push('/artist-dashboard/settings/privacy'),
              ),
              _ProfileTile(
                icon: Icons.article_outlined,
                label: s.termsConditions,
                onTap: () =>
                    context.push('/artist-dashboard/settings/terms'),
              ),
              _ProfileTile(
                icon: Icons.info_outline,
                label: s.aboutApp,
                onTap: () =>
                    context.push('/artist-dashboard/settings/about'),
              ),
              _ProfileTile(
                icon: Icons.headset_mic_outlined,
                label: s.contactSupport,
                onTap: () =>
                    context.push('/artist-dashboard/settings/support'),
              ),

              const SizedBox(height: 24),

              // ── تسجيل الخروج ────────────────────────────────────
              GestureDetector(
                onTap: () async {
                  await LocalStorage.clearAll();
                  if (context.mounted) context.go('/splash');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: NajmaColors.error.withOpacity(0.4)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    const Icon(Icons.logout,
                        color: NajmaColors.error, size: 18),
                    const SizedBox(width: 8),
                    Text(s.logout,
                        style: NajmaTextStyles.body(
                            size: 14, color: NajmaColors.error)),
                  ]),
                ),
              ),

              const SizedBox(height: 20),
              Center(
                child: Text('${s.version} 1.0.0',
                    style: NajmaTextStyles.caption(
                        size: 10, color: NajmaColors.textDim)),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _ProfileSectionLabel extends StatelessWidget {
  final String label;
  const _ProfileSectionLabel(this.label);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
      child: Text(label,
          style: NajmaTextStyles.caption(size: 11, color: NajmaColors.textDim)
              .copyWith(fontWeight: FontWeight.w700, letterSpacing: 1)),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ProfileTile(
      {required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: NajmaColors.surface,
          border:
              Border.all(color: NajmaColors.goldDim.withOpacity(0.12)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(children: [
          Icon(icon, color: NajmaColors.gold, size: 20),
          const SizedBox(width: 14),
          Expanded(
              child: Text(label, style: NajmaTextStyles.body(size: 14))),
          const Icon(Icons.arrow_forward_ios,
              color: NajmaColors.textDim, size: 13),
        ]),
      ),
    );
  }
}

class _DashTabHeader extends StatelessWidget {
  final String title;
  const _DashTabHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: NajmaColors.goldDim.withOpacity(0.2))),
      ),
      child: Row(children: [
        Container(width: 3, height: 20, color: NajmaColors.gold),
        const SizedBox(width: 10),
        Text(title, style: NajmaTextStyles.heading(size: 18)),
      ]),
    );
  }
}

// ── Bottom Nav ────────────────────────────────────────────────────
class _DashNavBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  final AppStrings s;
  const _DashNavBar({required this.index, required this.onTap, required this.s});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.dashboard_outlined, Icons.dashboard,        s.artistDashboard),
      (Icons.receipt_long_outlined, Icons.receipt_long,  s.orders),
      (Icons.notifications_outlined, Icons.notifications, s.notifications),
      (Icons.person_outline, Icons.person,               s.profile),
    ];

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: NajmaColors.surface,
        border: Border(top: BorderSide(color: NajmaColors.goldDim.withOpacity(0.25))),
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final active = index == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(
                  active ? items[i].$2 : items[i].$1,
                  color: active ? NajmaColors.gold : NajmaColors.textDim,
                  size: 22,
                ),
                const SizedBox(height: 3),
                Text(items[i].$3,
                    style: NajmaTextStyles.caption(
                      size: 10,
                      color: active ? NajmaColors.gold : NajmaColors.textDim,
                    )),
                if (active)
                  Container(
                    margin: const EdgeInsets.only(top: 3),
                    width: 16, height: 1.5,
                    color: NajmaColors.gold,
                  ),
              ]),
            ),
          );
        }),
      ),
    );
  }
}
