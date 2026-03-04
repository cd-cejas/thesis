import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../otp_service.dart';
import '../theme/app_colors.dart';
import '../widgets/social_buttons.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isObscure = true;
  bool _isLoading = false;
  String? _errorMessage;
  final _formKey = GlobalKey<FormState>();
  final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
    _confirmPasswordController.dispose();
    super.dispose();
  }

  final OtpService _otpService = OtpService();

  Future<bool> _deleteIncompleteAccountIfOwnedByPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) return false;

      final hasProfile =
          (await _firestore.collection('users').doc(user.uid).get()).exists;
      if (hasProfile) {
        await _auth.signOut();
        return false;
      }

      await _firestore
          .collection('email_otps')
          .doc(user.uid)
          .delete()
          .catchError((_) {});

      await user.delete();
      return true;
    } on FirebaseAuthException {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> _createAccountAndStartOtp({
    required String email,
    required String password,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = userCredential.user!.uid;

    final otpError = await _otpService.sendOtp(uid: uid, email: email);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (otpError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(otpError, style: const TextStyle(fontSize: 12)),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 6),
        ),
      );
    }

    Navigator.pushNamed(
      context,
      '/otp',
      arguments: {'email': email, 'uid': uid},
    );
  }

  Future<void> _signup() async {
    if (_isLoading) return;

    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    // confirmPassword is validated by the form validator below
    _confirmPasswordController.text.trim();

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _createAccountAndStartOtp(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        final cleaned = await _deleteIncompleteAccountIfOwnedByPassword(
          email: email,
          password: password,
        );

        if (cleaned) {
          try {
            await _createAccountAndStartOtp(email: email, password: password);
            return;
          } on FirebaseAuthException catch (retryError) {
            if (!mounted) return;
            setState(() {
              _errorMessage = _getErrorMessage(retryError.code);
              _isLoading = false;
            });
            return;
          } catch (_) {
            if (!mounted) return;
            setState(() {
              _errorMessage = 'An unexpected error occurred';
              _isLoading = false;
            });
            return;
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _errorMessage = _getErrorMessage(e.code);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'An unexpected error occurred';
        _isLoading = false;
      });
    }
  }

  Future<void> _signUpWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (kIsWeb) {
        await _auth.signInWithPopup(GoogleAuthProvider());
      } else {
        final googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          setState(() => _isLoading = false);
          return;
        }

        final googleAuth = await googleUser.authentication;
        final oauthCredential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await _auth.signInWithCredential(oauthCredential);
      }

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/profile_completion',
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e.code);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Google Sign-Up failed';
        _isLoading = false;
      });
    }
  }

  Future<UserCredential?> _signUpWithFacebook() async {
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
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/profile_completion',
            (route) => false,
          );
        }
        return userCredential;
      } else {
        final LoginResult result = await _facebookAuth.login(
          permissions: ['public_profile', 'email'],
        );

        if (result.status == LoginStatus.success &&
            result.accessToken != null) {
          final OAuthCredential credential = FacebookAuthProvider.credential(
            result.accessToken!.token,
          );

          final userCredential = await _auth.signInWithCredential(credential);

          if (mounted) {
            setState(() => _isLoading = false);
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/profile_completion',
              (route) => false,
            );
          }
          return userCredential;
        }

        setState(() {
          _errorMessage = 'Facebook Sign-Up cancelled';
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
        _errorMessage = 'Facebook Sign-Up failed: $e';
        _isLoading = false;
      });
      return null;
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Email already registered';
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password is too weak';
      case 'operation-not-allowed':
        return 'Account creation is not available';
      default:
        return 'Signup failed. Please try again';
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
      backgroundColor: isLight ? AppColors.light2 : Colors.transparent,
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
          onPressed: () => Navigator.pop(context),
        ),
      ),
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
      constraints: const BoxConstraints(maxWidth: 340),
      margin: const EdgeInsets.only(top: 32),
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
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _buildFormContent(context),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFormContent(BuildContext context) {
    return [
      const SizedBox(height: 8),
      _buildHeaderText(),
      const SizedBox(height: 25),
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
      const SizedBox(height: 8),
      _buildConfirmPasswordField(),
      const SizedBox(height: 8),
      _buildSignUpButton(context),
      const SizedBox(height: 12),
      _buildSocialSignUpDivider(),
      const SizedBox(height: 8),
      _buildSocialButtons(),
      const SizedBox(height: 8),
      _buildLoginLink(context),
    ];
  }

  Widget _buildHeaderText() {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Column(
      children: [
        Text(
          "Create Account",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryFor(isLight),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          "Sign up to get started",
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
      keyboardType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
      autovalidateMode: AutovalidateMode.onUserInteraction,
      textInputAction: TextInputAction.next,
      validator: (value) {
        final email = (value ?? '').trim();
        if (email.isEmpty) return 'Email is required';
        if (!_emailRegex.hasMatch(email)) return 'Enter a valid email';
        return null;
      },
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
      autovalidateMode: AutovalidateMode.onUserInteraction,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
      validator: (value) {
        final password = value ?? '';
        if (password.isEmpty) return 'Password is required';
        if (password.length < 6) return 'Use at least 6 characters';
        return null;
      },
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock_outline),
        hintText: 'Password',
        suffixIcon: _buildVisibilityToggle(),
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      enabled: !_isLoading,
      obscureText: _isObscure,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      textInputAction: TextInputAction.done,
      validator: (value) {
        final confirm = value ?? '';
        if (confirm.isEmpty) return 'Confirm your password';
        if (confirm != _passwordController.text)
          return 'Passwords do not match';
        return null;
      },
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock_outline),
        hintText: 'Confirm Password',
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

  Widget _buildSignUpButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _signup,
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
            : const Text("Sign Up"),
      ),
    );
  }

  Widget _buildSocialSignUpDivider() {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Text(
      "Or Create with",
      style: TextStyle(
        color: AppColors.textSecondaryFor(isLight),
        fontSize: 14,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildSocialButtons() {
    return Column(
      children: [
        SocialButton(
          text: "Sign Up with Google",
          imagePath: 'logos/google.png',
          onPressed: _isLoading ? null : _signUpWithGoogle,
        ),
        const SizedBox(height: 8),
        SocialButton(
          text: "Sign Up with Facebook",
          imagePath: 'logos/facebook.png',
          onPressed: _isLoading ? null : _signUpWithFacebook,
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account? ",
          style: TextStyle(
            color: AppColors.textSecondaryFor(isLight),
            fontSize: 14,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Text(
            "Log In",
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
