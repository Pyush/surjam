import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/audio/audio_engine.dart';
import 'core/audio/metronome_service.dart';
import 'core/ads/admob_service.dart';
import 'core/storage/storage_service.dart';
import 'core/lifecycle/playback_guard.dart';
import 'core/progress/practice_tracker.dart';
import 'features/piano/providers/piano_provider.dart';
import 'features/home/screens/home_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Allow natural device orientation (Portrait and Landscape)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Only local settings are needed before the first frame. Audio players start in the
  // background; ads start after the first frame (see _SurJamAppState).
  await StorageService().initialize();
  await PracticeTracker.instance.initialize();
  unawaited(AudioEngine().initialize());

  runApp(const SurJamApp());
}

class SurJamApp extends StatefulWidget {
  const SurJamApp({super.key});

  @override
  State<SurJamApp> createState() => _SurJamAppState();
}

class _SurJamAppState extends State<SurJamApp> {
  // Stops loops, the metronome, drones and lesson demos when the app is hidden (home
  // button, app switcher, phone call, screen lock). The tuner releases its microphone itself.
  // Created in initState: a lazily initialised field would never be created until dispose.
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onHide: PlaybackGuard.stopAll);
    // Ad consent may show Google's form over the app, so it waits for the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) => AdMobService().initialize());
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Only state shared across screens is global: the piano (used by Learn and Settings)
    // and its metronome. Every instrument screen creates and disposes its own provider.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PianoProvider()),
        ChangeNotifierProvider(create: (_) => MetronomeService()),
      ],
      child: MaterialApp(
        title: 'SurJam',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
