
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/local_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _starCtrl;
  late AnimationController _fadeCtrl;
  late AnimationController _particleCtrl;
  late Animation<double> _starAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _starCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _starAnim = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _starCtrl, curve: Curves.easeInOut));

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();

    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    Future.delayed(AppConstants.splashDuration, _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    final lang = LocalStorage.getLang();

    // أول مرة — اختيار اللغة (go = نقطة بداية جديدة)
    if (lang == null) {
      context.go('/language');
      return;
    }

    // الدور لم يختر — ابدأ من language لأن push stack تبنى من هناك
    final role = LocalStorage.getRole();
    if (role == null) {
      context.go('/language');
      return;
    }

    // مسجّل دخول مسبقاً
    final token = LocalStorage.getToken();
    context.go(
      token != null
          ? (role == 'artist' ? '/artist-dashboard' : '/home')
          : '/otp',
    );
  }

  @override
  void dispose() {
    _starCtrl.dispose();
    _fadeCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NajmaColors.black,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Stack(
          children: [
            // Particle background
            AnimatedBuilder(
              animation: _particleCtrl,
              builder: (_, __) => CustomPaint(
                painter: _ParticlePainter(_particleCtrl.value),
                child: const SizedBox.expand(),
              ),
            ),
            // Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Star logo
                  AnimatedBuilder(
                    animation: _starAnim,
                    builder: (_, __) => CustomPaint(
                      painter: _StarPainter(_starAnim.value),
                      size: const Size(80, 80),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Wordmark
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        NajmaColors.goldDim,
                        NajmaColors.gold,
                        NajmaColors.goldBright,
                        NajmaColors.gold,
                        NajmaColors.goldDim,
                      ],
                    ).createShader(bounds),
                    child: const Text(
                      'NAJMA',
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 10,
                        fontFamily: 'PlayfairDisplay',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'نجمة',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: NajmaColors.gold,
                      letterSpacing: 2,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 80,
                    height: 1,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          NajmaColors.gold,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'حيث تلتقي الموهبة بلحظاتك المميزة',
                    style: TextStyle(
                      fontSize: 12,
                      color: NajmaColors.textDim,
                      fontFamily: 'Tajawal',
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StarPainter extends CustomPainter {
  final double glow;
  _StarPainter(this.glow);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = NajmaColors.gold.withOpacity(glow)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final glowPaint = Paint()
      ..color = NajmaColors.gold.withOpacity(glow * 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final path = _starPath(size);
    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);

    // Center dot
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      3,
      Paint()..color = NajmaColors.goldBright.withOpacity(glow),
    );
  }

  Path _starPath(Size s) {
    final path = Path();
    final cx = s.width / 2;
    final cy = s.height / 2;
    const points = 5;
    final outer = s.width * 0.45;
    final inner = s.width * 0.18;

    for (int i = 0; i < points * 2; i++) {
      final angle = (i * math.pi / points) - math.pi / 2;
      final r = i.isEven ? outer : inner;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(_StarPainter old) => old.glow != glow;
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  final _rng = math.Random(42);
  late final List<_Particle> particles;

  _ParticlePainter(this.progress) {
    particles = List.generate(
      60,
      (i) => _Particle(
        x: _rng.nextDouble(),
        baseY: _rng.nextDouble(),
        speed: _rng.nextDouble() * 0.3 + 0.05,
        size: _rng.nextDouble() * 2 + 0.3,
        isGold: _rng.nextBool(),
        phase: _rng.nextDouble(),
      ),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final y = ((p.baseY - progress * p.speed + p.phase) % 1.0) * size.height;
      final paint = Paint()
        ..color = (p.isGold ? NajmaColors.gold : NajmaColors.textPrimary)
            .withOpacity((0.1 + p.size * 0.15).clamp(0.0, 0.7));
      canvas.drawCircle(Offset(p.x * size.width, y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}

class _Particle {
  final double x, baseY, speed, size, phase;
  final bool isGold;
  const _Particle({
    required this.x,
    required this.baseY,
    required this.speed,
    required this.size,
    required this.isGold,
    required this.phase,
  });
}

