import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/xylophone_model.dart';
import '../providers/xylophone_provider.dart';

class XylophoneBarsWidget extends StatelessWidget {
  const XylophoneBarsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<XylophoneProvider>();
    final keys = XylophoneKeyModel.defaultKeys;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF14121E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12, width: 1.5),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          double maxHeight = constraints.maxHeight - 20;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(keys.length, (idx) {
              final keyModel = keys[idx];
              bool isHit = provider.activeKeyMidi == keyModel.midiNote;

              // Height tapers from 1.0 (leftmost C4) to 0.62 (rightmost C6)
              double heightFraction = 1.0 - (idx * 0.026);
              double barHeight = (maxHeight * heightFraction).clamp(100.0, maxHeight);

              return Expanded(
                child: GestureDetector(
                  onTap: () => provider.playKey(keyModel.midiNote),
                  child: Container(
                    alignment: Alignment.center,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      height: barHeight,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: isHit ? Colors.white : keyModel.barColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isHit ? Colors.yellowAccent : Colors.black26,
                          width: isHit ? 2.5 : 1,
                        ),
                        boxShadow: isHit
                            ? [
                                BoxShadow(
                                  color: keyModel.barColor.withValues(alpha: 0.9),
                                  blurRadius: 16,
                                  spreadRadius: 2,
                                ),
                              ]
                            : [const BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2))],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Top Chrome Mounting Screw
                          Positioned(
                            top: 8,
                            child: _buildScrewHead(),
                          ),

                          // Note Label Badge
                          Text(
                            provider.useSargam ? keyModel.sargamName : keyModel.noteName,
                            style: TextStyle(
                              color: isHit ? Colors.black : Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),

                          // Bottom Chrome Mounting Screw
                          Positioned(
                            bottom: 8,
                            child: _buildScrewHead(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildScrewHead() {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFADB5BD), Color(0xFF495057)],
        ),
        border: Border.all(color: Colors.black38, width: 0.5),
      ),
    );
  }
}
