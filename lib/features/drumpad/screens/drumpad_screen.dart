import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/drumpad_provider.dart';
import '../widgets/pad_grid_widget.dart';
import '../../../shared/widgets/banner_ad_widget.dart';

class DrumPadScreen extends StatelessWidget {
  const DrumPadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DrumPadProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('🥁 Drum Pad Beat Maker'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            children: const [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: PadGridWidget(),
                ),
              ),
              BannerAdWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
