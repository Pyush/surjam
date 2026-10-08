import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/violin_provider.dart';
import '../widgets/fingerboard_widget.dart';

class ViolinScreen extends StatelessWidget {
  const ViolinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ViolinProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('🎻 Violin Studio'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            children: const [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: FingerboardWidget(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
