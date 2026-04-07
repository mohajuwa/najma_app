import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/l10n/locale_notifier.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/widgets/najma_shimmer.dart';
import '../../../notifications/presentation/bloc/notifications_bloc.dart';

class ArtistDashboardScreen extends StatelessWidget {
  const ArtistDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationsBloc()..add(LoadNotificationsEvent()),
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

// ── Tab 1: Overview ──────────────────────────────────────────────
class _OverviewTab extends StatelessWidget {
  final AppStrings s;
  const _OverviewTab({required this.s});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.artistDashboard,
                      style: NajmaTextStyles.display(size: 22),
                    ),
                    Text('ARTIST PANEL', style: NajmaTextStyles.label()),
                  ],
                ),
                const Spacer(),
                // Notifications badge
                BlocBuilder<NotificationsBloc, NotificationsState>(
                  builder: (context, state) {
                    final unread = state is NotificationsLoaded
                        ? state.unreadCount
                        : 0;
                    return GestureDetector(
                      onTap: () =>
                          context.push('/artist-dashboard/notifications'),
                      child: Stack(
                        children: [
                          Container(
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
                          if (unread > 0)
                            Positioned(
                              top: 4,
                              left: 4,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: const BoxDecoration(
                                  color: NajmaColors.error,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '$unread',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Stats cards
            Row(
              children: [
                _StatCard(
                  value: '0',
                  label: s.todayBookings,
                  icon: Icons.calendar_today,
                ),
                const SizedBox(width: 12),
                _StatCard(
                  value: '0 ر.س',
                  label: s.earnings,
                  icon: Icons.account_balance_wallet_outlined,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatCard(
                  value: '0',
                  label: s.myOrders,
                  icon: Icons.receipt_long_outlined,
                ),
                const SizedBox(width: 12),
                _StatCard(
                  value: '—',
                  label: s.rating,
                  icon: Icons.star_outline,
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Quick actions
            Container(width: 3, height: 18, color: NajmaColors.gold),
            const SizedBox(height: 4),
            Text('إجراءات سريعة', style: NajmaTextStyles.heading(size: 15)),
            const SizedBox(height: 14),
            _QuickAction(
              icon: Icons.playlist_add,
              label: s.myServices,
              onTap: () {},
            ),
            const SizedBox(height: 10),
            _QuickAction(
              icon: Icons.toggle_on_outlined,
              label: '${s.available} / ${s.unavailable}',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value, label;
  final IconData icon;
  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: NajmaColors.surface,
          border: Border.all(color: NajmaColors.goldDim.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: NajmaColors.goldDim, size: 18),
            const SizedBox(height: 10),
            Text(
              value,
              style: NajmaTextStyles.heading(
                size: 20,
                color: NajmaColors.goldBright,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: NajmaTextStyles.caption()),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: NajmaColors.surface,
          border: Border.all(color: NajmaColors.goldDim.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Icon(icon, color: NajmaColors.gold, size: 20),
            const SizedBox(width: 14),
            Text(label, style: NajmaTextStyles.body(size: 14)),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              color: NajmaColors.goldDim,
              size: 13,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tab 2: Orders ────────────────────────────────────────────────
class _OrdersTab extends StatelessWidget {
  final AppStrings s;
  const _OrdersTab({required this.s});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _DashTabHeader(title: s.orders),
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

// ── Tab 3: Notifications ─────────────────────────────────────────
class _NotificationsTab extends StatelessWidget {
  final AppStrings s;
  const _NotificationsTab({required this.s});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _DashTabHeader(title: s.notifications),
          Expanded(
            child: BlocBuilder<NotificationsBloc, NotificationsState>(
              builder: (context, state) {
                if (state is NotificationsLoading)
                  return ListView.builder(
                    itemCount: 4,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (_, __) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: NajmaShimmer(height: 64),
                    ),
                  );
                if (state is NotificationsLoaded &&
                    state.notifications.isNotEmpty)
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
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: n.isRead
                                ? Colors.transparent
                                : NajmaColors.gold,
                          ),
                        ),
                        title: Text(
                          n.title,
                          style: NajmaTextStyles.body(size: 14),
                        ),
                        subtitle: Text(
                          n.body,
                          style: NajmaTextStyles.caption(),
                        ),
                        onTap: () => context.read<NotificationsBloc>().add(
                          MarkReadEvent(n.id),
                        ),
                      );
                    },
                  );
                return Center(
                  child: Text(
                    s.noNotifications,
                    style: NajmaTextStyles.body(color: NajmaColors.textDim),
                  ),
                );
              },
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
          _DashTabHeader(title: s.profile),
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

class _DashTabHeader extends StatelessWidget {
  final String title;
  const _DashTabHeader({required this.title});
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

// ── Bottom Nav ───────────────────────────────────────────────────
class _DashNavBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  final AppStrings s;
  const _DashNavBar({
    required this.index,
    required this.onTap,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.dashboard_outlined, Icons.dashboard, s.artistDashboard),
      (Icons.receipt_long_outlined, Icons.receipt_long, s.orders),
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
