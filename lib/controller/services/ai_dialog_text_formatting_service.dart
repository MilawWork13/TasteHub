import 'package:flutter/material.dart';

List<TextSpan> processText(String text) {
  final RegExp boldPattern = RegExp(r'\*\*(.*?)\*\*');
  final List<TextSpan> spans = [];
  int start = 0;

  for (final match in boldPattern.allMatches(text)) {
    // Add non-bold text before the bold match
    if (match.start > start) {
      spans.add(TextSpan(text: text.substring(start, match.start)));
    }
    // Add bold text
    spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(fontWeight: FontWeight.bold)));
    start = match.end;
  }
  // Add any remaining non-bold text after the last match
  if (start < text.length) {
    spans.add(TextSpan(text: text.substring(start)));
  }

  return spans;
}
