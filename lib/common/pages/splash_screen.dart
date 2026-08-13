import 'package:flutter/material.dart';
import '../../services/auth_gate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoGlow;
  late Animation<Offset> _textSlide;
  late Animation<double> _textOpacity;
  late Animation<double> _progressWidth;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Controller untuk animasi utama (entrance)
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    // Controller untuk efek denyut / pulse background
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    // Animasi Scale Badge Logo (Back.out effect)
    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
      ),
    );

    // Animasi Fade In Logo
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    // Animasi Glow Ring Logo
    _logoGlow = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeInOut),
      ),
    );

    // Animasi Slide Up Teks & Subtitle
    _textSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.35, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // Animasi Opacity Teks
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.35, 0.75, curve: Curves.easeIn),
      ),
    );

    // Animasi Progress Bar Loading (0 - 100%)
    _progressWidth = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.5, 0.95, curve: Curves.easeInOut),
      ),
    );

    // Pulse animation untuk ambient light
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Jalankan animasi entrance
    _mainController.forward();

    // Berpindah ke AuthGate setelah durasi splash selesai
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(milliseconds: 3100));
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AuthGate(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // 1. DYNAMIC BACKGROUND GRADIENT & AMBIENT GLOW CIRCLES
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF090D16), // Dark Slate / Charcoal
                      Color(0xFF0F172A), // Deep Navy
                      Color(0xFF1E293B), // Slate Blue
                      Color(0xFF1E3A8A), // Royal Dark Blue
                    ],
                    stops: [0.0, 0.35, 0.7, 1.0],
                  ),
                ),
                child: Stack(
                  children: [
                    // Ambient Circle 1 (Top Left Glow)
                    Positioned(
                      top: -size.width * 0.25,
                      left: -size.width * 0.2,
                      child: Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: size.width * 0.8,
                          height: size.width * 0.8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFF3B82F6).withOpacity(0.35),
                                const Color(0xFF2563EB).withOpacity(0.12),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Ambient Circle 2 (Bottom Right Glow)
                    Positioned(
                      bottom: -size.width * 0.3,
                      right: -size.width * 0.25,
                      child: Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: size.width * 0.9,
                          height: size.width * 0.9,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFF6366F1).withOpacity(0.3),
                                const Color(0xFF2563EB).withOpacity(0.1),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Soft Grid Light Effect
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _BackgroundGridPainter(),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // 2. MAIN CONTENT (CENTERED LOGO, BRAND NAME, LOADING & FOOTER)
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 3),

                    // ANIMATED LOGO BADGE WITH GLOW RING
                    AnimatedBuilder(
                      animation: _mainController,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _logoOpacity,
                          child: ScaleTransition(
                            scale: _logoScale,
                            child: Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF3B82F6), // Bright Royal Blue
                                    Color(0xFF1D4ED8), // Deep Blue
                                  ],
                                ),
                                boxShadow: [
                                  // Primary Outer Glow Shadow
                                  BoxShadow(
                                    color: const Color(0xFF2563EB)
                                        .withOpacity(0.55 * _logoGlow.value),
                                    blurRadius: 32,
                                    spreadRadius: 6 * _logoGlow.value,
                                    offset: const Offset(0, 8),
                                  ),
                                  // Subtle Ambient Light
                                  BoxShadow(
                                    color: const Color(0xFF60A5FA)
                                        .withOpacity(0.3 * _logoGlow.value),
                                    blurRadius: 16,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 0),
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Glassmorphism Highlight Line
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      height: 45,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(28),
                                          topRight: Radius.circular(28),
                                        ),
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.white.withOpacity(0.25),
                                            Colors.white.withOpacity(0.0),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.school_rounded,
                                    size: 58,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // ANIMATED BRAND NAME & TAGLINE
                    SlideTransition(
                      position: _textSlide,
                      child: FadeTransition(
                        opacity: _textOpacity,
                        child: Column(
                          children: [
                            // App Name
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [
                                  Colors.white,
                                  Color(0xFFE0F2FE),
                                  Color(0xFF93C5FD),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ).createShader(bounds),
                              child: const Text(
                                "EduSchool",
                                style: TextStyle(
                                  fontSize: 38,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                  color: Colors.white,
                                  height: 1.1,
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Subtitle Tagline Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF60A5FA).withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF60A5FA),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "Smart Learning Management",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.6,
                                      color: Color(0xFFBFDBFE),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(flex: 2),

                    // ANIMATED PROGRESS BAR & LOADING INDICATOR
                    AnimatedBuilder(
                      animation: _mainController,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _textOpacity,
                          child: Column(
                            children: [
                              // Progress Track Container
                              Container(
                                width: 140,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: FractionallySizedBox(
                                    widthFactor: _progressWidth.value,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF60A5FA),
                                            Color(0xFF2563EB),
                                            Color(0xFF818CF8),
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF60A5FA)
                                                .withOpacity(0.6),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 14),

                              Text(
                                "Memuat aplikasi...",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withOpacity(0.5),
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const Spacer(flex: 1),

                    // FOOTER BRANDING & VERSION
                    FadeTransition(
                      opacity: _textOpacity,
                      child: Column(
                        children: [
                          Text(
                            "EduSchool Platform v1.0.0",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.4),
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "© 2026 EduSchool Ecosystem",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withOpacity(0.25),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Background painter for subtle geometric grid lines
class _BackgroundGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.025)
      ..strokeWidth = 1.0;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
