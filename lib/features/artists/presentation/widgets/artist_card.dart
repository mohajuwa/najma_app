import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/artist_entity.dart';

class NajmaArtistCard extends StatelessWidget {
  final ArtistEntity artist;
  final VoidCallback? onTap;

  const NajmaArtistCard({super.key, required this.artist, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: NajmaColors.surface,
          border: Border.all(color: NajmaColors.goldDim.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            // Avatar
            SizedBox(
              width: 80, height: 90,
              child: artist.avatar != null
                ? CachedNetworkImage(imageUrl: artist.avatar!, fit: BoxFit.cover)
                : Container(
                    color: NajmaColors.surface2,
                    child: const Icon(Icons.person, color: NajmaColors.goldDim, size: 32),
                  ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(artist.nameAr, style: NajmaTextStyles.heading(size: 15)),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.star, color: NajmaColors.gold, size: 13),
                      const SizedBox(width: 4),
                      Text(artist.rating.toStringAsFixed(1),
                          style: NajmaTextStyles.caption(size: 12, color: NajmaColors.gold)),
                      Text('  (${artist.reviewsCount})',
                          style: NajmaTextStyles.caption()),
                    ]),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      color: artist.isAvailable
                          ? NajmaColors.success.withOpacity(0.15)
                          : NajmaColors.surface2,
                      child: Text(
                        artist.isAvailable ? 'متاح' : 'غير متاح',
                        style: NajmaTextStyles.caption(
                          size: 10,
                          color: artist.isAvailable ? NajmaColors.success : NajmaColors.textDim,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 14),
              child: Icon(Icons.arrow_back_ios, color: NajmaColors.goldDim, size: 14),
            ),
          ],
        ),
      ),
    );
  }
}
