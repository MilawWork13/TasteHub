import 'package:flutter/material.dart';

// Process the text and return a list of text spans for AI dialog
List<TextSpan> processText(String text) {
  final RegExp boldPattern = RegExp(r'\*\*(.*?)\*\*');
  final List<TextSpan> spans = [];
  int start = 0;

  for (final match in boldPattern.allMatches(text)) {
    if (match.start > start) {
      spans.add(TextSpan(text: text.substring(start, match.start)));
    }
    spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(fontWeight: FontWeight.bold)));
    start = match.end;
  }
  if (start < text.length) {
    spans.add(TextSpan(text: text.substring(start)));
  }

  return spans;
}
