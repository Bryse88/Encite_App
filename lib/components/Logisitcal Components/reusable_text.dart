import 'package:flutter/material.dart';

class ResuableText extends StatelessWidget {
  const ResuableText(
      {super.key, required this.text, required this.style, this.maxLines});

  final String text;
  final TextStyle style;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        maxLines: maxLines ?? 1,
        softWrap: true,
        textAlign: TextAlign.left,
        style: style,
        overflow: TextOverflow.ellipsis);
  }
}
