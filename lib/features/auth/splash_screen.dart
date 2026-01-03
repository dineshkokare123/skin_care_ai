import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:skin_care_ai/core/app_theme.dart';
import '../../shared/widgets/glass_container.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  _navigateToLogin() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE0F7FA), Color(0xFFF3E5F5)], // Soft Cyan to Soft Lavender
          ),
        ),
        child: Stack(
          children: [
             // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.8),
                  ],
                ),
              ),
            ),
            Center(
              child: AnimationConfiguration.synchronized(
                duration: const Duration(seconds: 1),
                child: FadeInAnimation(
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: GlassContainer(
                      padding: const EdgeInsets.all(40),
                      color: Colors.white,
                      opacity: 0.3,
                      blur: 15,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/logo.png',
                            height: 120,
                            width: 120,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "Aura Skin AI",
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Unlock your perfect glow",
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: AppTheme.textLight,
                                ),
                          ),
                        ],
                      ),
                    ),
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
