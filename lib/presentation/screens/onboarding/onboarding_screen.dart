import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../presentation/providers/onboarding_provider.dart';
import '../../../presentation/theme/app_colors.dart';

// ── Data ─────────────────────────────────────────────────────────────────────

class _Slide {
  final Color background;
  final Color onBackground;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String subtitle;

  const _Slide({
    required this.background,
    required this.onBackground,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
  });
}

const _slides = [
  _Slide(
    background: Color(0xFFFFF3EF),
    onBackground: AppColors.onSurface,
    icon: Icons.kitchen_outlined,
    iconColor: AppColors.primary,
    iconBackground: Color(0xFFFFDDD4),
    title: 'Transforme tes restes',
    subtitle:
        "Dis-nous ce qu'il y a dans ton frigo et on trouve une recette réaliste avec ce que tu as.",
  ),
  _Slide(
    background: Color(0xFFF0FFF3),
    onBackground: AppColors.onSurface,
    icon: Icons.track_changes_rounded,
    iconColor: AppColors.secondary,
    iconBackground: Color(0xFFCCF5D0),
    title: 'Match parfait',
    subtitle:
        "L'appli calcule le score de correspondance et te dit exactement ce qu'il manque pour compléter la recette.",
  ),
  _Slide(
    background: Color(0xFFF8F0FF),
    onBackground: AppColors.onSurface,
    icon: Icons.auto_awesome_rounded,
    iconColor: AppColors.tertiary,
    iconBackground: Color(0xFFEDD5F9),
    title: "L'IA cuisine pour toi",
    subtitle:
        "Quand aucune recette ne correspond, notre IA invente une recette sur-mesure avec tes ingrédients.",
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  void _next() {
    if (_page < _slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _finish() {
    ref.read(onboardingSeenProvider.notifier).markSeen();
    context.go(Routes.auth);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Pages
          PageView.builder(
            controller: _controller,
            itemCount: _slides.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) => _SlidePage(slide: _slides[i]),
          ),

          // Skip button (top-right, hidden on last slide)
          if (_page < _slides.length - 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              right: 20,
              child: TextButton(
                onPressed: _finish,
                child: const Text(
                  'Passer',
                  style: TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

          // Bottom controls
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).padding.bottom + 32,
            child: Column(
              children: [
                // Page indicator
                _PageIndicator(count: _slides.length, current: _page),
                const SizedBox(height: 32),
                // CTA button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: SizedBox(
                      key: ValueKey(_page),
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _next,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _page == _slides.length - 1
                              ? AppColors.primary
                              : AppColors.onSurface,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _page == _slides.length - 1
                              ? 'C\'est parti !'
                              : 'Suivant',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Single slide ─────────────────────────────────────────────────────────────

class _SlidePage extends StatelessWidget {
  final _Slide slide;
  const _SlidePage({required this.slide});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      color: slide.background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Illustration
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: slide.iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  slide.icon,
                  size: 88,
                  color: slide.iconColor,
                ),
              ),
              const Spacer(flex: 2),
              // Text
              Text(
                slide.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: slide.onBackground,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                slide.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: slide.onBackground.withValues(alpha: 0.65),
                ),
              ),
              // Space for bottom controls (indicator + button)
              const SizedBox(height: 160),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Page indicator ────────────────────────────────────────────────────────────

class _PageIndicator extends StatelessWidget {
  final int count;
  final int current;
  const _PageIndicator({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active
                ? AppColors.primary
                : AppColors.outlineVariant,
            borderRadius: BorderRadius.circular(100),
          ),
        );
      }),
    );
  }
}
