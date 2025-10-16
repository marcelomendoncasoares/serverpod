import 'package:flutter/material.dart';
import 'auth_action_button.dart';
import 'auth_error_message.dart';
import 'auth_gaps.dart' as gaps;
import 'auth_loading_indicator.dart';
import 'auth_page_scaffold.dart';
import 'auth_text_button.dart';
import 'auth_text_field.dart';
import 'paste_from_clipboard_button.dart';

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
  Widget get smallGap => gaps.smallGap;

  /// A gap to use between unrelated widgets.
  Widget get largeGap => gaps.largeGap;

  /// A widget to show when a request is in progress.
  Widget get loadingWidget => const AuthLoadingIndicator();

  /// Returns a list of widgets to display an error message.
  List<Widget> get errorWidgets {
    final errorMessage = this.errorMessage;
    if (errorMessage == null) return [];

    return [
      AuthErrorMessage(errorMessage: errorMessage),
      smallGap,
    ];
  }

  /// Returns a standard text field widget.
  Widget createTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    String? hintText,
  }) {
    return AuthTextField(
      controller: controller,
      labelText: labelText,
      keyboardType: keyboardType,
      hintText: hintText,
      isLoading: isLoading,
    );
  }

  /// Returns a standard action button widget.
  Widget createActionButton({
    required VoidCallback onPressed,
    required String label,
  }) {
    return AuthActionButton(
      onPressed: onPressed,
      label: label,
      isLoading: isLoading,
    );
  }

  /// Returns a standard text button widget.
  Widget createTextButton({
    required VoidCallback onPressed,
    required String label,
  }) {
    return AuthTextButton(
      onPressed: onPressed,
      label: label,
      isLoading: isLoading,
    );
  }

  /// Returns a standard paste-from-clipboard button.
  Widget createPasteFromClipboardButton({
    required Function(String text) onPaste,
  }) {
    return PasteFromClipboardButton(onPaste: onPaste);
  }

  /// Returns a standard page scaffold.
  Widget createPage({
    required String title,
    required List<Widget> pageWidgets,
    required VoidCallback onClose,
  }) {
    return AuthPageScaffold(
      title: title,
      pageWidgets: pageWidgets,
      onClose: onClose,
      errorMessage: errorMessage,
    );
  }
}
