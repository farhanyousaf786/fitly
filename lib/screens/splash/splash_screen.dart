import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/local/shared_prefs_service.dart';
import 'widgets/animated_logo.dart';
import 'widgets/app_title.dart';
import 'widgets/loading_indicator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _configureSystemUI();
    _initializeApp();
  }

  void _configureSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize shared preferences
      await SharedPrefsService.init();

      // Wait for animations to complete
      await Future.delayed(const Duration(milliseconds: 2000));

      if (!mounted) return;

      // Check authentication state
      final authProvider = context.read<AuthProvider>();
      final userProvider = context.read<UserProvider>();

      if (authProvider.isAuthenticated) {
        // User is authenticated, load their data
        final userId = authProvider.currentUserId;
        if (userId != null) {
          await userProvider.loadUserProfile(userId);
          await userProvider.loadUserConfig(userId);
        }
        _navigateToHome();
      } else {
        // Check if it's first launch
        final isFirstLaunch = SharedPrefsService.getIsFirstLaunch();
        if (isFirstLaunch) {
          _navigateToOnboarding();
        } else {
          _navigateToAuth();
        }
      }
    } catch (e) {
      // Handle error and navigate to auth screen
      if (mounted) {
        _navigateToAuth();
      }
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
  }

  void _navigateToAuth() {
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  void _navigateToOnboarding() {
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil('/onboarding-slides', (route) => false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Logo
              const AnimatedLogo(),

              const SizedBox(height: 40),

              // App Title
              const AppTitle(),

              const SizedBox(height: 60),

              // Loading Indicator
              const SplashLoadingIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
