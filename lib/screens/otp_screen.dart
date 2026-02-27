import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_colors.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  late List<TextEditingController> _otpControllers;
  late List<FocusNode> _otpFocusNodes;
  bool _isLoading = false;
  String? _errorMessage;
  String? _verificationId;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeOtpFields();
  }

  void _initializeOtpFields() {
    _otpControllers = List.generate(6, (_) => TextEditingController());
    _otpFocusNodes = List.generate(6, (_) => FocusNode());
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
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Container(
        decoration: _buildGradientDecoration(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
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
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  BoxDecoration _buildGradientDecoration() {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final colors = AppColors.gradientColors(isLight);
    return BoxDecoration(gradient: RadialGradient(radius: 1, colors: colors));
  }

  Widget _buildFloatingContainer(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _buildFormContent(context),
      ),
    );
  }

  List<Widget> _buildFormContent(BuildContext context) {
    return [
      const SizedBox(height: 10),
      _buildHeaderText(),
      const SizedBox(height: 15),
      _buildSubtitleText(),
      const SizedBox(height: 35),
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
      _buildOtpFields(),
      const SizedBox(height: 32),
      _buildVerifyButton(context),
      const SizedBox(height: 24),
      _buildResendOtpLink(),
    ];
  }

  Widget _buildHeaderText() {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Text(
      "Verify Your Email",
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryFor(isLight),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSubtitleText() {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Text(
      "Enter the 6-digit code sent to your email",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 14,
        color: AppColors.textSecondaryFor(isLight),
      ),
    );
  }

  Widget _buildOtpFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) => _buildOtpDigit(index)),
    );
  }

  Widget _buildOtpDigit(int index) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      width: 40,
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.inputFillColor(isLight),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor(isLight), width: 1.5),
      ),
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _otpFocusNodes[index],
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly,
        ],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimaryFor(isLight),
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            if (index < 5) {
              _otpFocusNodes[index + 1].requestFocus();
            } else {
              _otpFocusNodes[index].unfocus();
            }
          }
        },
      ),
    );
  }

  Widget _buildVerifyButton(BuildContext context) {
    return SizedBox(
      width: 300,
      child: ElevatedButton(
        onPressed: _isLoading ? null : () => _verifyOtp(context),
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
            : const Text("Verify & Continue"),
      ),
    );
  }

  Future<void> _verifyOtp(BuildContext context) async {
    final otp = _otpControllers.map((controller) => controller.text).join();

    if (otp.length != 6) {
      setState(() {
        _errorMessage = 'Please enter all 6 digits';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_verificationId != null) {
        final credential = PhoneAuthProvider.credential(
          verificationId: _verificationId!,
          smsCode: otp,
        );
        await _auth.signInWithCredential(credential);
      }

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/profile_completion',
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = 'Invalid OTP. Please try again';
        _isLoading = false;
      });
    }
  }

  Future<void> _resendOtp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // This would resend the OTP - implement based on your backend
      setState(() {
        _errorMessage = null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error resending OTP';
        _isLoading = false;
      });
    }
  }

  Widget _buildResendOtpLink() {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Didn't receive code? ",
          style: TextStyle(
            color: AppColors.textSecondaryFor(isLight),
            fontSize: 14,
          ),
        ),
        GestureDetector(
          onTap: _isLoading ? null : _resendOtp,
          child: const Text(
            "Resend OTP",
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
