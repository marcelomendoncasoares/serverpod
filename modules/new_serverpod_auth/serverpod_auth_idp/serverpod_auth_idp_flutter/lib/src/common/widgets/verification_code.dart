import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';

import '../../theme.dart';
import 'buttons/paste_from_clipboard_button.dart';

/// A widget for inputting verification codes.
class VerificationCodeInput extends StatefulWidget {
  final TextEditingController verificationCodeController;
  final VoidCallback onCompleted;
  final bool isLoading;
  final int length;

  /// Creates a verification code input field.
  const VerificationCodeInput({
    super.key,
    required this.onCompleted,
    required this.verificationCodeController,
    required this.isLoading,
    this.length = 6,
  });

  @override
  State<VerificationCodeInput> createState() => _VerificationCodeInputState();
}

class _VerificationCodeInputState extends State<VerificationCodeInput> {
  late FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemWidth = MediaQuery.of(context).size.width / (widget.length + 3);

    final idpTheme = Theme.of(context).idpTheme;
    final defaultPinTheme = idpTheme.defaultPinTheme.copyWith(width: itemWidth);
    final focusedPinTheme = idpTheme.focusedPinTheme.copyWith(width: itemWidth);
    final errorPinTheme = idpTheme.errorPinTheme.copyWith(width: itemWidth);

    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyV):
            const PasteTextIntent(SelectionChangedCause.keyboard),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          PasteTextIntent:
              CallbackAction<PasteTextIntent>(onInvoke: (intent) async {
            final data = await Clipboard.getData('text/plain');
            final text = data?.text;
            if (text != null) {
              setState(() {
                widget.verificationCodeController.text = text;
              });
            }
            return null;
          }),
        },
        child: Container(
          height: 70,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Pinput(
                controller: widget.verificationCodeController,
                length: widget.length,
                showCursor: false,
                keyboardType: TextInputType.text,
                autofocus: true,
                enabled: !widget.isLoading,
                focusNode: focusNode,
                defaultPinTheme: defaultPinTheme,
                onCompleted: (_) => widget.onCompleted(),
                focusedPinTheme: focusedPinTheme,
                errorPinTheme: errorPinTheme,
              ),
              const SizedBox(width: 16),
              PasteFromClipboardButton(onPaste: (text) {
                setState(() {
                  widget.verificationCodeController.text = text;
                });
              }),
            ],
          ),
        ),
      ),
    );
  }
}
