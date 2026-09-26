import 'package:flutter/material.dart';
import 'package:metjou/dashboard/splash/splash.dart';
import 'package:metjou/legal/terms_of_use.dart';
import 'package:metjou/onboarding/views/onboarding_page.dart';
import 'package:metjou/utility/app_locale.dart';
import 'package:metjou/utility/language_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _pageTransition = Duration(milliseconds: 300);

/// First-run introduction: what MetJou does and the permissions it needs.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Background location has to be requested after foreground location.
  Future<void> _requestLocation() async {
    if (await Permission.location.request().isGranted) {
      await Permission.locationAlways.request();
    }
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("appOpenedBefore", true);
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Splash()));
  }

  void _goTo(int page) =>
      _controller.animateToPage(page, duration: _pageTransition, curve: Curves.easeOutCubic);

  List<Widget> _pages(BuildContext context) {
    final l10n = context.l10n;
    return [
      OnboardingPage(
        image: 'assets/onboarding/introduction_image.webp',
        title: 'MetJou',
        text: l10n.onbIntro,
        action: OnboardingActionButton(
          label: l10n.chooseLanguage,
          icon: Icons.language,
          onPressed: () => showLanguagePicker(context),
        ),
      ),
      OnboardingPage(
        image: 'assets/onboarding/Clip.webp',
        text: l10n.onbLocationText,
        action: OnboardingActionButton(
          label: l10n.onbLocationButton,
          icon: Icons.location_on_outlined,
          onPressed: _requestLocation,
        ),
      ),
      OnboardingPage(
        image: 'assets/onboarding/care_image.webp',
        text: l10n.onbMicText,
        action: OnboardingActionButton(
          label: l10n.onbMicButton,
          icon: Icons.mic_none,
          onPressed: () => [Permission.microphone, Permission.notification].request(),
        ),
      ),
      OnboardingPage(
        image: 'assets/onboarding/mood_dairy_image.webp',
        text: l10n.onbSmsText,
        action: OnboardingActionButton(
          label: l10n.onbSmsButton,
          icon: Icons.sms_outlined,
          onPressed: () => [Permission.sms, Permission.phone].request(),
        ),
      ),
      OnboardingPage(
        image: 'assets/onboarding/welcome.webp',
        title: l10n.onbWelcome,
        text: l10n.onbIntro,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pages = _pages(context);
    final isFirst = _page == 0;
    final isLast = _page == pages.length - 1;

    return Scaffold(
      backgroundColor: onboardingBackground,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 56,
              child: Row(
                children: [
                  if (!isFirst)
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => _goTo(_page - 1),
                    ),
                  const Spacer(),
                  if (!isLast)
                    TextButton(
                      onPressed: () => _goTo(pages.length - 1),
                      child: Text(l10n.onbSkip,
                          style: const TextStyle(color: onboardingPrimary)),
                    ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (page) => setState(() => _page = page),
                children: pages,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PageDots(count: pages.length, current: _page),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: onboardingPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                      ),
                      onPressed: isLast ? _finish : () => _goTo(_page + 1),
                      child: Text(
                        isFirst
                            ? l10n.onbBegin
                            : isLast
                                ? l10n.onbGetStarted
                                : l10n.onbNext,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  AnimatedSize(
                    duration: _pageTransition,
                    child: isLast ? const TermsOfUse() : const SizedBox(width: double.infinity),
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

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: _pageTransition,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == current ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == current ? onboardingPrimary : const Color(0xffDDCFD8),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}
