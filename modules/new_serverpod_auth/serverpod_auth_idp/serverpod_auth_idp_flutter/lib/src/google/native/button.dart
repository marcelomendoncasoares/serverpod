import 'package:flutter/material.dart';

import '../web/button.dart';
import 'icon.dart';

// Convenience export of the button configuration enums and style class.
export '../web/button.dart'
    show
        GoogleSignInStyle,
        GSIButtonType,
        GSIButtonTheme,
        GSIButtonSize,
        GSIButtonText,
        GSIButtonShape,
        GSIButtonLogoAlignment;

/// A styled button for Google Sign-In on native platforms.
class GoogleSignInNativeButton extends StatelessWidget {
  /// Callback when the button is pressed.
  final VoidCallback? onPressed;

  /// Whether the button is currently loading.
  final bool isLoading;

  /// Whether the button is disabled.
  final bool isDisabled;

  /// The button type: icon, or standard button.
  final GSIButtonType type;

  /// The button theme.
  ///
  /// For example, filledBlue or filledBlack.
  final GSIButtonTheme theme;

  /// The button size.
  ///
  /// For example, small or large.
  final GSIButtonSize size;

  /// The button text.
  ///
  /// For example "Sign in with Google" or "Sign up with Google".
  final GSIButtonText text;

  /// The button shape.
  ///
  /// For example, rectangular or circular.
  final GSIButtonShape shape;

  /// The Google logo alignment: left or center.
  final GSIButtonLogoAlignment logoAlignment;

  /// The minimum button width, in pixels.
  ///
  /// The maximum width is 400 pixels.
  final double minimumWidth;

  /// The pre-set locale of the button text.
  ///
  /// If not set, the device's default locale is used.
  ///
  /// Different users might see different versions of localized buttons, possibly
  /// with different sizes.
  final String? locale;

  /// A wrapper function to the rendered button to ensure style consistency.
  ///
  /// This wrapper ensures the consistency of the rendered button with the rest
  /// of the application. Since the render configuration is done through enum
  /// values, the wrapper will be called with a [GoogleSignInStyle] object that
  /// translates the enum values to actual style properties. The [Widget] is the
  /// rendered Google button that should be wrapped.
  ///
  /// Be mindful that creating the button with no wrapper will also result in a
  /// dangling "Getting ready..." text that is returned while the iFrame is
  /// being built.
  final Widget Function(
    GoogleSignInStyle style,
    VoidCallback? onPressed,
    Widget child,
  )? buttonWrapper;

  /// Creates a Google Sign-In button for native platforms.
  const GoogleSignInNativeButton({
    required this.onPressed,
    required this.isLoading,
    required this.isDisabled,
    this.type = GSIButtonType.standard,
    this.theme = GSIButtonTheme.outline,
    this.size = GSIButtonSize.large,
    this.text = GSIButtonText.continueWith,
    this.shape = GSIButtonShape.pill,
    this.logoAlignment = GSIButtonLogoAlignment.left,
    this.minimumWidth = 240,
    this.locale,
    this.buttonWrapper = wrapAsOutline,
    super.key,
  })  : assert(
          minimumWidth > 0 && minimumWidth <= 400,
          'Invalid minimumWidth. Must be between 0 and 400.',
        ),
        assert(
          size != GSIButtonSize.small,
          'Small size is disabled due to Android Material and iOS Human '
          'Interface design guidelines regarding minimum target size. Use '
          'medium or large instead.',
        );

  /// Builds Google Sign-In button with the icon type.
  factory GoogleSignInNativeButton.icon({
    required VoidCallback? onPressed,
    required bool isLoading,
    required bool isDisabled,
  }) =>
      GoogleSignInNativeButton(
        onPressed: onPressed,
        isLoading: isLoading,
        isDisabled: isDisabled,
        type: GSIButtonType.icon,
      );

  /// Builds Google Sign-In button compatible with Material's filled button.
  factory GoogleSignInNativeButton.filled({
    required VoidCallback onPressed,
    required bool isLoading,
    required bool isDisabled,
    GSIButtonTheme theme = GSIButtonTheme.outline,
    GSIButtonSize size = GSIButtonSize.large,
    GSIButtonText text = GSIButtonText.continueWith,
    GSIButtonShape shape = GSIButtonShape.pill,
    GSIButtonLogoAlignment logoAlignment = GSIButtonLogoAlignment.left,
    double minimumWidth = 240,
  }) =>
      GoogleSignInNativeButton(
        onPressed: onPressed,
        isLoading: isLoading,
        isDisabled: isDisabled,
        theme: theme,
        size: size,
        text: text,
        shape: shape,
        logoAlignment: logoAlignment,
        minimumWidth: minimumWidth,
        buttonWrapper: wrapAsFilled,
      );

  /// Builds Google Sign-In button compatible with Material's outline button.
  factory GoogleSignInNativeButton.outlined({
    required VoidCallback onPressed,
    required bool isLoading,
    required bool isDisabled,
    GSIButtonSize size = GSIButtonSize.large,
    GSIButtonText text = GSIButtonText.continueWith,
    GSIButtonShape shape = GSIButtonShape.pill,
    GSIButtonLogoAlignment logoAlignment = GSIButtonLogoAlignment.left,
    double minimumWidth = 240,
  }) =>
      GoogleSignInNativeButton(
        onPressed: onPressed,
        isLoading: isLoading,
        isDisabled: isDisabled,
        theme: GSIButtonTheme.outline,
        size: size,
        text: text,
        shape: shape,
        logoAlignment: logoAlignment,
        minimumWidth: minimumWidth,
        buttonWrapper: wrapAsOutline,
      );

  /// Builds Google Sign-In button compatible with Material's elevated button.
  factory GoogleSignInNativeButton.elevated({
    required VoidCallback onPressed,
    required bool isLoading,
    required bool isDisabled,
    GSIButtonTheme theme = GSIButtonTheme.outline,
    GSIButtonSize size = GSIButtonSize.large,
    GSIButtonText text = GSIButtonText.continueWith,
    GSIButtonShape shape = GSIButtonShape.pill,
    GSIButtonLogoAlignment logoAlignment = GSIButtonLogoAlignment.left,
    double minimumWidth = 240,
  }) =>
      GoogleSignInNativeButton(
        onPressed: onPressed,
        isLoading: isLoading,
        isDisabled: isDisabled,
        theme: theme,
        size: size,
        text: text,
        shape: shape,
        logoAlignment: logoAlignment,
        minimumWidth: minimumWidth,
        buttonWrapper: wrapAsElevated,
      );

  /// Wraps the button to match Material's outlined button style.
  static Widget wrapAsOutline(
    GoogleSignInStyle style,
    VoidCallback? onPressed,
    Widget child,
  ) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: style.backgroundColor,
        foregroundColor: style.foregroundColor,
        side: BorderSide(color: Colors.grey[300]!, width: 1),
        shape: RoundedRectangleBorder(borderRadius: style.borderRadius),
        padding: EdgeInsets.zero,
      ),
      child: child,
    );
  }

  /// Wraps the button to match Material's filled button style.
  static Widget wrapAsFilled(
    GoogleSignInStyle style,
    VoidCallback? onPressed,
    Widget child,
  ) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: style.backgroundColor,
        foregroundColor: style.foregroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: style.borderRadius,
          side: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        padding: EdgeInsets.zero,
      ),
      child: child,
    );
  }

  /// Wraps the button to match Material's elevated button style.
  static Widget wrapAsElevated(
    GoogleSignInStyle style,
    VoidCallback? onPressed,
    Widget child,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: style.backgroundColor,
        foregroundColor: style.foregroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: style.borderRadius,
          side: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        padding: EdgeInsets.zero,
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttonStyle = GoogleSignInStyle.fromConfiguration(
      theme: theme,
      shape: shape,
      size: size,
      width: minimumWidth,
    );

    if (type == GSIButtonType.icon) {
      return SizedBox(
        width: buttonStyle.size.height,
        height: buttonStyle.size.height,
        child: OutlinedButton(
          onPressed: isDisabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.grey[300]!, width: 1),
            shape: CircleBorder(),
            padding: EdgeInsets.zero,
          ),
          child: GoogleSignInIcon(
            isLoading: isLoading,
            isDisabled: isDisabled,
          ),
        ),
      );
    }

    // NOTE: Styled according to official guidelines.
    // https://developers.google.com/identity/branding-guidelines#padding
    final buttonContents = Stack(
      children: [
        if (logoAlignment == GSIButtonLogoAlignment.center)
          Center(
            child: Padding(
              padding: _getPadding(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GoogleSignInIcon(
                    isLoading: isLoading,
                    isDisabled: isDisabled,
                  ),
                  const SizedBox(width: 8),
                  Text(_getButtonText()),
                ],
              ),
            ),
          )
        else ...[
          Center(
            child: Padding(
              padding: _getPadding(),
              child: Text(_getButtonText()),
            ),
          ),
          Positioned(
            left: 12,
            top: 0,
            bottom: 0,
            child: GoogleSignInIcon(
              isLoading: isLoading,
              isDisabled: isDisabled,
            ),
          ),
        ],
      ],
    );

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minimumWidth,
        maxWidth: 400,
        minHeight: buttonStyle.size.height,
        maxHeight: buttonStyle.size.height,
      ),
      child: buttonWrapper?.call(
            buttonStyle,
            isDisabled ? null : onPressed,
            buttonContents,
          ) ??
          buttonContents,
    );
  }

  String _getButtonText() {
    if (isLoading) return 'Signing in...';

    // Use locale-specific text if provided
    // For now, we'll use English defaults
    // TODO: Implement proper localization based on locale parameter
    return switch (text) {
      GSIButtonText.signinWith => 'Sign in with Google',
      GSIButtonText.signupWith => 'Sign up with Google',
      GSIButtonText.continueWith => 'Continue with Google',
      GSIButtonText.signin => 'Sign in',
    };
  }

  EdgeInsets _getPadding() {
    return switch (size) {
      GSIButtonSize.large => const EdgeInsets.symmetric(vertical: 10),
      GSIButtonSize.medium => const EdgeInsets.symmetric(vertical: 6),
      GSIButtonSize.small => const EdgeInsets.symmetric(vertical: 4),
    };
  }
}
