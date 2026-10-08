import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/drum_pad_model.dart';
import '../providers/drumpad_provider.dart';
import '../widgets/pad_grid_widget.dart';
import '../../../core/theme/app_colors.dart';

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
              _KitSelector(),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: PadGridWidget(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KitSelector extends StatelessWidget {
  const _KitSelector();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DrumPadProvider>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: DrumKit.kits.map((kit) {
            final isSelected = provider.selectedKit.id == kit.id;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ChoiceChip(
                label: Text(kit.name),
                selected: isSelected,
                selectedColor: AppColors.primaryNeon,
                backgroundColor: AppColors.darkCardBorder,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                onSelected: (_) => provider.selectKit(kit),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
