import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/santoor_model.dart';
import '../providers/santoor_provider.dart';
import '../widgets/santoor_strings_widget.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/record_button.dart';

class SantoorScreen extends StatelessWidget {
  const SantoorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SantoorProvider(),
      child: Consumer<SantoorProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('🎶 Santoor Studio'),
              centerTitle: true,
              actions: [
                const RecordButton(instrument: 'Santoor', compact: true),
                IconButton(
                  tooltip: provider.showSargam ? 'Show note names' : 'Show sargam',
                  icon: Text(
                    provider.showSargam ? 'C' : 'Sa',
                    style: const TextStyle(color: AppColors.pianoGold, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  onPressed: provider.toggleLabels,
                ),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  // Thaat (tuning) selector
                  SizedBox(
                    height: 44,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      children: [
                        for (final thaat in Thaat.all)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(thaat.name),
                              selected: provider.thaat.id == thaat.id,
                              selectedColor: AppColors.pianoGold,
                              backgroundColor: AppColors.darkCard,
                              labelStyle: TextStyle(
                                color: provider.thaat.id == thaat.id ? Colors.black : Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                              onSelected: (_) => provider.setThaat(thaat),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
                    child: Text(
                      '${provider.thaat.name} thaat: ${provider.thaat.character}.  Tap to strike · hold for a tremolo roll',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
                      child: SantoorStringsWidget(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
