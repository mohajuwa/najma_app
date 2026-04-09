import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/artist_entity.dart';

class NajmaArtistCard extends StatefulWidget {
  final ArtistEntity artist;
  final VoidCallback? onTap;
  const NajmaArtistCard({super.key, required this.artist, this.onTap});

  @override
  State<NajmaArtistCard> createState() => _NajmaArtistCardState();
}

class _NajmaArtistCardState extends State<NajmaArtistCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 160),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.artist;

    return GestureDetector(
      onTapDown: (_) {
        _ctrl.forward();
        HapticFeedback.selectionClick();
      },
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 96,
          decoration: BoxDecoration(
            color: NajmaColors.surface,
            border: Border.all(color: NajmaColors.goldDim.withOpacity(0.18)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(children: [
            // ── Avatar ──────────────────────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(4),
                bottomRight: Radius.circular(4),
              ),
              child: SizedBox(
                width: 82,
                height: double.infinity,
                child: a.avatar != null
                    ? CachedNetworkImage(
                        imageUrl: a.avatar!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: NajmaColors.surface2,
                          child: const Center(
                            child: SizedBox(
                              width: 18, height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: NajmaColors.goldDim,
                              ),
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) => _AvatarFallback(a.nameAr),
                      )
                    : _AvatarFallback(a.nameAr),
              ),
            ),

            // ── Info ─────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Name + availability badge
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            a.nameAr,
                            style: NajmaTextStyles.heading(size: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _AvailBadge(isAvailable: a.isAvailable),
                      ],
                    ),

                    // Genre if exists
                    if (a.genre != null)
                      Text(
                        a.genre!,
                        style: NajmaTextStyles.caption(
                            size: 11, color: NajmaColors.textSecond),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                    // Bottom row: rating + services count + arrow
                    Row(children: [
                      const Icon(Icons.star_rounded,
                          color: NajmaColors.gold, size: 14),
                      const SizedBox(width: 3),
                      Text(
                        a.rating.toStringAsFixed(1),
                        style: NajmaTextStyles.caption(
                            size: 12, color: NajmaColors.gold),
                      ),
                      Text(
                        '  (${a.reviewsCount})',
                        style: NajmaTextStyles.caption(size: 11),
                      ),
                      const Spacer(),
                      if (a.services.isNotEmpty) ...[
                        const Icon(Icons.playlist_play,
                            color: NajmaColors.textDim, size: 14),
                        const SizedBox(width: 3),
                        Text(
                          '${a.services.length} خدمة',
                          style: NajmaTextStyles.caption(
                              size: 11, color: NajmaColors.textDim),
                        ),
                        const SizedBox(width: 10),
                      ],
                      // أقل سعر خدمة
                      if (a.services.isNotEmpty) ...[
                        Builder(builder: (_) {
                          final prices = a.services
                              .map((s) => (s['price'] as num?)?.toDouble() ?? 0)
                              .where((p) => p > 0)
                              .toList()
                            ..sort();
                          if (prices.isEmpty) return const SizedBox.shrink();
                          return Text(
                            'من ${prices.first.toStringAsFixed(0)} ر.س',
                            style: NajmaTextStyles.caption(
                                size: 11, color: NajmaColors.goldBright),
                          );
                        }),
                      ],
                    ]),
                  ],
                ),
              ),
            ),

            // ── Arrow ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(left: 14, right: 6),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: NajmaColors.gold.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: NajmaColors.goldDim,
                  size: 12,
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ── Avatar Fallback ──────────────────────────────────────────────
class _AvatarFallback extends StatelessWidget {
  final String name;
  const _AvatarFallback(this.name);

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
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: NajmaColors.goldDim,
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: isAvailable
            ? NajmaColors.success.withOpacity(0.12)
            : NajmaColors.surface2,
        border: Border.all(
          color: isAvailable
              ? NajmaColors.success.withOpacity(0.5)
              : NajmaColors.textDim.withOpacity(0.2),
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            color: isAvailable ? NajmaColors.success : NajmaColors.textDim,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          isAvailable ? 'متاح' : 'غير متاح',
          style: NajmaTextStyles.caption(
            size: 9,
            color: isAvailable ? NajmaColors.success : NajmaColors.textDim,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
      ]),
    );
  }
}
