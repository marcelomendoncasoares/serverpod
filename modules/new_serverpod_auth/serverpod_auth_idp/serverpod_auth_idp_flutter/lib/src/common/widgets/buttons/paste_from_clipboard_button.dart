import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A standard paste-from-clipboard button.
class PasteFromClipboardButton extends StatelessWidget {
  final Function(String text) onPaste;

  const PasteFromClipboardButton({
    required this.onPaste,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        final data = await Clipboard.getData('text/plain');
        final text = data?.text;
        if (text != null) onPaste(text);
      },
      icon: const Icon(Icons.paste),
      color: Colors.grey[400],
      tooltip: 'Paste from clipboard',
    );
  }
}
