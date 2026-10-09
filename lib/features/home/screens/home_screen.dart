import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../piano/screens/piano_screen.dart';
import '../../tabla/screens/tabla_screen.dart';
import '../../dholak/screens/dholak_screen.dart';
import '../../guitar/screens/guitar_screen.dart';
import '../../ukulele/screens/ukulele_screen.dart';
import '../../xylophone/screens/xylophone_screen.dart';
import '../../drumpad/screens/drumpad_screen.dart';
import '../../djlooper/screens/dj_looper_screen.dart';
import '../../harmonium/screens/harmonium_screen.dart';
import '../../sitar/screens/sitar_screen.dart';
import '../../bansuri/screens/bansuri_screen.dart';
import '../../violin/screens/violin_screen.dart';
import '../../tuner/screens/tuner_screen.dart';
import '../../musictheory/screens/ear_training_screen.dart';
import '../../musictheory/screens/scale_encyclopedia_screen.dart';
import '../../learn/screens/exercise_list_screen.dart';
import '../../recorder/screens/recording_library_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../santoor/screens/santoor_screen.dart';
import '../../progress/screens/progress_screen.dart';
import '../../../core/progress/practice_tracker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/banner_ad_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 1. App Header Banner
            _buildHeader(context),

            // 2. Main Instrument Dashboard Suite
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  _buildDashboardCard(
                    context,
                    title: '🎹 Piano Studio & Learn',
                    subtitle: 'Multitouch Keyboard, Scales, Chords & Learn Mode',
                    gradient: const [Color(0xFFFF9F1C), Color(0xFFFFBF69)],
                    icon: Icons.piano_rounded,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PianoScreen())),
                  ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 12),

                  _buildDashboardCard(
                    context,
                    title: '🪘 Tabla Studio & Taal Trainer',
                    subtitle: '3D Dayan & Bayan drums, 5 Taals & Step Sequencer',
                    gradient: const [Color(0xFFFB8500), Color(0xFFFFB703)],
                    icon: Icons.adjust_rounded,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TablaScreen())),
                  ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 12),

                  _buildDashboardCard(
                    context,
                    title: '🥁 Dholak & Dhol Studio',
                    subtitle: 'Dual-Head Percussion, Garba, Bhangra & Bhajan Beats',
                    gradient: const [Color(0xFFD35400), Color(0xFFE67E22)],
                    icon: Icons.graphic_eq_rounded,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DholakScreen())),
                  ).animate().fadeIn(duration: 275.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 12),

                  _buildDashboardCard(
                    context,
                    title: '🎸 Guitar & Strum Studio',
                    subtitle: '6-String Fretboard, 45+ Chords & Auto Strum',
                    gradient: const [Color(0xFFE53170), Color(0xFFC70039)],
                    icon: Icons.music_note_rounded,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GuitarScreen())),
                  ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 12),

                  _buildDashboardCard(
                    context,
                    title: '🪕 Ukulele & Strum Studio',
                    subtitle: '4-String G-C-E-A Nylon Fretboard & Chords',
                    gradient: const [Color(0xFF8B5A2B), Color(0xFFD4A373)],
                    icon: Icons.music_note_rounded,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UkuleleScreen())),
                  ).animate().fadeIn(duration: 325.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 12),

                  _buildDashboardCard(
                    context,
                    title: '🎼 Rainbow Xylophone Studio',
                    subtitle: '2-Octave Wooden Mallet Bars, English & Sargam Labels',
                    gradient: const [Color(0xFF7F5AF0), Color(0xFFE63946)],
                    icon: Icons.graphic_eq_rounded,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const XylophoneScreen())),
                  ).animate().fadeIn(duration: 340.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 12),

                  _buildDashboardCard(
                    context,
                    title: '🥁 Drum Pad Beat Maker',
                    subtitle: '16 pads with Classic, Hip-Hop & EDM Drum Kits',
                    gradient: const [Color(0xFF00E5FF), Color(0xFF0083B0)],
                    icon: Icons.grid_view_rounded,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DrumPadScreen())),
                  ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 12),

                  _buildDashboardCard(
                    context,
                    title: '🎛 DJ Loop Launcher & FX Pad',
                    subtitle: '8-Track Live Loop Matrix, BPM Sync & Low-Pass FX Filter',
                    gradient: const [Color(0xFFB5179E), Color(0xFF7F5AF0)],
                    icon: Icons.tune_rounded,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DJLooperScreen())),
                  ).animate().fadeIn(duration: 375.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 12),

                  _buildDashboardCard(
                    context,
                    title: '🪕 Harmonium & Drone Studio',
                    subtitle: 'Wooden cabinet, Sargam notes & Sa/Pa Drone keys',
                    gradient: const [Color(0xFFD4A373), Color(0xFF8B5E3C)],
                    icon: Icons.radio_rounded,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HarmoniumScreen())),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 12),

                  _buildDashboardCard(
                    context,
                    title: '🪕 Sitar & Meend Studio',
                    subtitle: '14 Curved Pardas, Meend Pitch Bend, Chikari & Tarab',
                    gradient: const [Color(0xFFB8860B), Color(0xFF7A4A28)],
                    icon: Icons.graphic_eq_rounded,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SitarScreen())),
                  ).animate().fadeIn(duration: 425.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 12),

                  _buildDashboardCard(
                    context,
                    title: '🪈 Bansuri & Flute Studio',
                    subtitle: '6-Hole Bamboo Flute, Half-Hole Komal Swaras & Vibrato',
                    gradient: const [Color(0xFFE5B064), Color(0xFF8F5E1D)],
                    icon: Icons.air_rounded,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BansuriScreen())),
                  ).animate().fadeIn(duration: 435.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 12),

                  _buildDashboardCard(
                    context,
                    title: '🎻 Violin Studio',
                    subtitle: '4-String fretless fingerboard with position tapes',
                    gradient: const [Color(0xFF7F5AF0), Color(0xFF5A3EC8)],
                    icon: Icons.graphic_eq_rounded,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ViolinScreen())),
                  ).animate().fadeIn(duration: 450.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 12),

                  _buildDashboardCard(
                    context,
                    title: '🎶 Santoor Studio',
                    subtitle: 'Hammered strings in all 10 thaats, with tremolo rolls',
                    gradient: const [Color(0xFFB5651D), Color(0xFF6B3D1E)],
                    icon: Icons.blur_linear_rounded,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SantoorScreen())),
                  ).animate().fadeIn(duration: 450.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 12),

                  _buildDashboardCard(
                    context,
                    title: '🎯 Chromatic Tuner & Vocal Pitch',
                    subtitle: 'Instrument Presets, Flat/Sharp Needle Meter & Vocal Graph',
                    gradient: const [Color(0xFF2CB67D), Color(0xFF00E5FF)],
                    icon: Icons.tune_rounded,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TunerScreen())),
                  ).animate().fadeIn(duration: 475.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 12),

                  _buildDashboardCard(
                    context,
                    title: '🎓 Practice & Learn Hub',
                    subtitle: 'Interactive note highlight lessons with score tracking',
                    gradient: const [Color(0xFF2CB67D), Color(0xFF208B58)],
                    icon: Icons.school_rounded,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExerciseListScreen())),
                  ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildSecondaryCard(
                          context,
                          title: '🎼 Ear Training',
                          icon: Icons.quiz_rounded,
                          color: AppColors.accentPurple,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EarTrainingScreen())),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildSecondaryCard(
                          context,
                          title: '📖 Raga Guide',
                          icon: Icons.menu_book_rounded,
                          color: AppColors.primaryCyan,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScaleEncyclopediaScreen())),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 550.ms),

                  const SizedBox(height: 12),

                  _buildDashboardCard(
                    context,
                    title: '🎙 Local Jam Recordings',
                    subtitle: 'Replay and manage jams from every instrument',
                    gradient: const [Color(0xFF4A4E69), Color(0xFF22223B)],
                    icon: Icons.library_music_rounded,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RecordingLibraryScreen())),
                  ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0),
                ],
              ),
            ),

            // 3. AdMob Banner Ad
            const BannerAdWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        border: Border(bottom: BorderSide(color: AppColors.darkCardBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  children: const [
                    Text('🎵 ', style: TextStyle(fontSize: 26)),
                    Flexible(
                      child: Text(
                        'SurJam Suite',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryNeon.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryNeon),
                    ),
                    child: const Text(
                      'WORKS OFFLINE',
                      style: TextStyle(color: AppColors.primaryNeon, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_rounded, color: AppColors.textSecondary),
                    tooltip: 'Settings',
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Practice streak and today's goal; opens the progress screen.
          ListenableBuilder(
            listenable: PracticeTracker.instance,
            builder: (context, _) {
              final tracker = PracticeTracker.instance;
              final streak = tracker.currentStreak;
              return InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProgressScreen())),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        streak > 0 ? '🔥 $streak-day streak' : '🔥 Start a streak today',
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      Flexible(
                        child: Text(
                          '  ·  ${tracker.today.minutes}/${tracker.dailyGoalMinutes} min today',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 18),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required List<Color> gradient,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.black26,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(color: Colors.black87, fontSize: 12, height: 1.2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.black54, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
