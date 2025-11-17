import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import 'package:icd0018_hybridmobile_club_managment/views/constants/strings.dart';
import 'package:icd0018_hybridmobile_club_managment/views/constants/app_colors.dart';
import 'package:icd0018_hybridmobile_club_managment/views/authentication/widgets/divider_with_margins.dart';
import 'package:icd0018_hybridmobile_club_managment/views/authentication/validators/validators.dart';
import 'package:icd0018_hybridmobile_club_managment/state/auth/models/auth_result.dart';
import 'package:icd0018_hybridmobile_club_managment/state/auth/models/auth_state.dart';
import 'package:icd0018_hybridmobile_club_managment/state/auth/providers/authentication_provider.dart';
import 'package:icd0018_hybridmobile_club_managment/state/auth/providers/is_logged_in_provider.dart';

class RegisterView extends ConsumerStatefulWidget {
  const RegisterView({super.key});

  @override
  RegisterViewState createState() => RegisterViewState();
}

class RegisterViewState extends ConsumerState<RegisterView> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _attemptRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    await ref.read(authenticationProvider.notifier).registerWithEmailAndPassword(
      name: name,
      email: email,
      password: password,
    );
  }

  Future<void> _attemptGoogleRegister() async {
    await ref.read(authenticationProvider.notifier).loginWithGoogle();
  }

  Future<void> _attemptAppleRegister() async {
    await ref.read(authenticationProvider.notifier).loginWithApple();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authenticationProvider);
    final isLoading = authState.isLoading;

    // Show apple auth on if ios or mac
    final showApple = kIsWeb || defaultTargetPlatform != TargetPlatform.android;

    ref.listen<bool>(isLoggedInProvider, (_, isLoggedIn) {
      if (isLoggedIn && context.mounted) {
        context.pop();
      }
    });

    ref.listen<AuthState>(authenticationProvider, (previous, current) {
      if (!current.isLoading && context.mounted) {
        if (current.result == AuthResult.userAlreadyExists) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User already exists!'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (current.result == AuthResult.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.appName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Text(
                  Strings.signUp,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const DividerWithMargins(20),

                // Name
                TextFormField(
                  controller: _nameController,
                  enabled: !isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: validateName,
                ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailController,
                  enabled: !isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: validateEmail,
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passwordController,
                  enabled: !isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: validatePassword,
                ),
                const SizedBox(height: 16),

                // Register button
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.secondaryColor,
                    foregroundColor: AppColors.loginButtonTextColor,
                  ),
                  onPressed: isLoading ? null : _attemptRegister,
                  child: isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text(
                    'Register',
                    style: TextStyle(color: Colors.white),
                  ),
                ),

                const DividerWithMargins(20),

                // Google
                OutlinedButton.icon(
                  icon: const FaIcon(
                    FontAwesomeIcons.google,
                    color: Colors.red,
                  ),
                  label: const Text('Sign up with Google'),
                  onPressed: isLoading ? null : _attemptGoogleRegister,
                ),
                const SizedBox(height: 10),

                // Apple
                if (showApple)
                  OutlinedButton.icon(
                    icon: const Icon(Icons.apple, size: 24),
                    label: const Text('Sign up with Apple'),
                    onPressed: isLoading ? null : _attemptAppleRegister,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
