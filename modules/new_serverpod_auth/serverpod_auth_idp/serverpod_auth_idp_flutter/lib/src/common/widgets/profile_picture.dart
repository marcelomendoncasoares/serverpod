import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart';

/// A circular image that represents a user, based on a [UserProfileModel]. If
/// the user info is missing a link to an image, a default gray circle with a
/// user icon is used. The image is cached between sessions. The image can be
/// drawn with an optional border and be elevated.
class ProfilePictureWidget extends StatelessWidget {
  /// The [UserProfileModel] to fetch the image from.
  final UserProfileModel? userProfile;

  /// The size of the user image. Defaults to 20.
  final double size;

  /// Elevation of the user image. Defaults to 0.
  final double elevation;

  /// The width of the user image's border. Defaults to 0.
  final double borderWidth;

  /// The color of the user image's border. Only used if the [borderWidth] is
  /// non-zero. Defaults to white.
  final Color borderColor;

  /// The shape of the user image. Defaults to a circle.
  final OutlinedBorder shape;

  /// Creates a circular image that represents a user.
  const ProfilePictureWidget({
    this.userProfile,
    this.size = 20.0,
    this.elevation = 0,
    this.borderColor = Colors.white,
    this.borderWidth = 0,
    this.shape = const CircleBorder(),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = userProfile?.imageUrl;
    final child = (imageUrl != null)
        ? ExtendedImage.network(imageUrl.toString())
        : Center(
            child: Icon(
              Icons.account_circle,
              size: size - borderWidth * 2,
              color: Colors.white,
            ),
          );

    if (borderWidth == 0) {
      return SizedBox(
        width: size,
        height: size,
        child: Material(
          elevation: elevation,
          shape: shape,
          color: Colors.grey[500],
          clipBehavior: Clip.antiAlias,
          child: child,
        ),
      );
    } else {
      return SizedBox(
        width: size,
        height: size,
        child: Material(
          elevation: elevation,
          shape: shape,
          color: borderColor,
          clipBehavior: Clip.none,
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[500],
              ),
              clipBehavior: Clip.antiAlias,
              width: size - borderWidth * 2,
              height: size - borderWidth * 2,
              child: child,
            ),
          ),
        ),
      );
    }
  }
}
