import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/l10n/locale_notifier.dart';
import '../../../../core/widgets/najma_shimmer.dart';
import '../../../artists/presentation/bloc/artists_bloc.dart';
import '../../../artists/domain/entities/artist_entity.dart';
import '../../../checkout/presentation/screens/checkout_screen.dart';

class ArtistProfileScreen extends StatelessWidget {
  final String artistId;
  const ArtistProfileScreen({super.key, required this.artistId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ArtistsBloc()..add(LoadArtistDetailEvent(int.parse(artistId))),
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
            if (state is ArtistsLoading) return _buildSkeleton();
            if (state is ArtistsError)
              return SafeArea(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: const Padding(
                        padding: EdgeInsets.all(20),
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: NajmaColors.gold,
                        ),
                      ),
                    ),
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
            if (state is ArtistDetailLoaded)
              return _buildContent(context, state.artist, s);
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ArtistEntity a, AppStrings s) {
    return CustomScrollView(
      slivers: [
        // ── Hero
        SliverAppBar(
          expandedHeight: 260,
          pinned: true,
          backgroundColor: NajmaColors.black,
          leading: GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(Icons.arrow_back_ios, color: NajmaColors.gold),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                a.avatar != null
                    ? CachedNetworkImage(imageUrl: a.avatar!, fit: BoxFit.cover)
                    : Container(
                        color: NajmaColors.surface2,
                        child: const Icon(
                          Icons.person,
                          color: NajmaColors.goldDim,
                          size: 80,
                        ),
                      ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, NajmaColors.black],
                      stops: [0.5, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.nameAr,
                            style: NajmaTextStyles.display(size: 24),
                          ),
                          if (a.nameEn != null)
                            Text(a.nameEn!, style: NajmaTextStyles.label()),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            (a.isAvailable
                                    ? NajmaColors.success
                                    : NajmaColors.surface2)
                                .withOpacity(0.2),
                        border: Border.all(
                          color: a.isAvailable
                              ? NajmaColors.success
                              : NajmaColors.textDim,
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        a.isAvailable ? s.available : s.unavailable,
                        style: NajmaTextStyles.caption(
                          size: 11,
                          color: a.isAvailable
                              ? NajmaColors.success
                              : NajmaColors.textDim,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Rating
                Row(
                  children: [
                    ...List.generate(
                      5,
                      (i) => Icon(
                        i < a.rating.floor() ? Icons.star : Icons.star_border,
                        color: NajmaColors.gold,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${a.rating.toStringAsFixed(1)}  (${a.reviewsCount} ${s.reviews})',
                      style: NajmaTextStyles.caption(
                        size: 12,
                        color: NajmaColors.textSecond,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Divider
                Container(
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
                ),
                const SizedBox(height: 20),

                // Bio
                if (a.bio != null) ...[
                  Text(
                    a.bio!,
                    style: NajmaTextStyles.body(
                      size: 14,
                      color: NajmaColors.textSecond,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Services title
                Row(
                  children: [
                    Container(width: 3, height: 18, color: NajmaColors.gold),
                    const SizedBox(width: 10),
                    Text(
                      'الخدمات المتاحة',
                      style: NajmaTextStyles.heading(size: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Services list — كل خدمة بطاقة قابلة للضغط
                BlocBuilder<ArtistsBloc, ArtistsState>(
                  builder: (context, state) {
                    if (state is! ArtistDetailLoaded) return const SizedBox();
                    // نحتاج full service objects — موجودة في state لكن entity بسيطة
                    // نستخدم services names من entity مؤقتاً
                    return Column(
                      children: a.services.asMap().entries.map((e) {
                        return _ServiceCard(
                          name: e.value,
                          index: e.key,
                          artistId: a.id,
                          artistName: a.nameAr,
                          isAvailable: a.isAvailable,
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkeleton() {
    return SafeArea(
      child: Column(
        children: [
          const NajmaShimmer(height: 260, radius: 0),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                NajmaShimmer(height: 30, width: 200),
                const SizedBox(height: 12),
                NajmaShimmer(height: 16, width: 120),
                const SizedBox(height: 20),
                NajmaShimmer(height: 14),
                const SizedBox(height: 8),
                NajmaShimmer(height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Service Card ─────────────────────────────────────────────────
class _ServiceCard extends StatelessWidget {
  final String name;
  final int index;
  final int artistId;
  final String artistName;
  final bool isAvailable;

  const _ServiceCard({
    required this.name,
    required this.index,
    required this.artistId,
    required this.artistName,
    required this.isAvailable,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isAvailable ? () => _openCheckout(context) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: NajmaColors.surface,
          border: Border.all(color: NajmaColors.goldDim.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: NajmaColors.gold.withOpacity(0.1),
                border: Border.all(color: NajmaColors.goldDim.withOpacity(0.3)),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: NajmaTextStyles.gold(size: 13),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(name, style: NajmaTextStyles.body(size: 14))),
            if (isAvailable)
              const Icon(
                Icons.arrow_back_ios,
                color: NajmaColors.goldDim,
                size: 13,
              ),
            if (!isAvailable)
              Text(
                'غير متاح',
                style: NajmaTextStyles.caption(color: NajmaColors.textDim),
              ),
          ],
        ),
      ),
    );
  }

  void _openCheckout(BuildContext context) {
    context.push(
      '/home/checkout'
      '?serviceId=$index'
      '&serviceName=${Uri.encodeComponent(name)}'
      '&price=0'
      '&artistName=${Uri.encodeComponent(artistName)}',
    );
  }
}
