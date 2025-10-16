import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import 'mock_client.dart';

final client = Client('http://localhost:8080/')
  ..authSessionManager = ClientAuthSessionManager();

void main() {
  runApp(const ExampleApp());
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

    client.auth.authInfo.addListener(() {
      setState(() {
        _isSignedIn = client.auth.isAuthenticated;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      client.auth.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        colorScheme: const ColorScheme.light(
          surface: Colors.white,
          primary: Colors.black,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: _isSignedIn ? _connectedScreen() : _signInScreen(),
    );
  }

  Widget _connectedScreen() {
    return ConnectedScreen(
      onSignOut: () async {
        await client.auth.signOutDevice();
        setState(() {
          _isSignedIn = false;
        });
      },
    );
  }

  Widget _signInScreen() {
    return SignInWithEmailPage(
      client: client,
      onAuthenticated: () {
        setState(() {
          _isSignedIn = true;
        });
      },
    );
  }
}

class ConnectedScreen extends StatelessWidget {
  const ConnectedScreen({
    required this.onSignOut,
    super.key,
  });

  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          spacing: 20,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You are connected'),
            FilledButton(
              onPressed: onSignOut,
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}
