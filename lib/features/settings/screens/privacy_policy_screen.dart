import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const List<(String, String)> _sections = [
    (
      'Overview',
      'SurJam has no accounts and does not run its own servers. The app itself does not collect, '
          'sell or share your personal information.',
    ),
    (
      'Microphone',
      'The Chromatic Tuner uses your microphone, only while the tuner screen is open and listening, '
          'to measure the pitch of your instrument or voice. Audio is analysed on your device in real '
          'time. It is never recorded, saved or sent anywhere.',
    ),
    (
      'Data stored on your device',
      'Your jam recordings, exercise high scores and preferences (such as note labels) are stored only '
          'on your device. They are deleted when you uninstall the app.',
    ),
    (
      'Advertising',
      'SurJam shows ads provided by Google AdMob. To show and measure ads, Google may collect '
          'information such as your device\'s advertising ID, IP address and app usage. Google\'s use of '
          'this information is described at https://policies.google.com/technologies/ads. You can reset '
          'or limit your advertising ID in your device settings.',
    ),
    (
      'Children',
      'SurJam is not directed at children under 13 and does not knowingly collect personal information '
          'from them.',
    ),
    (
      'Changes',
      'If this policy changes, the updated version will appear in this screen with a new date.',
    ),
  ];

  static const String lastUpdated = '8 October 2026';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Last updated: $lastUpdated',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            for (final (heading, body) in _sections) ...[
              const SizedBox(height: 18),
              Text(
                heading,
                style: const TextStyle(color: AppColors.pianoGold, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              SelectableText(
                body,
                style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.45),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
