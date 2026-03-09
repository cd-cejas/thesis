import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'theme/app_colors.dart';
import 'theme/theme_provider.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/profile_completion_screen.dart';
import 'screens/home_screen.dart';
import 'screens/riasec_test_screen.dart';
import 'screens/ai_chatbot_screen.dart';
import 'screens/riasec_results_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/chat_history_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'AI Guidance',
          theme: themeProvider.isDarkMode ? _darkTheme() : _lightTheme(),
          initialRoute: '/',
          routes: {
            '/': (context) => const LoginScreen(),
            '/signup': (context) => const SignupScreen(),
            '/otp': (context) {
              final args = ModalRoute.of(context)?.settings.arguments as Map?;
              return OtpScreen(
                email: args?['email'] as String? ?? '',
                uid: args?['uid'] as String? ?? '',
              );
            },
            '/forgot_password': (context) => const ForgotPasswordScreen(),
            '/profile_completion': (context) => const ProfileCompletionScreen(),
            '/home': (context) => const HomeScreen(),
          },
          // Tab routes use zoom-scale; detail routes use slide-up.
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/riasec_test':
                return SlideUpPageRoute(
                  settings: settings,
                  builder: (_) => const RiasecTestScreen(),
                );
              case '/ai_chatbot':
                return SlideUpPageRoute(
                  settings: settings,
                  builder: (_) {
                    final args = settings.arguments as Map?;
                    return AiChatbotScreen(
                      profession: args?['profession'] as String?,
                      initialQuery: args?['initialQuery'] as String?,
                      backgroundPrompt: args?['backgroundPrompt'] as String?,
                      autoSend: args?['autoSend'] as bool? ?? false,
                    );
                  },
                );
              case '/riasec_results':
                return SlideUpPageRoute(
                  settings: settings,
                  builder: (_) {
                    final args = settings.arguments as List<int>?;
                    return RiasecResultsScreen(answers: args);
                  },
                );
              case '/profile':
                return ZoomPageRoute(
                  settings: settings,
                  builder: (_) => const ProfileScreen(),
                );
              case '/chat_history':
                return ZoomPageRoute(
                  settings: settings,
                  builder: (_) => const ChatHistoryScreen(),
                );
              case '/notifications':
                return ZoomPageRoute(
                  settings: settings,
                  builder: (_) => const NotificationsScreen(),
                );
              case '/settings':
                return ZoomPageRoute(
                  settings: settings,
                  builder: (_) => const SettingsScreen(),
                );
              default:
                return null;
            }
          },
        );
      },
    );
  }

  ThemeData _darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      fontFamily: 'Google Sans',
      useMaterial3: true,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2D3748), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        prefixIconColor: AppColors.textSecondary,
        suffixIconColor: AppColors.textSecondary,
      ),
    );
  }

  ThemeData _lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.light1,
      primaryColor: AppColors.primary,
      fontFamily: 'Google Sans',
      useMaterial3: true,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.light4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: TextStyle(color: AppColors.light3, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.light2, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        prefixIconColor: AppColors.light3,
        suffixIconColor: AppColors.light3,
      ),
    );
  }
}

/// A [PageRoute] that zooms and fades the incoming screen in from the center,
/// giving a smooth, app-native feel when switching between tabs.
class ZoomPageRoute<T> extends PageRouteBuilder<T> {
  ZoomPageRoute({required WidgetBuilder builder, super.settings})
    : super(
        transitionDuration: const Duration(milliseconds: 310),
        reverseTransitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (context, animation, secondaryAnimation) =>
            builder(context),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          );
          return ScaleTransition(
            scale: Tween<double>(begin: 0.86, end: 1.0).animate(curved),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curved),
              child: child,
            ),
          );
        },
      );
}

/// A [PageRoute] that slides the incoming screen up from the bottom — used
/// for detail/action screens like the AI chatbot and RIASEC test.
class SlideUpPageRoute<T> extends PageRouteBuilder<T> {
  SlideUpPageRoute({required WidgetBuilder builder, super.settings})
    : super(
        transitionDuration: const Duration(milliseconds: 350),
        reverseTransitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (context, animation, secondaryAnimation) =>
            builder(context),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(curved),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curved),
              child: child,
            ),
          );
        },
      );
}
