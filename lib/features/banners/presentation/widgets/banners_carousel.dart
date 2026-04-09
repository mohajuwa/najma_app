import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/banners_datasource.dart';
import '../../domain/entities/banner_entity.dart';

class BannersCarousel extends StatefulWidget {
  const BannersCarousel({super.key});

  @override
  State<BannersCarousel> createState() => _BannersCarouselState();
}

class _BannersCarouselState extends State<BannersCarousel> {
  List<BannerEntity> _banners = [];
  bool _loading = true;
  final _controller  = PageController();
  int _current = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final ds = BannersDataSource();
      final data = await ds.getBanners();
      if (!mounted) return;
      setState(() {
        _banners = data;
        _loading = false;
      });
      if (data.length > 1) _startTimer();
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || _banners.isEmpty) return;
      final next = (_current + 1) % _banners.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _onTap(BannerEntity b) {
    if (b.linkType == 'artist' && b.linkId != null) {
      context.push('/home/artist/${b.linkId}');
    } else if (b.linkType == 'url' && b.linkUrl != null) {
      // يمكن إضافة url_launcher لاحقاً
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return _Skeleton();
    if (_banners.isEmpty) return const SizedBox.shrink();

    return Column(children: [
      SizedBox(
        height: 160,
        child: PageView.builder(
          controller: _controller,
          itemCount: _banners.length,
          onPageChanged: (i) => setState(() => _current = i),
          itemBuilder: (_, i) => _BannerCard(
            banner: _banners[i],
            onTap: () => _onTap(_banners[i]),
          ),
        ),
      ),
      if (_banners.length > 1) ...[
        const SizedBox(height: 10),
        _Dots(count: _banners.length, current: _current),
      ],
    ]);
  }
}

// ── بطاقة بانر واحدة ──────────────────────────────────────────────
class _BannerCard extends StatelessWidget {
  final BannerEntity banner;
  final VoidCallback onTap;
  const _BannerCard({required this.banner, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: NajmaColors.surface,
          border: Border.all(color: NajmaColors.goldDim.withOpacity(0.2)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(fit: StackFit.expand, children: [
            // صورة البانر
            _BannerImage(url: banner.imageUrl),

            // تدرج للنص
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.75),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(banner.title,
                        style: NajmaTextStyles.heading(size: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    if (banner.description != null) ...[
                      const SizedBox(height: 2),
                      Text(banner.description!,
                          style: NajmaTextStyles.caption(
                              size: 11, color: NajmaColors.textSecond),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ],
                ),
              ),
            ),

            // Badge إذا كان قابلاً للنقر
            if (banner.linkType != 'none')
              Positioned(
                top: 10, left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: NajmaColors.gold,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    banner.linkType == 'artist' ? '🎤 فنان' : '🔗 رابط',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}

// ── تحميل الصورة ─────────────────────────────────────────────────
class _BannerImage extends StatelessWidget {
  final String url;
  const _BannerImage({required this.url});

  @override
  Widget build(BuildContext context) {
    // placeholder gradient إذا فشل التحميل أو كانت placeholder URL
    if (url.isEmpty || url.startsWith('placeholder')) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              NajmaColors.gold.withOpacity(0.3),
              NajmaColors.surface2,
            ],
          ),
        ),
        child: const Center(
          child: Text('🌟', style: TextStyle(fontSize: 48)),
        ),
      );
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              NajmaColors.gold.withOpacity(0.25),
              NajmaColors.surface2,
            ],
          ),
        ),
        child: const Center(
          child: Icon(Icons.image_outlined,
              color: NajmaColors.goldDim, size: 48),
        ),
      ),
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return Container(color: NajmaColors.surface2);
      },
    );
  }
}

// ── Dots Indicator ────────────────────────────────────────────────
class _Dots extends StatelessWidget {
  final int count, current;
  const _Dots({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width:  active ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active ? NajmaColors.gold : NajmaColors.goldDim.withOpacity(0.3),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

// ── Skeleton Loading ──────────────────────────────────────────────
class _Skeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: NajmaColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: NajmaColors.goldDim.withOpacity(0.15)),
      ),
      child: Center(
        child: SizedBox(
          width: 24, height: 24,
          child: CircularProgressIndicator(
            color: NajmaColors.gold.withOpacity(0.4),
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
}
