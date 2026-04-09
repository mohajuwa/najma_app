import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/l10n/app_strings.dart';
import '../bloc/profile_bloc.dart';

class SettingsScreen extends StatelessWidget {
  final String origin;
  const SettingsScreen({super.key, required this.origin});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileBloc()..add(LoadProfileEvent()),
      child: _SettingsBody(origin: origin),
    );
  }
}

class _SettingsBody extends StatelessWidget {
  final String origin;
  const _SettingsBody({required this.origin});

  String get _prefix => origin == 'artist' ? '/artist-dashboard' : '/home';

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);

    return BlocListener<ProfileBloc, ProfileState>(
      listener: (ctx, state) {
        if (state is AccountDeleted) {
          LocalStorage.clearAll();
          ctx.go('/splash');
        }
        if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message,
                style: NajmaTextStyles.body(size: 13, color: Colors.white),
                textDirection: TextDirection.rtl),
            backgroundColor: NajmaColors.error,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ));
        }
      },
      child: Directionality(
        textDirection: s.isAr ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          backgroundColor: NajmaColors.black,
          body: SafeArea(
            child: Column(children: [

              // ── Header ──────────────────────────────────────────
              _Header(title: s.settings),

              // ── Profile Card ─────────────────────────────────
              BlocBuilder<ProfileBloc, ProfileState>(
                builder: (ctx, state) {
                  final name     = state is ProfileLoaded ? (state.data['name'] as String? ?? '—') : '—';
                  final phone    = state is ProfileLoaded ? (state.data['phone'] as String? ?? '') : '';
                  final isArtist = state is ProfileLoaded && state.data['artist'] != null;
                  return _ProfileCard(
                    name:     name,
                    phone:    phone,
                    isArtist: isArtist,
                    s:        s,
                    onEdit:   () => context.push('$_prefix/settings/edit-profile'),
                  );
                },
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  child: Column(children: [

                    // ── الحساب ─────────────────────────────────
                    _SectionLabel(s.accountSection),
                    _Tile(
                      icon:  Icons.person_outline,
                      label: s.editProfile,
                      onTap: () => context.push('$_prefix/settings/edit-profile'),
                    ),
                    _Tile(
                      icon:    Icons.language,
                      label:   s.language,
                      trailing: Text(
                        LocalStorage.getLang() == 'en' ? '🇬🇧  English' : '🇸🇦  العربية',
                        style: NajmaTextStyles.caption(
                            size: 12, color: NajmaColors.textSecond),
                      ),
                      onTap: () => context.push('$_prefix/settings/language'),
                    ),

                    // ── التطبيق ────────────────────────────────
                    _SectionLabel(s.appSection),
                    _Tile(
                      icon:  Icons.shield_outlined,
                      label: s.privacyPolicy,
                      onTap: () => context.push('$_prefix/settings/privacy'),
                    ),
                    _Tile(
                      icon:  Icons.article_outlined,
                      label: s.termsConditions,
                      onTap: () => context.push('$_prefix/settings/terms'),
                    ),
                    _Tile(
                      icon:  Icons.info_outline,
                      label: s.aboutApp,
                      onTap: () => context.push('$_prefix/settings/about'),
                    ),
                    _Tile(
                      icon:  Icons.star_outline,
                      label: s.rateApp,
                      onTap: () {},
                    ),
                    _Tile(
                      icon:  Icons.headset_mic_outlined,
                      label: s.contactSupport,
                      onTap: () => context.push('$_prefix/settings/support'),
                    ),

                    const SizedBox(height: 20),

                    // ── تسجيل الخروج ───────────────────────────
                    _LogoutButton(
                      label: s.logout,
                      onTap: () async {
                        await LocalStorage.clearAll();
                        if (context.mounted) context.go('/splash');
                      },
                    ),

                    const SizedBox(height: 12),

                    // ── حذف الحساب ─────────────────────────────
                    GestureDetector(
                      onTap: () => _confirmDelete(context, s),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(s.deleteAccount,
                            style: NajmaTextStyles.caption(
                                size: 12,
                                color: NajmaColors.error.withOpacity(0.6))),
                      ),
                    ),

                    const SizedBox(height: 20),
                    Text('${s.version} 1.0.0',
                        style: NajmaTextStyles.caption(
                            size: 10, color: NajmaColors.textDim)),
                  ]),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppStrings s) {
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: s.isAr ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          backgroundColor: NajmaColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: Text(s.deleteAccountTitle, style: NajmaTextStyles.heading(size: 16)),
          content: Text(s.deleteAccountMsg,
              style: NajmaTextStyles.body(size: 13, color: NajmaColors.textSecond)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(s.cancel, style: NajmaTextStyles.gold()),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<ProfileBloc>().add(DeleteAccountEvent());
              },
              child: Text(s.deleteAccount,
                  style: NajmaTextStyles.body(size: 14, color: NajmaColors.error)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────── Widgets ─────────────────────────

class _Header extends StatelessWidget {
  final String title;
  const _Header({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(color: NajmaColors.goldDim.withOpacity(0.15))),
      ),
      child: Row(children: [
        GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: NajmaColors.surface,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: NajmaColors.goldDim.withOpacity(0.2)),
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                color: NajmaColors.gold, size: 16),
          ),
        ),
        const SizedBox(width: 14),
        Text(title, style: NajmaTextStyles.heading(size: 18)),
      ]),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String name, phone;
  final bool isArtist;
  final AppStrings s;
  final VoidCallback onEdit;

  const _ProfileCard({
    required this.name,
    required this.phone,
    required this.isArtist,
    required this.s,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onEdit,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              NajmaColors.gold.withOpacity(0.14),
              NajmaColors.surface,
            ],
          ),
          border: Border.all(color: NajmaColors.gold.withOpacity(0.25)),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: NajmaColors.gold.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(children: [
          // Avatar
          Container(
            width: 58, height: 58,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  NajmaColors.gold.withOpacity(0.2),
                  NajmaColors.surface2,
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                  color: NajmaColors.gold.withOpacity(0.5), width: 1.5),
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: NajmaTextStyles.heading(size: 22, color: NajmaColors.gold),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: NajmaTextStyles.heading(size: 16)),
              if (phone.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(phone,
                    style: NajmaTextStyles.caption(
                        size: 12, color: NajmaColors.textSecond)),
              ],
              const SizedBox(height: 6),
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: NajmaColors.gold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: NajmaColors.gold.withOpacity(0.3)),
                  ),
                  child: Text(
                    isArtist ? s.artistRole : s.celebrantRole,
                    style: NajmaTextStyles.caption(size: 10, color: NajmaColors.gold)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ]),
            ]),
          ),
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: NajmaColors.gold.withOpacity(0.08),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.edit_outlined,
                color: NajmaColors.gold, size: 16),
          ),
        ]),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 10),
      child: Row(children: [
        Container(width: 3, height: 12, color: NajmaColors.gold),
        const SizedBox(width: 8),
        Text(label,
            style: NajmaTextStyles.caption(size: 11, color: NajmaColors.goldDim)
                .copyWith(fontWeight: FontWeight.w800, letterSpacing: 0.5)),
      ]),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback onTap;

  const _Tile({
    required this.icon,
    required this.label,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: NajmaColors.surface,
          border: Border.all(color: NajmaColors.goldDim.withOpacity(0.14)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: NajmaColors.gold.withOpacity(0.07),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(icon, color: NajmaColors.gold, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(label,
              style: NajmaTextStyles.body(size: 14))),
          trailing ??
              const Icon(Icons.arrow_forward_ios,
                  color: NajmaColors.textDim, size: 13),
        ]),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _LogoutButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: NajmaColors.error.withOpacity(0.05),
          border: Border.all(color: NajmaColors.error.withOpacity(0.35)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.logout, color: NajmaColors.error, size: 18),
          const SizedBox(width: 10),
          Text(label,
              style: NajmaTextStyles.body(size: 14, color: NajmaColors.error)),
        ]),
      ),
    );
  }
}
