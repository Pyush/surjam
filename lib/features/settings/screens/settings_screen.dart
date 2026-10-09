import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'privacy_policy_screen.dart';
import '../../piano/providers/piano_provider.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/progress/practice_tracker.dart';
import '../../../core/ads/admob_service.dart';
import '../../../core/theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const Map<String, String> _labelModes = {
    'english': 'English (C, D, E)',
    'sargam': 'Sargam (Sa, Re, Ga)',
    'none': 'Hide labels',
  };

  @override
  Widget build(BuildContext context) {
    final piano = context.watch<PianoProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('⚙️ Settings'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            _sectionHeader('Note Labels'),
            RadioGroup<String>(
              groupValue: piano.keyLabelMode,
              onChanged: (mode) {
                if (mode != null) piano.setKeyLabelMode(mode);
              },
              child: Column(
                children: _labelModes.entries.map((entry) {
                  return RadioListTile<String>(
                    value: entry.key,
                    activeColor: AppColors.primaryNeon,
                    title: Text(entry.value, style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
              ),
            ),

            const Divider(color: AppColors.darkCardBorder),
            _sectionHeader('Daily practice goal'),
            ListenableBuilder(
              listenable: PracticeTracker.instance,
              builder: (context, _) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Wrap(
                  spacing: 8,
                  children: [
                    for (final minutes in PracticeTracker.goalChoices)
                      ChoiceChip(
                        label: Text('$minutes min'),
                        selected: PracticeTracker.instance.dailyGoalMinutes == minutes,
                        selectedColor: AppColors.learnGreen,
                        labelStyle: TextStyle(
                          color: PracticeTracker.instance.dailyGoalMinutes == minutes ? Colors.black : Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (_) => PracticeTracker.instance.setDailyGoalMinutes(minutes),
                      ),
                  ],
                ),
              ),
            ),

            const Divider(color: AppColors.darkCardBorder),
            _sectionHeader('Feel'),
            StatefulBuilder(
              builder: (context, setState) {
                return SwitchListTile(
                  value: StorageService().getHapticsEnabled(),
                  activeTrackColor: AppColors.primaryNeon,
                  secondary: const Icon(Icons.vibration_rounded, color: AppColors.primaryCyan),
                  title: const Text('Vibrate on drum taps', style: TextStyle(color: Colors.white)),
                  subtitle: const Text(
                    'Drum pad, tabla and dholak',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  onChanged: (enabled) async {
                    await StorageService().setHapticsEnabled(enabled);
                    setState(() {});
                  },
                );
              },
            ),

            const Divider(color: AppColors.darkCardBorder),
            _sectionHeader('About'),
            // Required where ad consent applies (EEA, UK, Switzerland); hidden elsewhere.
            ValueListenableBuilder<bool>(
              valueListenable: AdMobService().privacyOptionsRequired,
              builder: (context, required, _) => required
                  ? ListTile(
                      leading: const Icon(Icons.shield_outlined, color: AppColors.primaryCyan),
                      title: const Text('Privacy choices', style: TextStyle(color: Colors.white)),
                      subtitle: const Text(
                        'Change your consent for ads',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white54),
                      onTap: () => AdMobService().showPrivacyOptions(),
                    )
                  : const SizedBox.shrink(),
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.primaryCyan),
              title: const Text('Privacy Policy', style: TextStyle(color: Colors.white)),
              trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white54),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.description_outlined, color: AppColors.primaryCyan),
              title: const Text('Open-Source Licenses', style: TextStyle(color: Colors.white)),
              subtitle: const Text(
                'Libraries SurJam is built with',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white54),
              onTap: () => showLicensePage(
                context: context,
                applicationName: 'SurJam',
                applicationLegalese: 'All instrument sounds are synthesized by SurJam.',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(color: AppColors.pianoGold, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
      ),
    );
  }
}
