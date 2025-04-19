import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

// This widget handles both Terms of Service and Privacy Policy
// with a smooth tab transition between them
class LegalPagesScreen extends StatefulWidget {
  const LegalPagesScreen({Key? key, this.initialTab = 0}) : super(key: key);

  // 0 = Terms of Service, 1 = Privacy Policy
  final int initialTab;

  @override
  State<LegalPagesScreen> createState() => _LegalPagesScreenState();
}

class _LegalPagesScreenState extends State<LegalPagesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );

    _animationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Animated background
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return CustomPaint(
                painter: BackgroundPainter(_animationController.value),
                size: MediaQuery.of(context).size,
              );
            },
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Header with back button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),

                      // Spacer
                      const Spacer(),

                      // Tab selector
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F111A),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: const Color(0xFF1E2235),
                            width: 1,
                          ),
                        ),
                        child: Container(
                            width: MediaQuery.of(context).size.width * 0.7,
                            child: TabBar(
                              controller: _tabController,
                              indicator: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                color: const Color(0xFF1A3A8F),
                              ),
                              labelColor: Colors.white,
                              unselectedLabelColor:
                                  Colors.white.withOpacity(0.5),
                              labelStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              dividerColor: Colors.transparent,
                              tabs: const [
                                Tab(text: "Terms of Service"),
                                Tab(text: "Privacy Policy"),
                              ],
                            )),
                      ),

                      // Spacer
                      const Spacer(),

                      // Empty container for symmetry
                      const SizedBox(width: 40),
                    ],
                  ),
                ),

                // "Impaler" bar
                _buildImpalerBar(),

                // Tab content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Terms of Service content
                      _buildTermsOfServiceContent(),

                      // Privacy Policy content
                      _buildPrivacyPolicyContent(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImpalerBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      height: 4,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF1A3A8F),
            Color(0xFF3E6CDF),
          ],
        ),
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3E6CDF).withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
    );
  }

  Widget _buildTermsOfServiceContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: _buildLegalCard(
        title: "Terms of Service",
        lastUpdated: "Last updated: March 24, 2025",
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLegalSection(
              title: "1. Acceptance of Terms",
              content:
                  "By accessing or using Encite ('the App'), you agree to be bound by these Terms of Service. If you disagree with any part of these terms, you may not access the App.",
            ),
            _buildLegalSection(
              title: "2. User Accounts",
              content:
                  "When you create an account with us, you must provide accurate and complete information. You are responsible for maintaining the security of your account, and you are fully responsible for all activities that occur under your account.",
            ),
            _buildLegalSection(
              title: "3. Service Changes and Availability",
              content:
                  "Encite reserves the right to modify, suspend, or discontinue the App with or without notice at any time and without any liability to you.",
            ),
            _buildLegalSection(
              title: "4. User Content",
              content:
                  "You retain all rights to any content you submit, post, or display on or through the App. By submitting content, you grant Encite a worldwide, non-exclusive, royalty-free license to use, reproduce, modify, adapt, publish, and display such content for the purpose of providing and promoting the App.",
            ),
            _buildLegalSection(
              title: "5. Prohibited Uses",
              content:
                  "You agree not to use the App for any unlawful purpose or in any way that could damage the App or impair the user experience. Prohibited behaviors include harassing other users, distributing malware, or attempting to gain unauthorized access to the App's systems.",
            ),
            _buildLegalSection(
              title: "6. Termination",
              content:
                  "We may terminate or suspend your account immediately, without prior notice or liability, for any reason, including if you breach the Terms of Service.",
            ),
            _buildLegalSection(
              title: "7. Limitation of Liability",
              content:
                  "In no event shall Encite, nor its directors, employees, partners, agents, suppliers, or affiliates, be liable for any indirect, incidental, special, consequential or punitive damages, including without limitation, loss of profits, data, use, goodwill, or other intangible losses.",
            ),
            _buildLegalSection(
              title: "8. Governing Law",
              content:
                  "These Terms shall be governed by and defined following the laws of [Your Country]. Encite and yourself irrevocably consent to the exclusive jurisdiction and venue of the courts in [Your City] for any disputes arising out of the use of the App.",
            ),
            _buildLegalSection(
              title: "9. Changes to Terms",
              content:
                  "We reserve the right to modify these terms at any time. We will provide notification of significant changes through the App or by sending an email to the address associated with your account.",
            ),
            _buildLegalSection(
              title: "10. Contact Information",
              content:
                  "If you have any questions about these Terms, please contact us at bryson@encite.net.",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyPolicyContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: _buildLegalCard(
        title: "Privacy Policy",
        lastUpdated: "Last updated: March 24, 2025",
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLegalSection(
              title: "1. Information We Collect",
              content:
                  "We collect information you provide directly to us, such as your name, phone number, and any other information you choose to provide. We also automatically collect certain information about your device, including IP address, device type, and operating system.",
            ),
            _buildLegalSection(
              title: "2. How We Use Information",
              content:
                  "We use the information we collect to provide, maintain, and improve our services, develop new features, communicate with you, and protect our App and users.",
            ),
            _buildLegalSection(
              title: "3. Information Sharing",
              content:
                  "We do not share your personal information with third parties except as described in this policy. We may share information with service providers who perform services on our behalf, when required by law, or in connection with a merger or acquisition.",
            ),
            _buildLegalSection(
              title: "4. Data Security",
              content:
                  "We take reasonable measures to help protect your personal information from loss, theft, misuse, and unauthorized access. However, no security system is impenetrable, and we cannot guarantee the security of your information.",
            ),
            _buildLegalSection(
              title: "5. Your Choices",
              content:
                  "You can update your account information at any time from the profile section of the App. You can also opt out of certain communications by adjusting your notification settings.",
            ),
            _buildLegalSection(
              title: "6. Data Retention",
              content:
                  "We retain your information as long as your account is active or as needed to provide you services. We will also retain and use your information as necessary to comply with legal obligations, resolve disputes, and enforce our agreements.",
            ),
            _buildLegalSection(
              title: "7. Children's Privacy",
              content:
                  "Our App is not intended for children under 13, and we do not knowingly collect information from children under 13. If we learn we have collected information from a child under 13, we will delete that information.",
            ),
            _buildLegalSection(
              title: "8. International Data Transfers",
              content:
                  "We may transfer your information to servers located outside your country of residence, where data protection laws may differ from those in your jurisdiction.",
            ),
            _buildLegalSection(
              title: "9. Changes to This Policy",
              content:
                  "We may update this privacy policy from time to time. We will notify you of significant changes by posting the new policy on our App or by sending you an email.",
            ),
            _buildLegalSection(
              title: "10. Contact Us",
              content:
                  "If you have any questions about this Privacy Policy, please contact us at bryson@encite.net.",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalCard({
    required String title,
    required String lastUpdated,
    required Widget content,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0A0A0A),
                const Color(0xFF121726),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                // Last updated date
                Text(
                  lastUpdated,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),

                const SizedBox(height: 24),

                // Content
                content,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegalSection({
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF3E6CDF),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 12),

        // Section content
        Text(
          content,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 15,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }
}

class BackgroundPainter extends CustomPainter {
  final double animationValue;

  BackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;

    // Create a gradient background
    Paint paint = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          0.5 + 0.3 * sin(animationValue * 2 * pi),
          0.5 + 0.3 * cos(animationValue * 2 * pi),
        ),
        radius: 1.2,
        colors: const [
          Color(0xFF0A0A12),
          Color(0xFF060818),
          Color(0xFF000000),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, paint);

    // Add some subtle floating particles
    final particlePaint = Paint()
      ..color = const Color(0xFF3E6CDF).withOpacity(0.03)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 20; i++) {
      final offset = i / 20;
      final x =
          size.width * (0.2 + 0.6 * sin(2 * pi * (offset + animationValue)));
      final y = size.height *
          (0.2 + 0.6 * cos(2 * pi * (offset + animationValue * 1.2)));
      final radius = 5 + 5 * sin(animationValue * 2 * pi + i);

      canvas.drawCircle(Offset(x, y), radius, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant BackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
