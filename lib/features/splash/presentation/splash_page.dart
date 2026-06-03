import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

class SplashPage extends HookWidget {
  const SplashPage({super.key});

  static const _seenKey = 'splash_seen';

  @override
  Widget build(BuildContext context) {
    final opacity = useAnimationController(
      duration: const Duration(milliseconds: 800),
      initialValue: 0,
    );
    final scale = useAnimationController(
      duration: const Duration(milliseconds: 800),
      initialValue: 0.7,
    );

    useEffect(() {
      // Kick off animations
      opacity.animateTo(1.0, curve: Curves.easeIn);
      scale.animateTo(1.0, curve: Curves.easeOutBack);

      // Navigate after 2.5 seconds
      Future.delayed(const Duration(milliseconds: 2500), () async {
        if (!context.mounted) return;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_seenKey, true);
        if (context.mounted) context.go('/login');
      });

      return null;
    }, const []);

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: AnimatedBuilder(
        animation: Listenable.merge([opacity, scale]),
        builder: (context, _) {
          return Opacity(
            opacity: opacity.value,
            child: Transform.scale(
              scale: scale.value,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo container
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.note_alt_rounded,
                        size: 56,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      AppStrings.appName,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.splashTagline,
                      style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 60),
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
