import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:green_urban_connect/viewmodel/auth_viewmodel.dart';
import 'package:green_urban_connect/views/screen/auth/signup_screen.dart';
import 'package:green_urban_connect/views/dashboard_screen.dart';
import 'package:green_urban_connect/views/widgets/common/custom_button.dart';
import 'package:green_urban_connect/views/widgets/common/custom_textfield.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login(AuthViewModel authViewModel) async {
    if (_formKey.currentState!.validate()) {
      await authViewModel.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // Check status after sign-in attempt
      // The listener in AuthViewModel will update the status,
      // and the GoRouter redirect or SplashScreen logic should handle navigation.
      if (mounted && authViewModel.status == AuthStatus.authenticated) {
        context.go(DashboardScreen.routeName);
      } else if (mounted && authViewModel.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authViewModel.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Icon(Icons.eco_rounded, size: 80, color: Theme.of(context).primaryColor),
                const SizedBox(height: 16),
                Text(
                  'Welcome Back!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).primaryColorDark
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Log in to Green Urban Connect',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  prefixIcon: Icons.email_outlined,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  prefixIcon: Icons.lock_outline,
                ),
                const SizedBox(height: 24),
                authViewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : CustomButton(
                        text: 'Login',
                        onPressed: () => _login(authViewModel),
                      ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    context.go(SignupScreen.routeName);
                  },
                  child: Text(
                    'Don\'t have an account? Sign Up',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
                // Optionally, add password reset link
                // TextButton(
                //   onPressed: () {
                //     // Navigate to password reset screen
                //   },
                //   child: Text(
                //     'Forgot Password?',
                //     style: TextStyle(color: Colors.grey[600]),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}