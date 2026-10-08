import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:surjam/features/settings/screens/privacy_policy_screen.dart';

/// Visible text of an HTML document with tags removed and whitespace collapsed.
String _visibleText(String html) {
  return html
      .replaceAll(RegExp(r'<(style|script)[^>]*>.*?</\1>', dotAll: true), ' ')
      .replaceAll(RegExp(r'<!--.*?-->', dotAll: true), ' ')
      .replaceAll(RegExp(r'</?a\b[^>]*>'), '') // links are inline: no extra space
      .replaceAll(RegExp(r'<[^>]+>'), ' ')
      .replaceAll('&amp;', '&')
      .replaceAll(RegExp(r'\s+'), ' ');
}

void main() {
  final html = File('docs/privacy-policy.html').readAsStringSync();
  final text = _visibleText(html);

  test('Web privacy policy has every in-app section, word for word', () {
    for (final (heading, body) in PrivacyPolicyScreen.sections) {
      expect(html, contains('<h2>$heading</h2>'), reason: 'missing heading "$heading"');
      expect(text, contains(body.replaceAll(RegExp(r'\s+'), ' ')), reason: 'section "$heading" differs');
    }
  });

  test('Web privacy policy has no sections the app lacks', () {
    final webHeadings = RegExp(r'<h2>(.*?)</h2>').allMatches(html).map((m) => m.group(1)).toList();
    expect(webHeadings, equals(PrivacyPolicyScreen.sections.map((s) => s.$1).toList()));
  });

  test('Both copies show the same date and contact details', () {
    expect(text, contains('Last updated: ${PrivacyPolicyScreen.lastUpdated}'));
    expect(html, contains('mailto:${PrivacyPolicyScreen.contactEmail}'));
    // GitHub Pages serves docs/ at the site root.
    final publishedFile = PrivacyPolicyScreen.webUrl.split('/').last;
    expect(File('docs/$publishedFile').existsSync(), isTrue);
  });
}
