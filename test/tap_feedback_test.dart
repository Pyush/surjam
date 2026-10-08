import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surjam/core/storage/storage_service.dart';
import 'package:surjam/features/dholak/providers/dholak_provider.dart';
import 'package:surjam/features/drumpad/models/drum_pad_model.dart';
import 'package:surjam/features/drumpad/providers/drumpad_provider.dart';
import 'package:surjam/features/tabla/providers/tabla_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final vibrations = <String>[];

  setUpAll(() async {
    for (final channel in ['xyz.luan/audioplayers.global', 'xyz.luan/audioplayers']) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MethodChannel(channel), (call) async => 1);
    }
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'HapticFeedback.vibrate') vibrations.add(call.arguments as String);
      return null;
    });
    SharedPreferences.setMockInitialValues({});
    await StorageService().initialize();
  });

  setUp(() async {
    vibrations.clear();
    await StorageService().setHapticsEnabled(true);
  });

  test('Manual drum pad, tabla and dholak strikes vibrate', () {
    DrumPadProvider().triggerPad(DrumPadModel.defaultPads.first);
    TablaProvider().triggerBol('Dha');
    DholakProvider().playStrokeById('dha');
    expect(vibrations, equals(['HapticFeedbackType.lightImpact', 'HapticFeedbackType.lightImpact', 'HapticFeedbackType.lightImpact']));
  });

  test('Automated loop playback does not vibrate', () {
    TablaProvider().triggerBol('Dha', isAutomated: true);
    DholakProvider().playStrokeById('dha', isAutomated: true);
    expect(vibrations, isEmpty);
  });

  test('Turning vibration off in settings stops it', () async {
    await StorageService().setHapticsEnabled(false);
    DrumPadProvider().triggerPad(DrumPadModel.defaultPads.first);
    TablaProvider().triggerBol('Na');
    expect(vibrations, isEmpty);
  });
}
