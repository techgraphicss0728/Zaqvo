import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zaqvo_customer_app/core/router/app_routes.dart';
import 'package:zaqvo_customer_app/core/theme/app_colors.dart';

/// Help center: FAQ, contact shortcuts, and legal links.
class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  final _searchController = TextEditingController();
  /// Default expanded FAQ matches reference ("How do I update my profile?").
  int? _expandedFaqIndex = 1;

  static const _faqs = <_FaqData>[
    _FaqData(
      question: 'How to reset my password?',
      answer:
          'On the login screen, tap Forgot password and follow the steps sent to your registered email or phone number.',
    ),
    _FaqData(
      question: 'How do I update my profile?',
      answer:
          "Go to your Profile tab, click on the 'Edit' icon in the top right corner. You can change your name, email, and preferences there.",
    ),
    _FaqData(
      question: 'Payment methods accepted',
      answer:
          'We accept UPI, major debit and credit cards, and net banking. Cash on delivery may be available in select areas.',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF3F6F9);

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HelpHeader(onBack: () => _onBack(context)),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                _SearchField(controller: _searchController),
                const SizedBox(height: 22),
                const _SectionTitle('CONTACT US'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ContactCard(
                        icon: Icons.phone_in_talk_rounded,
                        label: 'Call',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Support: +91 1800-XXX-XXXX (demo)',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ContactCard(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Email: support@zaqvo.com (demo)',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                Row(
                  children: [
                    const Expanded(
                      child: _SectionTitle('COMMON QUESTIONS'),
                    ),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Full FAQ list coming soon.'),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.skyBlue,
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'View All',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Material(
                  color: Colors.white,
                  elevation: 1,
                  shadowColor: Colors.black.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    children: [
                      for (var i = 0; i < _faqs.length; i++) ...[
                        if (i > 0)
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: AppColors.border.withValues(alpha: 0.85),
                          ),
                        _FaqTile(
                          data: _faqs[i],
                          expanded: _expandedFaqIndex == i,
                          onTap: () {
                            setState(() {
                              _expandedFaqIndex =
                                  _expandedFaqIndex == i ? null : i;
                            });
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const _FeedbackBanner(),
                const SizedBox(height: 20),
                Material(
                  color: Colors.white,
                  elevation: 1,
                  shadowColor: Colors.black.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    children: [
                      _LegalTile(
                        icon: Icons.info_outline_rounded,
                        label: 'About ZAQVO',
                        onTap: () => _soon(context),
                      ),
                      Divider(
                        height: 1,
                        thickness: 1,
                        indent: 52,
                        color: AppColors.border.withValues(alpha: 0.85),
                      ),
                      _LegalTile(
                        icon: Icons.description_outlined,
                        label: 'Terms of Service',
                        onTap: () => _soon(context),
                      ),
                      Divider(
                        height: 1,
                        thickness: 1,
                        indent: 52,
                        color: AppColors.border.withValues(alpha: 0.85),
                      ),
                      _LegalTile(
                        icon: Icons.shield_outlined,
                        label: 'Privacy Policy',
                        onTap: () => _soon(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'ZAQVO Mobile App',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Version 1.0.0',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.slate400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '(Build www.techgraphicss.com)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.slate400.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _soon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon.')),
    );
  }
}

class _FaqData {
  const _FaqData({required this.question, required this.answer});

  final String question;
  final String answer;
}

class _HelpHeader extends StatelessWidget {
  const _HelpHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(28),
      ),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4A9FD9), Color(0xFF36B8E8), AppColors.skyBlue],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 16, 18),
            child: Row(
              children: [
                Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onBack,
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                  ),
                ),
                const Expanded(
                  child: Text(
                    'Help & Support',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(14),
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'How can we help you?',
          hintStyle: TextStyle(
            color: AppColors.slate400.withValues(alpha: 0.95),
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppColors.slate400.withValues(alpha: 0.9),
            size: 26,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.85,
        color: Color(0xFF9CA8B5),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.skyBlue.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.skyBlue, size: 26),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Color(0xFF203447),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({
    required this.data,
    required this.expanded,
    required this.onTap,
  });

  final _FaqData data;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    data.question,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color(0xFF203447),
                      height: 1.25,
                    ),
                  ),
                ),
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.slate400,
                  size: 26,
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 10, right: 8),
                child: Text(
                  data.answer,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              crossFadeState: expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedbackBanner extends StatelessWidget {
  const _FeedbackBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            const Color(0xFF0D47A1),
            AppColors.skyBlue.withValues(alpha: 0.95),
          ],
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Help us improve',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Your feedback is valuable to our team',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalTile extends StatelessWidget {
  const _LegalTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF1565C0), size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Color(0xFF203447),
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.slate400,
              size: 26,
            ),
          ],
        ),
      ),
    );
  }
}
