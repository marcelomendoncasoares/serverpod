import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:serverpod_auth_idp_flutter/widgets.dart';

import 'mock_client.dart';

final client = Client('http://localhost:8080/')
  ..authSessionManager = ClientAuthSessionManager();

void main() {
  client.auth.initialize();

  runApp(
    MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        colorScheme: const ColorScheme.light(
          surface: Colors.white,
          primary: Colors.black,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const ExampleApp(),
    ),
  );
}

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  bool _isSignedIn = false;

  @override
  void initState() {
    super.initState();

    // NOTE: This is the only required setState to ensure that the  UI gets
    // updated when the auth state changes.
    client.auth.authInfo.addListener(() {
      setState(() {
        _isSignedIn = client.auth.isAuthenticated;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isSignedIn ? _connectedScreen() : _signInScreen();
  }

  Widget _connectedScreen() {
    return const ConnectedScreen();
  }

  Widget _signInScreen() {
    return Scaffold(
      body: SignInWidget(
        client: client,
        // NOTE: No need to call navigation here if it gets done on the
        // client.auth.authInfo listener.
        onAuthenticated: () {
          context.showSnackBar(
            message: 'User authenticated.',
            backgroundColor: Colors.green,
          );
        },
        onError: (error) {
          context.showSnackBar(
            message: 'Authentication failed: $error',
            backgroundColor: Colors.red,
          );
        },
      ),
    );
  }
}

class ConnectedScreen extends StatelessWidget {
  const ConnectedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          spacing: 16,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const ProfileWidget(),
            const Text('You are connected'),
            FilledButton(
              onPressed: client.auth.signOutDevice,
              child: const Text('Sign out'),
            ),
            if (client.auth.idp.hasGoogle)
              FilledButton(
                onPressed: client.auth.disconnectGoogleAccount,
                child: const Text('Disconnect Google'),
              ),
          ],
        ),
      ),
    );
  }
}

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  UserProfileModel? _userProfile;

  @override
  void initState() {
    super.initState();

    client.modules.auth.userProfileInfo.get().then((profile) {
      if (!mounted) return;
      setState(() {
        _userProfile = profile;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ProfilePictureWidget(
          userProfile: _userProfile,
          size: 100,
          elevation: 4,
          borderWidth: 2,
          borderColor: Colors.white,
        ),
        if (_userProfile == null) ...[
          const Opacity(
            opacity: 0.8,
            child: SizedBox(
              width: 100,
              height: 100,
              child: Material(
                shape: CircleBorder(),
                color: Colors.white,
                clipBehavior: Clip.antiAlias,
              ),
            ),
          ),
          const CircularProgressIndicator(),
        ],
      ],
    );
  }
}

extension on BuildContext {
  void showSnackBar({
    required String message,
    Color? backgroundColor,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 5),
      ),
    );
  }
}
