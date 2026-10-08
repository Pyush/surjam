import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tabla_provider.dart';
import 'tabla_drum_painter.dart';
import '../../../core/theme/app_colors.dart';

class TablaSurfaceWidget extends StatefulWidget {
  const TablaSurfaceWidget({super.key});

  @override
  State<TablaSurfaceWidget> createState() => _TablaSurfaceWidgetState();
}

class _TablaSurfaceWidgetState extends State<TablaSurfaceWidget> with TickerProviderStateMixin {
  late AnimationController _bayanRippleController;
  late AnimationController _dayanRippleController;

  @override
  void initState() {
    super.initState();
    _bayanRippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _dayanRippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _bayanRippleController.dispose();
    _dayanRippleController.dispose();
    super.dispose();
  }

  void _triggerBayanRipple(TablaProvider provider, String bol) {
    provider.triggerBol(bol);
    _bayanRippleController.forward(from: 0.0);
  }

  void _triggerDayanRipple(TablaProvider provider, String bol) {
    provider.triggerBol(bol);
    _dayanRippleController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TablaProvider>();

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isLandscape = constraints.maxWidth > constraints.maxHeight;

        double drumSize;
        if (isLandscape) {
          drumSize = (constraints.maxHeight * 0.72).clamp(140.0, 240.0);
        } else {
          drumSize = (constraints.maxWidth * 0.44).clamp(130.0, 210.0);
        }

        return Column(
          children: [
            // 3D Drum Stage
            Expanded(
              child: isLandscape
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildBayanStage(context, provider, drumSize * 1.1),
                        _buildDayanStage(context, provider, drumSize * 0.95),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildBayanStage(context, provider, drumSize * 1.05),
                        _buildDayanStage(context, provider, drumSize * 0.92),
                      ],
                    ),
            ),

            const SizedBox(height: 10),

            // Bol Striker Pad Palette
            _buildBolPalette(context, provider),
          ],
        );
      },
    );
  }

  Widget _buildBayanStage(BuildContext context, TablaProvider provider, double size) {
    return AnimatedBuilder(
      animation: _bayanRippleController,
      builder: (context, child) {
        return GestureDetector(
          onTapDown: (details) {
            // Check inner vs outer tap for Ke vs Ge
            double dist = (details.localPosition - Offset(size / 2, size / 2)).distance;
            if (dist < size * 0.25) {
              _triggerBayanRipple(provider, 'Ke');
            } else {
              _triggerBayanRipple(provider, 'Ge');
            }
          },
          child: AnimatedScale(
            scale: provider.isBayanHit ? 0.96 : 1.0,
            duration: const Duration(milliseconds: 60),
            child: SizedBox(
              width: size,
              height: size,
              child: CustomPaint(
                painter: BayanDrumPainter(
                  isHit: provider.isBayanHit,
                  rippleRadius: _bayanRippleController.value,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'BAYAN',
                        style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Ge / Ke',
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDayanStage(BuildContext context, TablaProvider provider, double size) {
    return AnimatedBuilder(
      animation: _dayanRippleController,
      builder: (context, child) {
        return GestureDetector(
          onTapDown: (details) {
            double dist = (details.localPosition - Offset(size / 2, size / 2)).distance;
            if (dist < size * 0.22) {
              _triggerDayanRipple(provider, 'Tun');
            } else if (dist < size * 0.35) {
              _triggerDayanRipple(provider, 'Tin');
            } else {
              _triggerDayanRipple(provider, 'Na');
            }
          },
          child: AnimatedScale(
            scale: provider.isDayanHit ? 0.96 : 1.0,
            duration: const Duration(milliseconds: 60),
            child: SizedBox(
              width: size,
              height: size,
              child: CustomPaint(
                painter: DayanDrumPainter(
                  isHit: provider.isDayanHit,
                  rippleRadius: _dayanRippleController.value,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'DAYAN',
                        style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, shadows: [Shadow(color: Colors.black, blurRadius: 3)]),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Na / Tin',
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black, blurRadius: 3)]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBolPalette(BuildContext context, TablaProvider provider) {
    final bols = ['Dha', 'Dhin', 'Na', 'Tin', 'Ge', 'Ke', 'Ta', 'Tun'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkCardBorder),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: bols.map((bol) {
            bool isLastHit = provider.lastBolHit.toLowerCase() == bol.toLowerCase();
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLastHit ? AppColors.tablaAmber : AppColors.darkCardBorder,
                    foregroundColor: isLastHit ? Colors.black : Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: isLastHit ? 8 : 1,
                  ),
                  onPressed: () {
                    provider.triggerBol(bol);
                    if (['dha', 'dhin', 'ge', 'ke'].contains(bol.toLowerCase())) {
                      _bayanRippleController.forward(from: 0.0);
                    }
                    if (['dha', 'dhin', 'na', 'tin', 'ta', 'tun'].contains(bol.toLowerCase())) {
                      _dayanRippleController.forward(from: 0.0);
                    }
                  },
                  child: Text(
                    bol,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
