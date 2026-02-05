import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/onboarding_provider.dart';
import 'services/firebase/auth_service.dart';
import 'services/firebase/firestore_service.dart';
import 'services/api/ai_service.dart';
import 'services/api/conversation_manager.dart';
import 'services/local/shared_prefs_service.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/onboarding/onboarding_slides_screen.dart';
import 'screens/onboarding/ai_chat_screen.dart';
import 'screens/onboarding/plan_summary_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SharedPrefsService.init();
  runApp(const FitlyApp());
}

class FitlyApp extends StatelessWidget {
  const FitlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<FirestoreService>(create: (_) => FirestoreService()),
        Provider<AiService>(create: (_) => AiService()),
        Provider<SharedPrefsService>(create: (_) => SharedPrefsService()),
        Provider<ConversationManager>(create: (_) => ConversationManager()),

        // Providers
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            authService: context.read<AuthService>(),
            firestoreService: context.read<FirestoreService>(),
          ),
        ),
        ChangeNotifierProvider<UserProvider>(
          create: (context) => UserProvider(
            firestoreService: context.read<FirestoreService>(),
            sharedPrefsService: context.read<SharedPrefsService>(),
          ),
        ),
        ChangeNotifierProvider<OnboardingProvider>(
          create: (context) => OnboardingProvider(
            userProvider: context.read<UserProvider>(),
            aiService: context.read<AiService>(),
            conversationManager: context.read<ConversationManager>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Fitly',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/onboarding-slides': (context) => const OnboardingSlidesScreen(),
          '/ai-chat': (context) => const AiChatScreen(),
          '/plan-summary': (context) => const PlanSummaryScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitly'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 100, color: Color(0xFF2196F3)),
            SizedBox(height: 20),
            Text(
              'Welcome to Fitly!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Your AI Fitness Coach',
              style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
            ),
            SizedBox(height: 40),
            Text(
              'App setup complete! 🎉',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF10B981),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
