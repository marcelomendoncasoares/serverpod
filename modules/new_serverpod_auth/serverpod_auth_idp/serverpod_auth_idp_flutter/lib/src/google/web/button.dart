import 'package:flutter/material.dart';

import 'wrapper.dart';

// Convenience export of the button configuration enums.
export 'wrapper.dart'
    show
        GSIButtonType,
        GSIButtonTheme,
        GSIButtonSize,
        GSIButtonText,
        GSIButtonShape,
        GSIButtonLogoAlignment;

/// A widget that renders the Google Sign-In button for web.
class GoogleSignInWebButton extends StatelessWidget {
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
  /// If not set, the browser's default locale or the Google session user's
  /// preference is used.
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
  final Widget Function(GoogleSignInStyle style, Widget child)? buttonWrapper;

  /// Creates a Google Sign-In button for web.
  const GoogleSignInWebButton({
    this.type = GSIButtonType.standard,
    this.theme = GSIButtonTheme.outline,
    this.size = GSIButtonSize.large,
    this.text = GSIButtonText.continueWith,
    this.shape = GSIButtonShape.pill,
    this.logoAlignment = GSIButtonLogoAlignment.left,
    this.minimumWidth = 240,
    this.locale,
    this.buttonWrapper = wrapAsMaterial,
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
  factory GoogleSignInWebButton.icon() =>
      GoogleSignInWebButton(type: GSIButtonType.icon);

  /// Builds Google Sign-In button compatible with Material's filled button.
  factory GoogleSignInWebButton.filled({
    GSIButtonTheme theme = GSIButtonTheme.outline,
    GSIButtonSize size = GSIButtonSize.large,
    GSIButtonText text = GSIButtonText.continueWith,
    GSIButtonShape shape = GSIButtonShape.pill,
    GSIButtonLogoAlignment logoAlignment = GSIButtonLogoAlignment.left,
    double minimumWidth = 240,
  }) =>
      GoogleSignInWebButton(
        theme: theme,
        size: size,
        text: text,
        shape: shape,
        logoAlignment: logoAlignment,
        minimumWidth: minimumWidth,
        buttonWrapper: wrapAsFilledButton,
      );

  /// Builds Google Sign-In button compatible with Material's outline button.
  factory GoogleSignInWebButton.outlined({
    GSIButtonSize size = GSIButtonSize.large,
    GSIButtonText text = GSIButtonText.continueWith,
    GSIButtonShape shape = GSIButtonShape.pill,
    GSIButtonLogoAlignment logoAlignment = GSIButtonLogoAlignment.left,
    double minimumWidth = 240,
  }) =>
      GoogleSignInWebButton(
        theme: GSIButtonTheme.outline,
        size: size,
        text: text,
        shape: shape,
        logoAlignment: logoAlignment,
        minimumWidth: minimumWidth,
        buttonWrapper: wrapAsMaterial,
      );

  /// Builds Google Sign-In button compatible with Material's elevated button.
  factory GoogleSignInWebButton.elevated({
    GSIButtonTheme theme = GSIButtonTheme.outline,
    GSIButtonSize size = GSIButtonSize.large,
    GSIButtonText text = GSIButtonText.continueWith,
    GSIButtonShape shape = GSIButtonShape.pill,
    GSIButtonLogoAlignment logoAlignment = GSIButtonLogoAlignment.left,
    double minimumWidth = 240,
  }) =>
      GoogleSignInWebButton(
        theme: theme,
        size: size,
        text: text,
        shape: shape,
        logoAlignment: logoAlignment,
        minimumWidth: minimumWidth,
        buttonWrapper: wrapAsElevatedButton,
      );

  /// Wraps the button to match Material's default button style.
  static Widget wrapAsMaterial(GoogleSignInStyle style, Widget child) {
    return Material(
      borderRadius: style.borderRadius,
      clipBehavior: Clip.antiAlias,
      child: Container(
        alignment: Alignment.center,
        color: style.backgroundColor,
        width: style.size.width,
        height: style.size.height,
        child: child,
      ),
    );
  }

  /// Wraps the button to match Material's filled button style.
  static Widget wrapAsFilledButton(GoogleSignInStyle style, Widget child) {
    return FilledButton(
      onPressed: () {},
      style: FilledButton.styleFrom(
        padding: EdgeInsets.zero,
        fixedSize: style.size,
        backgroundColor: style.backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: style.borderRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }

  /// Wraps the button to match Material's elevated button style.
  static Widget wrapAsElevatedButton(GoogleSignInStyle style, Widget child) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        fixedSize: style.size,
        backgroundColor: style.backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: style.borderRadius),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }

  /// Render the button with the actual width.
  Widget _renderButton({double? width}) => renderButton(
        configuration: GSIButtonConfiguration(
          type: type,
          theme: theme,
          size: size,
          text: text,
          shape: shape,
          logoAlignment: logoAlignment,
          minimumWidth: width ?? minimumWidth,
          locale: locale,
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (type == GSIButtonType.icon) {
      return _renderButton();
    }

    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth.clamp(minimumWidth, 400).toDouble();

      final buttonStyle = GoogleSignInStyle.fromConfiguration(
        theme: theme,
        shape: shape,
        size: size,
        width: width,
      );

      final button = _renderButton(width: width);
      return buttonWrapper?.call(buttonStyle, button) ?? button;
    });
  }
}

/// The style of the rendered Google button.
class GoogleSignInStyle {
  final Size size;
  final Color backgroundColor;
  final BorderRadius borderRadius;

  /// Creates a [GoogleSignInStyle] with the given properties.
  const GoogleSignInStyle({
    required this.size,
    required this.backgroundColor,
    required this.borderRadius,
  });

  /// Creates a [GoogleSignInStyle] from the button configuration.
  ///
  /// Values are translated from the enum values to actual style properties
  /// using the Google Sign-In documentation as reference.
  factory GoogleSignInStyle.fromConfiguration({
    required GSIButtonTheme theme,
    required GSIButtonShape shape,
    required GSIButtonSize size,
    required double width,
  }) {
    final height = switch (size) {
      GSIButtonSize.large => 40.0,
      GSIButtonSize.medium => 32.0,
      GSIButtonSize.small => 20.0,
    };

    return GoogleSignInStyle(
      size: Size(width, height),
      backgroundColor: switch (theme) {
        GSIButtonTheme.outline => Colors.white,
        GSIButtonTheme.filledBlue => Colors.blue,
        GSIButtonTheme.filledBlack => Colors.black,
      },
      borderRadius: switch (shape) {
        GSIButtonShape.rectangular => BorderRadius.circular(4),
        GSIButtonShape.pill => BorderRadius.circular(height / 2),
      },
    );
  }
}
