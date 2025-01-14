import 'package:flutter/material.dart';

class TranscriptionDisplay extends StatelessWidget {
  final String transcription;
  final String label;
  final TextStyle? labelStyle;
  final TextStyle? transcriptionStyle;
  final bool truncate; // Whether to truncate long text
  final int maxLines;  // Max lines to show before truncating

  const TranscriptionDisplay({
    super.key,
    required this.transcription,
    this.label = 'Transcription:',
    this.labelStyle,
    this.transcriptionStyle,
    this.truncate = false,
    this.maxLines = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: labelStyle ??
              const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          transcription,
          style: transcriptionStyle ??
              const TextStyle(
                fontSize: 14,
              ),
          overflow: truncate ? TextOverflow.ellipsis : TextOverflow.visible,
          maxLines: truncate ? maxLines : null,
        ),
      ],
    );
  }
}
