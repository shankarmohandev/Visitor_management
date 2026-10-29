import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app.dart';
import '../theme/app_theme.dart';

/// Animated Splash Screen featuring Sumadhura branding and smooth motion.
/// Directly navigates to MainNavigationShell (Dashboard) for front-desk personnel.
class SplashScreen extends StatefulWidget {
  final bool autoNavigate;

  const SplashScreen({super.key, this.autoNavigate = true});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.7, curve: Curves.easeIn)),
    );

    _slideAnimation = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.9, curve: Curves.easeOutCubic)),
    );

    _controller.forward();

    if (widget.autoNavigate) {
      _navigationTimer = Timer(const Duration(milliseconds: 2000), _proceedToNextScreen);
    }
  }

  void _proceedToNextScreen() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) => const MainNavigationShell(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.onyxDark,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Background ambient gradient
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.0, -0.2),
                  radius: 1.1,
                  colors: [
                    Color(0xFF26201B),
                    Color(0xFF14120F),
                    Color(0xFF0D0B0A),
                  ],
                ),
              ),
            ),

            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Luxury Monogram Badge with official Sumadhura logo
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1B17),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: const Color(0xFFC59A3F).withValues(alpha: 0.6),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFC59A3F).withValues(alpha: 0.25),
                                    blurRadius: 28,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'assets/icon.png',
                                height: 38,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                              ),
                            ),

                          const SizedBox(height: 22),

                          // Brand Name
                          const Text(
                            'SUMADHURA',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4.0,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 6),

                          // Gold subtitle
                          const Text(
                            'VISITOR MANAGEMENT SYSTEM',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.2,
                              color: AppTheme.primaryGold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Footer version
          const Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Security & Front Desk Portal • v1.0.0',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
  }
}
