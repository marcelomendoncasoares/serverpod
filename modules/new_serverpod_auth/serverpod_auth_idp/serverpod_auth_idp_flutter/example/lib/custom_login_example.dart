import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

/// Example of building a custom login screen using [EmailAuthController].
///
/// This demonstrates how to create your own UI while reusing all the
/// authentication logic from the controller.
class CustomLoginExample extends StatefulWidget {
  const CustomLoginExample({
    super.key,
    required this.client,
  });
  final ServerpodClientShared client;

  @override
  State<CustomLoginExample> createState() => _CustomLoginExampleState();
}

class _CustomLoginExampleState extends State<CustomLoginExample> {
  late final EmailAuthController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EmailAuthController(
      client: widget.client,
      onAuthenticated: () {
        // Navigate to home screen
        // Navigator.of(context).pushReplacement(
        //   MaterialPageRoute(builder: (_) => const HomeScreen()),
        // );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful!')),
        );
      },
    );
    _controller.addListener(_onControllerStateChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerStateChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerStateChanged() {
    final errorMessage = _controller.errorMessage;

    if (errorMessage != null) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }

    // Trigger rebuild to update UI based on new state
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo or title
                  Icon(
                    Icons.lock_outline,
                    size: 64,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome Back',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Email field
                  TextField(
                    controller: _controller.emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    keyboardType: TextInputType.emailAddress,
                    enabled: !_controller.isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  TextField(
                    controller: _controller.passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    obscureText: true,
                    enabled: !_controller.isLoading,
                  ),
                  const SizedBox(height: 24),

                  // Login button
                  ElevatedButton(
                    onPressed: _controller.isLoading ? null : _controller.login,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _controller.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Forgot password link
                  TextButton(
                    onPressed: _controller.isLoading
                        ? null
                        : () {
                            // Navigate to forgot password screen
                          },
                    child: const Text('Forgot Password?'),
                  ),

                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),

                  // Create account link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      TextButton(
                        onPressed: _controller.isLoading
                            ? null
                            : () {
                                // Navigate to registration screen
                              },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Example showing how to use the controller with Provider
///
/// Uncomment this if you're using the Provider package:
///
/// ```dart
/// import 'package:provider/provider.dart';
///
/// // In your app setup:
/// ChangeNotifierProvider(
///   create: (_) => EmailAuthController(client: client),
///   child: const CustomLoginWithProvider(),
/// )
///
/// class CustomLoginWithProvider extends StatelessWidget {
///   const CustomLoginWithProvider({super.key});
///
///   @override
///   Widget build(BuildContext context) {
///     final controller = context.watch<EmailAuthController>();
///
///     return Scaffold(
///       body: Column(
///         children: [
///           TextField(
///             // ... email field
///           ),
///           TextField(
///             // ... password field
///           ),
///           ElevatedButton(
///             onPressed: controller.isLoading ? null : () async {
///               await controller.login(
///                 email: emailController.text,
///                 password: passwordController.text,
///               );
///             },
///             child: controller.isLoading
///                 ? CircularProgressIndicator()
///                 : Text('Login'),
///           ),
///         ],
///       ),
///     );
///   }
/// }
/// ```
