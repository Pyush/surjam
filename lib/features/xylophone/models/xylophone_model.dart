import 'package:flutter/material.dart';

class XylophoneKeyModel {
  final int midiNote;
  final String noteName;
  final String sargamName;
  final Color barColor;

  const XylophoneKeyModel({
    required this.midiNote,
    required this.noteName,
    required this.sargamName,
    required this.barColor,
  });

  static const List<XylophoneKeyModel> defaultKeys = [
    XylophoneKeyModel(midiNote: 60, noteName: 'C4', sargamName: 'Sa', barColor: Color(0xFFE63946)),
    XylophoneKeyModel(midiNote: 62, noteName: 'D4', sargamName: 'Re', barColor: Color(0xFFF77F00)),
    XylophoneKeyModel(midiNote: 64, noteName: 'E4', sargamName: 'Ga', barColor: Color(0xFFFFB703)),
    XylophoneKeyModel(midiNote: 65, noteName: 'F4', sargamName: 'Ma', barColor: Color(0xFF52B788)),
    XylophoneKeyModel(midiNote: 67, noteName: 'G4', sargamName: 'Pa', barColor: Color(0xFF2CB67D)),
    XylophoneKeyModel(midiNote: 69, noteName: 'A4', sargamName: 'Dha', barColor: Color(0xFF00E5FF)),
    XylophoneKeyModel(midiNote: 71, noteName: 'B4', sargamName: 'Ni', barColor: Color(0xFF0083B0)),
    XylophoneKeyModel(midiNote: 72, noteName: 'C5', sargamName: 'Sa\'', barColor: Color(0xFF7F5AF0)),
    XylophoneKeyModel(midiNote: 74, noteName: 'D5', sargamName: 'Re\'', barColor: Color(0xFFB5179E)),
    XylophoneKeyModel(midiNote: 76, noteName: 'E5', sargamName: 'Ga\'', barColor: Color(0xFFE53170)),
    XylophoneKeyModel(midiNote: 77, noteName: 'F5', sargamName: 'Ma\'', barColor: Color(0xFFFF477E)),
    XylophoneKeyModel(midiNote: 79, noteName: 'G5', sargamName: 'Pa\'', barColor: Color(0xFFFF70A6)),
    XylophoneKeyModel(midiNote: 81, noteName: 'A5', sargamName: 'Dha\'', barColor: Color(0xFFFF9770)),
    XylophoneKeyModel(midiNote: 83, noteName: 'B5', sargamName: 'Ni\'', barColor: Color(0xFFFFD670)),
    XylophoneKeyModel(midiNote: 84, noteName: 'C6', sargamName: 'Sa\'\'', barColor: Color(0xFFE9FF70)),
  ];
}
