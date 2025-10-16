import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A helper class to declare the widgets used in the sign in with email flow.
///
/// Can be used to create a custom sign in with email flow that reuses the basic
/// components.
mixin BaseAuthScreenWidgets {
  /// Whether is there a request in progress.
  bool get isLoading;

  /// The current request error message, if any.
  String? get errorMessage;

  /// A gap to use between related widgets.
  Widget get smallGap => const SizedBox(height: 16);

  /// A gap to use between unrelated widgets.
  Widget get largeGap => const SizedBox(height: 24);

  /// A widget to show when a request is in progress.
  Widget get loadingWidget => const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );

  /// Returns a list of widgets to display an error message.
  List<Widget> get errorWidgets {
    final errorMessage = this.errorMessage;
    if (errorMessage == null) return [];

    return [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          errorMessage,
          style: TextStyle(color: Colors.red.shade900),
        ),
      ),
      smallGap,
    ];
  }

  /// Returns a standard text field widget.
  TextField createTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    String? hintText,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        hintText: hintText,
      ),
      keyboardType: keyboardType,
      enabled: !isLoading,
    );
  }

  /// Returns a standard action button widget.
  Widget createActionButton({
    required VoidCallback onPressed,
    required String label,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        shape: StadiumBorder(),
      ),
      onPressed: isLoading ? null : onPressed,
      child: isLoading ? loadingWidget : Text(label),
    );
  }

  /// Returns a standard text button widget.
  Widget createTextButton({
    required VoidCallback onPressed,
    required String label,
  }) {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      child: Text(label),
    );
  }

  /// Returns a standard paste-from-clipboard button.
  Widget createPasteFromClipboardButton({
    required Function(String text) onPaste,
  }) =>
      IconButton(
        onPressed: () async {
          final data = await Clipboard.getData('text/plain');
          final text = data?.text;
          if (text != null) onPaste(text);
        },
        icon: const Icon(Icons.paste),
        color: Colors.grey[400],
        tooltip: 'Paste from clipboard',
      );

  /// Returns a standard page scaffold.
  Widget createPage({
    required String title,
    required List<Widget> pageWidgets,
    required VoidCallback onClose,
  }) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: onClose,
        ),
        title: Text(title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...errorWidgets,
              ...pageWidgets,
            ],
          ),
        ),
      ),
    );
  }
}
