import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import '../widgets/social_buttons.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isObscure = true;
  bool _isLoading = false;
  String? _errorMessage;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FacebookAuth _facebookAuth = FacebookAuth.instance;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (email.isEmpty || password.isEmpty) {
        setState(() {
          _errorMessage = 'Please fill in all fields';
          _isLoading = false;
        });
        return;
      }

      await _auth.signInWithEmailAndPassword(email: email, password: password);

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e.code);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred';
        _isLoading = false;
      });
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      default:
        return 'Login failed. Please try again';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Container(
          decoration: _buildGradientDecoration(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(24, 0, 24, bottomInset + 24),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildFloatingContainer(context),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
                child: Text(
                  "Developed By: Carl Dindo L. Cejas & Joshua Jhon Juariza",
                  style: TextStyle(fontSize: 8, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      toolbarHeight: 60,
      title: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Image.asset(
          isLight ? 'logos/name1.png' : 'logos/name.png',
          height: 200,
          width: 200,
          fit: BoxFit.contain,
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black87,
          ),
          onPressed: () => exit(0),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16, top: 10),
          child: IconButton(
            icon: Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                return Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: themeProvider.isDarkMode
                      ? Colors.white
                      : Colors.black87,
                );
              },
            ),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
            tooltip: 'Toggle Theme',
          ),
        ),
      ],
    );
  }

  BoxDecoration _buildGradientDecoration() {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final colors = isLight
        ? [AppColors.light1, AppColors.light2]
        : [const Color(0xFF00365D), Colors.black];
    return BoxDecoration(gradient: RadialGradient(radius: 1, colors: colors));
  }

  Widget _buildFloatingContainer(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: AppColors.containerColor(isLight),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderColor(isLight), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor(isLight),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(15),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _buildFormContent(context),
        ),
      ),
    );
  }

  List<Widget> _buildFormContent(BuildContext context) {
    return [
      const SizedBox(height: 15),
      _buildHeaderText(),
      const SizedBox(height: 30),
      if (_errorMessage != null) ...[
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            border: Border.all(color: Colors.red.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ),
        const SizedBox(height: 16),
      ],
      _buildEmailField(),
      const SizedBox(height: 8),
      _buildPasswordField(),
      const SizedBox(height: 12),
      _buildForgotPasswordLink(context),
      const SizedBox(height: 12),
      _buildLoginButton(),
      const SizedBox(height: 12),
      _buildSocialLoginDivider(),
      const SizedBox(height: 12),
      _buildSocialButtons(),
      const SizedBox(height: 5),
      _buildSignUpLink(context),
    ];
  }

  Widget _buildHeaderText() {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Column(
      children: [
        Text(
          "Welcome Back!",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryFor(isLight),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          "Log in to your account",
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondaryFor(isLight),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      enabled: !_isLoading,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.email_outlined),
        hintText: 'Email Address',
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      enabled: !_isLoading,
      obscureText: _isObscure,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock_outline),
        hintText: 'Password',
        suffixIcon: _buildVisibilityToggle(),
      ),
    );
  }

  Widget _buildVisibilityToggle() {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return IconButton(
      icon: Icon(
        _isObscure ? Icons.visibility_off : Icons.visibility,
        color: AppColors.iconColor(isLight),
      ),
      onPressed: () => setState(() => _isObscure = !_isObscure),
    );
  }

  Widget _buildForgotPasswordLink(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/forgot_password'),
        child: const Text(
          "Forgot Password?",
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: SizedBox(
        width: 300,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _login,
          child: _isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.black.withOpacity(0.7),
                    ),
                  ),
                )
              : const Text("Log In"),
        ),
      ),
    );
  }

  Widget _buildSocialLoginDivider() {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Text(
      "Or Login with",
      style: TextStyle(
        color: AppColors.textSecondaryFor(isLight),
        fontSize: 14,
        letterSpacing: 0.3,
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      UserCredential credential;
      if (kIsWeb) {
        credential = await _auth.signInWithPopup(GoogleAuthProvider());
      } else {
        final googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          setState(() {
            _isLoading = false;
          });
          return;
        }

        final googleAuth = await googleUser.authentication;
        final oauthCredential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        credential = await _auth.signInWithCredential(oauthCredential);
      }

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e.code);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Google Sign-In failed';
        _isLoading = false;
      });
    }
  }

  Future<UserCredential?> _signInWithFacebook() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (kIsWeb) {
        final userCredential = await _auth.signInWithPopup(
          FacebookAuthProvider(),
        );

        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        }
        return userCredential;
      } else {
        // 1. Trigger the Facebook sign-in flow
        final LoginResult result = await _facebookAuth.login(
          permissions: ['public_profile', 'email'],
        );

        if (result.status == LoginStatus.success) {
          // 2. Create a credential from the access token
          final OAuthCredential credential = FacebookAuthProvider.credential(
            result.accessToken!.token,
          );

          // 3. Sign in with Firebase using the credential
          final userCredential = await _auth.signInWithCredential(credential);

          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
            );
          }
          return userCredential;
        }

        setState(() {
          _errorMessage = 'Facebook Sign-In cancelled';
          _isLoading = false;
        });
        return null;
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = 'Firebase Error: ${e.message}';
        _isLoading = false;
      });
      return null;
    } catch (e) {
      setState(() {
        _errorMessage = 'Facebook Sign-In failed: $e';
        _isLoading = false;
      });
      return null;
    }
  }

  Widget _buildSocialButtons() {
    return Column(
      children: [
        SocialButton(
          text: "Log In with Google",
          imagePath: 'logos/google.png',
          onPressed: _isLoading ? null : _signInWithGoogle,
        ),
        const SizedBox(height: 8),
        SocialButton(
          text: "Log In with Facebook",
          imagePath: 'logos/facebook.png',
          onPressed: _isLoading ? null : _signInWithFacebook,
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildSignUpLink(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(
            color: AppColors.textSecondaryFor(isLight),
            fontSize: 14,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/signup'),
          child: const Text(
            "Sign Up",
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
