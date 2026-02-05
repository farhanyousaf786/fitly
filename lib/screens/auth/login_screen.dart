import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'widgets/auth_header.dart';
import 'widgets/login_form.dart';
import 'widgets/social_login_buttons.dart';
import 'widgets/auth_footer.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void dispose() {
    super.dispose();
  }

  void _navigateToSignup() {
    Navigator.of(context).pushNamed('/signup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              
              // Header
              const AuthHeader(
                title: 'Welcome Back',
                subtitle: 'Sign in to continue your fitness journey',
              ),
              
              const SizedBox(height: 40),
              
              // Login Form
              const LoginForm(),
              
              const SizedBox(height: 24),
              
              // Sign Up Link
              AuthFooter(
                question: "Don't have an account? ",
                actionText: 'Sign Up',
                onActionPressed: _navigateToSignup,
              ),
              
              const SizedBox(height: 32),
              
              // Social Login Buttons
              const SocialLoginButtons(),
            ],
          ),
        ),
      ),
    );
  }
}
