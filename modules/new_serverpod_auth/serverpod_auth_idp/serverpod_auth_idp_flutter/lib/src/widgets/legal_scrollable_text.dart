import 'package:flutter/material.dart';

/// This class is used to display the terms and conditions and privacy policy.
///
/// It can be used as a starting point, but it is recommended to serve the
/// terms and conditions and privacy policy from a web server instead of using
/// a widget. Since such documents are often long and complex, and may change
/// frequently to comply with legal requirements, it is a best practice to not
/// have them locally in the app.
class LegalScrollableTextWidget extends StatelessWidget {
  final String title;
  final String text;

  const LegalScrollableTextWidget({
    super.key,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'monospace',
                    color: Theme.of(context).textTheme.bodySmall!.color,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
