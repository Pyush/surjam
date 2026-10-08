import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/audio/audio_engine.dart';
import 'core/audio/metronome_service.dart';
import 'core/ads/admob_service.dart';
import 'core/storage/storage_service.dart';
import 'features/piano/providers/piano_provider.dart';
import 'features/tabla/providers/tabla_provider.dart';
import 'features/guitar/providers/guitar_provider.dart';
import 'features/home/screens/home_screen.dart';

import 'features/sitar/providers/sitar_provider.dart';
import 'features/bansuri/providers/bansuri_provider.dart';
import 'features/dholak/providers/dholak_provider.dart';
import 'features/ukulele/providers/ukulele_provider.dart';
import 'features/xylophone/providers/xylophone_provider.dart';
import 'features/djlooper/providers/dj_looper_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Allow natural device orientation (Portrait and Landscape)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Pre-initialize Core Services
  await StorageService().initialize();
  await AudioEngine().initialize();
  await AdMobService().initialize();

  runApp(const SurJamApp());
}

class SurJamApp extends StatelessWidget {
  const SurJamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PianoProvider()),
        ChangeNotifierProvider(create: (_) => TablaProvider()),
        ChangeNotifierProvider(create: (_) => GuitarProvider()),
        ChangeNotifierProvider(create: (_) => SitarProvider()),
        ChangeNotifierProvider(create: (_) => BansuriProvider()),
        ChangeNotifierProvider(create: (_) => DholakProvider()),
        ChangeNotifierProvider(create: (_) => UkuleleProvider()),
        ChangeNotifierProvider(create: (_) => XylophoneProvider()),
        ChangeNotifierProvider(create: (_) => DJLooperProvider()),
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
